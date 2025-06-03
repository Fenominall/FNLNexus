//
//  FNLCircuitBreaker.swift
//  FNLNexus
//
//  Created by Fenominall on 6/2/25.
//

import Foundation

public actor FNLCircuitBreaker {
    // MARK: - State Definition
    public enum State: CustomStringConvertible, Sendable {
        case closed
        case open
        case halfOpen
        
        public var description: String {
            switch self {
            case .closed: return "Closed"
            case .open: return "Open"
            case .halfOpen: return "Half-Open"
            }
        }
    }
    
    // MARK: - Configuration
    public let failureThreshold: Int
    public let recoveryTimeout: TimeInterval
    public let halfOpenSuccessThreshold: Int
    
    // MARK: - Internal State (Protected by Actor)
    public private(set) var state: State = .closed
    private(set) var consecutiveFailures: Int = 0
    private(set) var lastFailureTime: Date? = nil
    private(set) var successfulHalfOpenAttempts: Int = 0
    
    // MARK: - Initialization
    public init(
        failureThreshold: Int = 3,
        recoveryTimeout: TimeInterval = 30.0,
        halfOpenSuccessThreshold: Int = 1
    ) throws {
        guard failureThreshold > 0, recoveryTimeout > 0, halfOpenSuccessThreshold > 0 else {
            throw FNLCircuitBreakerError.negativeValues
        }
        self.failureThreshold = failureThreshold
        self.recoveryTimeout = recoveryTimeout
        self.halfOpenSuccessThreshold = halfOpenSuccessThreshold
    }
    
    // MARK: - Core Logic: Performing the Request
    /// Executes the given asynchronous operation, applying circuit breaker logic.
    /// - Parameter operation: The async throwing closure representing the actual work (e.g., network call).
    /// - Returns: The result of the operation if successful.
    /// - Throws: `CircuitBreakerError.isOpen` if the circuit is open,
    ///           `CircuitBreakerError.operationFailedInHalfOpen` if the test request failed,
    ///           or the underlying error from the `operation` itself.
    public func performRequest<T: Sendable>(_ operation: @escaping () async throws -> T) async throws -> T {
        switch state {
        case .closed:
            do {
                let result = try await operation()
                recordSuccess()
                return result
            } catch {
                recordFailure()
                throw error // Propagate the original error
            }
            
        case .open:
            if let lastFailure = lastFailureTime, Date().timeIntervalSince(lastFailure) > recoveryTimeout {
                print("CircuitBreaker: Timeout elapsed. Moving to Half-Open.")
                transition(to: .halfOpen)
                // Immediately attempt the request in Half-Open state
                return try await performRequest(operation)
            } else {
                print("CircuitBreaker: Circuit is Open. Rejecting request.")
                throw FNLCircuitBreakerError.isOpen
            }
            
        case .halfOpen:
            print("CircuitBreaker: State is Half-Open. Attempting test request...")
            do {
                let result = try await operation()
                recordHalfOpenSuccess()
                return result
            } catch {
                print("CircuitBreaker: Test request failed in Half-Open state. Re-opening circuit.")
                recordFailure() // This will transition back to Open
                throw FNLCircuitBreakerError.operationFailedInHalfOpen(underlyingError: error)
            }
        }
    }
    
    // MARK: - State Transition Helpers (Private)
    
    private func recordSuccess() {
        // When successful in Closed state, reset failure count.
        // When successful in Half-Open, successfulHalfOpenAttempts is incremented, and might transition to Closed.
        // We ensure we don't accidentally reset failure count if we're in HalfOpen and then succeed,
        // as HalfOpen has its own success tracking logic.
        if state == .closed && consecutiveFailures > 0 {
            print("CircuitBreaker: Request succeeded in Closed state. Resetting failure count.")
            consecutiveFailures = 0
        }
        // If coming from HalfOpen, `recordHalfOpenSuccess` is called directly by `performRequest`.
    }
    
    private func recordHalfOpenSuccess() {
        guard state == .halfOpen else { return } // Ensure we are actually in half-open
        successfulHalfOpenAttempts += 1
        print("CircuitBreaker: Test request succeeded (\(successfulHalfOpenAttempts)/\(halfOpenSuccessThreshold)) in Half-Open.")
        if successfulHalfOpenAttempts >= halfOpenSuccessThreshold {
            print("CircuitBreaker: Threshold met. Moving back to Closed.")
            transition(to: .closed)
        }
    }
    
    private func recordFailure() {
        consecutiveFailures += 1
        lastFailureTime = Date()
        
        if state == .halfOpen {
            // Failure in Half-Open immediately transitions back to Open
            print("CircuitBreaker: Failure recorded in Half-Open state. Moving to Open.")
            transition(to: .open)
        } else if state == .closed && consecutiveFailures >= failureThreshold {
            // Failure threshold reached in Closed state, transition to Open
            print("CircuitBreaker: Failure threshold (\(failureThreshold)) reached. Moving to Open for \(recoveryTimeout) seconds.")
            transition(to: .open)
        } else if state == .closed {
            print("CircuitBreaker: Failure recorded (\(consecutiveFailures)/\(failureThreshold)) in Closed state.")
        }
        // If state is already Open, recording another failure just updates the lastFailureTime (implicitly handled by setting it above)
    }
    
    private func transition(to newState: State) {
        print("CircuitBreaker: Transitioning from \(state) to \(newState)")
        state = newState
        switch newState {
        case .closed:
            consecutiveFailures = 0
            lastFailureTime = nil
            successfulHalfOpenAttempts = 0
        case .open:
            // lastFailureTime is already set in recordFailure
            successfulHalfOpenAttempts = 0 // Reset just in case
        case .halfOpen:
            successfulHalfOpenAttempts = 0 // Reset counter for tracking successful attempts in this state
        }
    }
}

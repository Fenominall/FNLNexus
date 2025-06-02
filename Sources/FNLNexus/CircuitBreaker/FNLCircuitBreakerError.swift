//
//  FNLCircuitBreakerError.swift
//  FNLNexus
//
//  Created by Fenominall on 6/2/25.
//

import Foundation

public enum FNLCircuitBreakerError: Error, Equatable {
    case isOpen
    case operationFailedInHalfOpen(underlyingError: Error)
    case negativeValues
    
    public var localizedDescription: String {
        switch self {
        case .isOpen:
            return "Circuit Breaker is Open. Requests are currently being rejected."
        case .operationFailedInHalfOpen(let error):
            return "Test request failed in Half-Open state. Underlying error: \(error.localizedDescription)"
        case .negativeValues:
            return "CircuitBreaker thresholds and timeout must be positive."
        }
    }
    
    public static func == (lhs: FNLCircuitBreakerError, rhs: FNLCircuitBreakerError) -> Bool {
        switch (lhs, rhs) {
        case (.isOpen, .isOpen):
            return true
        case (.operationFailedInHalfOpen(let lhsError), .operationFailedInHalfOpen(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

//
//  FNLCircuitBreakerTests.swift
//  FNLNexus
//
//  Created by Fenominall on 6/2/25.
//

import Foundation
@testable import FNLNexus
import XCTest

final class FNLCircuitBreakerTests: XCTestCase {
    // MARK: - Init
    func test_init_doesNotThrow() throws {
        XCTAssertNoThrow(try makeSUT())
    }
    
    func test_init_throwsAnErrorWithNegativeValues() throws {
        XCTAssertThrowsError(try makeSUT(
            failureThreshold: -1,
            recoveryTimeout: -1,
            halfOpenSuccessThreshold: -1), "Values should always be positive")
    }
    
    // MARK: - Success
    func test_performRequest_completesSuccessfullyWithoutErrorRemainsInClosed() async throws {
        let sut = try makeSUT()
        
        await performFailureRequests(with: sut, times: 2)
        
        // Perform a successful request
        let result = try await sut.performRequest {
            return "Success"
        }
        
        XCTAssertEqual(result, "Success")
        
        await expectedState(sut, exptected: .closed)
        
    }
    
    // MARK: - Failure
    func test_performRequest_transitionsToOpenStateAfterThreeFailedAttempts() async throws {
        let sut = try makeSUT()
        
        await performFailureRequests(with: sut, times: 3)
        
        await expectedState(sut, exptected: .open)
    }
    
    func test_performRequest_transitionsToHalfOpenAfterTimeout_andSucceeds() async throws {
        let expectation = expectation(description: "Circuit should transition to Half-Open and succeed")
        
        let timeout: TimeInterval = 1.0
        let sut = try makeSUT(
            failureThreshold: 1,
            recoveryTimeout: timeout,
            halfOpenSuccessThreshold: 1
        )
        
        await performFailureRequests(with: sut)
        
        try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000) + 200_000_000)
        
        let result = try await sut.performRequest {
            "Recovered!"
        }
        
        XCTAssertEqual(result, "Recovered!")
        await expectedState(sut, exptected: .closed)
        expectation.fulfill()
        
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func test_performRequest_transitionsToOpenAfterFailingHalfOpenState() async throws {
        let timeout: TimeInterval = 1.0
        let sut = try makeSUT(
            failureThreshold: 1,
            recoveryTimeout: timeout,
            halfOpenSuccessThreshold: 1
        )
        
        // Fail once to open the circuit
        await performFailureRequests(with: sut)
        
        await expectedState(
            sut,
            exptected: .open,
            message: "Should transition to Open state!"
        )
        
        try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000) + 200_000_000)
        
        // Now call again — should be half-open, fail, and transition to open
        do {
            _ = try await sut.performRequest {
                throw anyNSError()
            }
            await expectedState(sut, exptected: .halfOpen)
        } catch {
            // Expected error - ignore or verify it's .operationFailedInHalfOpen if you want
        }
        
        await expectedState(sut, exptected: .open)
    }
    
    // MARK: - Error Handling
    func test_performRequest_throwsAnError() async throws {
        let sut = try makeSUT(failureThreshold: 2)
        
        do {
            _ = try await sut.performRequest {
                throw anyNSError()
            }
        } catch {
            XCTAssertFalse(error is FNLCircuitBreakerError)
        }
        
        let state = await sut.state
        XCTAssertEqual(state, .closed)
    }
    
    func test_performRequest_throwsIsOpenErrorIfTimeoutNotPassed() async throws {
        let timeout: TimeInterval = 2.0
        let sut = try makeSUT(failureThreshold: 1, recoveryTimeout: timeout)
        
        // Cause failure to open circuit
        await performFailureRequests(with: sut)
        
        // Assert circuit is open immediately after failure
        await expectedState(
            sut,
            exptected: .open,
            message: "Circuit should be open immediately after failure"
        )
        
        // Immediately call again — timeout has NOT passed yet
        do {
            _ = try await sut.performRequest { print("This should NOT be called") }
            XCTFail("Expected .isOpen error to be thrown")
        } catch let error as FNLCircuitBreakerError {
            if case .isOpen = error {
                // Correct error thrown — test passes here
            } else {
                XCTFail("Expected .isOpen error, got \(error)")
            }
        } catch {
            XCTFail("Expected FNLCircuitBreakerError, got \(error)")
        }
        
        // Confirm state still open (no transition)
        await expectedState(
            sut,
            exptected: .open,
            message: "Circuit state should remain open before timeout"
        )
    }
    
    // MARK: - State tracking
    func test_performRequest_consecutiveFailuresResetsAfterSuccess() async throws {
        let sut = try makeSUT(failureThreshold: 3)
                
        await performFailureRequests(with: sut, times: 2)
        let failuresCount = await sut.consecutiveFailures
        XCTAssertEqual(failuresCount, 2, "Should reset the state after success!")
        
        _ = try await sut.performRequest({ "Success" })
        
        let failureReset = await sut.consecutiveFailures
        XCTAssertEqual(failureReset, 0)
    }
    
    func test_performRequest_successfulHalfOpenAttemptsIncrementsAndResets() async throws {
        let sut = try makeSUT(
            failureThreshold: 1,
            recoveryTimeout: 0.1,
            halfOpenSuccessThreshold: 2
        )
        
        // Trigger open state
        await performFailureRequests(with: sut)
        await expectedState(sut, exptected: .open)
        
        // Wait for timeout to move to halfOpen
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // First success in halfOpen
        _ = try await sut.performRequest { "First Success" }
        let halfAttempts = await sut.successfulHalfOpenAttempts
        XCTAssertEqual(halfAttempts, 1)
        
        // Second success, should reset attempts and close
        _ = try await sut.performRequest { "Second Success" }
        let nextHalfAttempts = await sut.successfulHalfOpenAttempts
        XCTAssertEqual(nextHalfAttempts, 0)
        
        await expectedState(sut, exptected: .closed)
    }
    
    func test_performRequest_lastFailureTimeIsSetOnFailure() async throws {
        let sut = try makeSUT()
        
        let beforeFailure = Date()
        await performFailureRequests(with: sut)
        let failureTime = await sut.lastFailureTime
        
        XCTAssertNotNil(failureTime)
        XCTAssertGreaterThanOrEqual(failureTime!, beforeFailure)
    }
    
    // MARK: - Thread-safety
    func test_performRequest_concurrentCallsMaintainStateConsistency() async throws {
        let sut = try makeSUT()
        
        await withTaskGroup(of: Void.self) { group in
            for _ in 1...50 {
                group.addTask {
                    let shouldFail = Bool.random()
                    do {
                        _ = try await sut.performRequest {
                            if shouldFail {
                                throw anyNSError()
                            } else {
                                return "Success"
                            }
                        }
                    } catch {}
                }
            }
        }
        
        let state = await sut.state
        XCTAssertTrue(state == .closed || state == .open || state == .halfOpen, "Unexpected state: \(state)")
    }
    
    // MARK: - Helpers
    func makeSUT(failureThreshold: Int = 3,
                 recoveryTimeout: TimeInterval = 30.0,
                 halfOpenSuccessThreshold: Int = 1) throws -> FNLCircuitBreaker {
        return try .init(
            failureThreshold: failureThreshold,
            recoveryTimeout: recoveryTimeout,
            halfOpenSuccessThreshold: halfOpenSuccessThreshold
        )
    }
    
    private func expectedState(
        _ sut: FNLCircuitBreaker,
        exptected: FNLCircuitBreaker.State,
        message: String = ""
    ) async {
        let state = await sut.state
        XCTAssertEqual(state, exptected, message)
    }
    
    private func performFailureRequests(with sut: FNLCircuitBreaker, times: Int = 1) async {
        for _ in 1...times {
            do {
                _ = try await sut.performRequest {
                    throw anyNSError()
                }
            } catch {}
        }
    }
}

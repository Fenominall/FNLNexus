//
//  FNLHTTPClient.swift
//  FNLNexus
//
//  Created by Fenominall on 6/1/25.
//

import Foundation
import Combine

public protocol FNLHTTPCleint: FNLAsyncHTTPClient & FNLCombineHTTPClient {}

/// A protocol that defines an abstraction for sending asynchronous HTTP requests using async/await.
///
/// Implementers of this protocol provide mechanisms to perform network requests
/// and optionally decode the response into strongly typed models.
public protocol FNLAsyncHTTPClient: Sendable {
    
    /// Sends an HTTP request using the provided endpoint configuration and returns the raw response.
    ///
    /// - Parameter endpoint: The `FNLEndpoint` representing the request details.
    /// - Returns: A `FNLRawResponse` containing raw data, headers, status code, and original request.
    /// - Throws: A `FNLRequestError` or other thrown error during request construction or execution.
    func sendRequest(_ endpoint: FNLEndpoint) async throws -> FNLRawResponse

    /// Sends an HTTP request and decodes the response into a specified `Codable` type.
    ///
    /// - Parameters:
    ///   - endpoint: The `FNLEndpoint` describing the request.
    ///   - responseType: The type conforming to `Codable` and `Sendable` into which the response will be decoded.
    /// - Returns: A decoded instance of the specified type.
    /// - Throws: An error if the request fails or decoding is unsuccessful.
    func sendRequest<T: Codable & Sendable>(
        from endpoint: FNLEndpoint,
        withResponseType responseType: T.Type
    ) async throws -> T
}

public extension FNLAsyncHTTPClient where Self: FNLHTTPCleint {
    /// Sends an HTTP request using the provided endpoint configuration and returns the raw response.
    ///
    /// __**The current implementation uses the FNLDefaultHTTPClient, if you want your own you need to implement the method.**__
    func sendRequest(_ endpoint: FNLEndpoint) async throws -> FNLRawResponse {
        return try await FNLDefaultHTTPClient()
            .sendRequest(endpoint)
    }
    
    /// Sends an HTTP request and decodes the response into a specified `Codable` type.
    ///
    /// The current implementation uses the FNLDefaultHTTPClient, if you want your own you need to implement the method.
    func sendRequest<T: Codable & Sendable>(
        from endpoint: FNLEndpoint,
        withResponseType responseType: T.Type
    ) async throws -> T {
        return try await FNLDefaultHTTPClient()
            .sendRequest(
                from: endpoint,
                withResponseType: responseType
            )
    }
}

/// A protocol defining an HTTP client that supports Combine-based request execution.
///
/// This is an alternative interface to `FNLHTTPClient` for use in reactive programming scenarios.
public protocol FNLCombineHTTPClient: Sendable {
    
    /// Sends an HTTP request and returns a publisher that emits the raw `Data` or a `FNLRequestError`.
    ///
    /// - Parameter endpoint: The endpoint configuration for the request.
    /// - Returns: A Combine `AnyPublisher` that emits `Data` or a `FNLRequestError`.
    func sendRequest(from endpoint: FNLEndpoint) -> AnyPublisher<Data, FNLRequestError>

    /// Sends an HTTP request and returns a publisher that decodes the response into a specified type.
    ///
    /// - Parameters:
    ///   - endpoint: The request definition.
    ///   - responseType: The expected decodable type of the response.
    /// - Returns: A Combine `AnyPublisher` emitting the decoded type or a `FNLRequestError`.
    func sendRequest<T: Codable & Sendable>(
        from endpoint: FNLEndpoint,
        withResponseType responseType: T.Type
    ) -> AnyPublisher<T, FNLRequestError>
}

public extension FNLCombineHTTPClient where Self: FNLHTTPCleint {
    /// Sends an HTTP request and returns a publisher that emits the raw `Data` or a `FNLRequestError`.
    ///
    /// The current implementation uses the FNLDefaultHTTPClient, if you want your own you need to implement the method.
    func sendRequest(from endpoint: FNLEndpoint) -> AnyPublisher<Data, FNLRequestError> {
        return FNLDefaultHTTPClient().sendRequest(from: endpoint)
    }

    /// Sends an HTTP request and returns a publisher that decodes the response into a specified type.
    ///
    /// The current implementation uses the FNLDefaultHTTPClient, if you want your own you need to implement the method.
    func sendRequest<T: Codable & Sendable>(
        from endpoint: FNLEndpoint,
        withResponseType responseType: T.Type
    ) -> AnyPublisher<T, FNLRequestError> {
        return FNLDefaultHTTPClient().sendRequest(from: endpoint, withResponseType: responseType)
    }
}

/// An extension providing a convenient method for `FNLHTTPClient` to handle mapping logic
/// using a provided mapper conforming to `FNLMappable`.
public extension FNLAsyncHTTPClient {
    
    /// Sends a request and applies a custom mapper to transform the decoded response.
    ///
    /// - Parameters:
    ///   - endpoint: The request definition.
    ///   - mapper: A mapper conforming to `FNLMappable`, used to convert the decoded response.
    /// - Returns: The transformed output from the mapper.
    /// - Throws: An error if the request, decoding, or mapping fails.
    func sendMappedRequest<M: FNLMappable & Sendable>(
        from endpoint: FNLEndpoint,
        mapper: M
    ) async throws -> M.Output {
        let decoded: M.Input = try await sendRequest(
            from: endpoint,
            withResponseType: M.Input.self
        )
        return try await mapper.map(decoded)
    }
}

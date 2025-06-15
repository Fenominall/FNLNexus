//
//  File.swift
//  FNLNexus
//
//  Created by Fenominall on 6/2/25.
//

import Foundation
import Combine

/// A default implementation of `FNLHTTPClient` that uses `URLSession` to perform HTTP requests, it`s being used from the exntension providing a default implemtantion so there is no need to make it public.
///
/// This client is built to work with a custom `FNLRequestBuildable` request builder
/// and a `FNLDataDecoder` for decoding responses. It supports raw response fetching
/// and strongly typed decoding using Swift's `Codable`.
final class FNLDefaultHTTPClient {
    
    /// The URL session used to perform network requests.
    public let session: URLSession
    
    /// The request builder responsible for converting `FNLEndpoint` to `URLRequest`.
    public let requestBuilder: FNLRequestBuildable
    
    /// The decoder used to parse data responses into strongly typed models.
    public let decoder: FNLDataDecoder
    
    /// Initializes a new `FNLDefaultURLSessionHTTPClient`.
    ///
    /// - Parameters:
    ///   - session: A `URLSession` instance to use for requests. Defaults to `.shared`.
    ///   - requestBuilder: An object conforming to `FNLRequestBuildable` to construct requests.
    ///   - decoder: A `FNLDataDecoder` used to decode the response data. Defaults to `JSONDecoder()`.
    public init(
        session: URLSession = .shared,
        requestBuilder: FNLRequestBuildable = FNLRequestBuilder(),
        decoder: FNLDataDecoder = JSONDecoder()
    ) {
        self.session = session
        self.requestBuilder = requestBuilder
        self.decoder = decoder
    }
}

// MARK: - FNLHTTPClient

extension FNLDefaultHTTPClient: FNLHTTPClient {
    /// Sends a raw HTTP request using the provided endpoint.
    ///
    /// - Parameter endpoint: The endpoint that defines the request.
    /// - Returns: A `FNLRawResponse` containing the response data and metadata.
    /// - Throws: `FNLRequestError` if request building, network, or validation fails.
    public func sendRequest(_ endpoint: FNLEndpoint) async throws -> FNLRawResponse {
        do {
            let request = try buildRequest(from: endpoint)
            let (data, response) = try await session.data(for: request)
            let validatedResponse = try validateResponse(response)
            
            return FNLRawResponse(
                data: data,
                urlResponse: validatedResponse,
                request: request
            )
        } catch {
            throw handleError(error)
        }
    }
    
    /// Sends a typed HTTP request and decodes the result.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint that defines the request.
    ///   - responseType: The expected `Codable` type of the response.
    /// - Returns: A decoded object of the given type.
    /// - Throws: `FNLRequestError` if the request fails, the response is invalid,
    ///           or decoding fails.
    public func sendRequest<T: Codable & Sendable>(
        from endpoint: FNLEndpoint,
        withResponseType responseType: T.Type
    ) async throws -> T {
        do {
            let request = try buildRequest(from: endpoint)
            let (data, response) = try await session.data(for: request)
            _ = try validateResponse(response)
            return try decodeData(responseType, from: data)
        } catch let urlError as URLError {
            throw FNLRequestError(fromURLError: urlError)
        } catch {
            throw handleError(error)
        }
    }
    
    /// Sends a raw HTTP request using Combine and returns the response data.
    ///
    /// This is a convenience method for when you only need the raw `Data` response
    /// without decoding it into a model.
    ///
    /// - Parameter endpoint: The endpoint describing the request to perform.
    /// - Returns: A publisher that emits the raw `Data` or a `FNLRequestError`.
    public func sendRequest(from endpoint: any FNLEndpoint) -> AnyPublisher<Data, FNLRequestError> {
        performCombineRequest(for: endpoint) { $0 }
    }
    
    
    /// Sends a typed HTTP request using Combine and decodes the response into the specified `Codable` type.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint describing the request to perform.
    ///   - responseType: The expected `Codable` type to decode the response into.
    /// - Returns: A publisher that emits the decoded object or a `FNLRequestError`.
    public func sendRequest<T: Codable & Sendable>(
        from endpoint: any FNLEndpoint,
        withResponseType responseType: T.Type
    ) -> AnyPublisher<T, FNLRequestError> {
        performCombineRequest(for: endpoint) { [weak self] data in
            guard let self else { throw FNLRequestError.unknown("Self deallocated") }
            return try self.decodeData(responseType, from: data)
        }
    }
}

// MARK: - Helpers

extension FNLDefaultHTTPClient {
    
    /// Builds a `URLRequest` from the given endpoint.
    ///
    /// - Parameter endpoint: The endpoint to convert into a `URLRequest`.
    /// - Returns: A valid `URLRequest`.
    /// - Throws: `FNLRequestError.urlMalformed` if the request could not be built.
    private func buildRequest(from endpoint: FNLEndpoint) throws -> URLRequest {
        guard let request = requestBuilder.buildURLRequest(from: endpoint) else {
            throw FNLRequestError.urlMalformed
        }
        return request
    }
    
    /// Validates the HTTP response and ensures it's within the success range.
    ///
    /// - Parameter response: The `URLResponse` received from the server.
    /// - Returns: A validated `HTTPURLResponse`.
    /// - Throws: `FNLRequestError.noResponse` or an error based on the HTTP status code.
    private func validateResponse(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FNLRequestError.noResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw FNLRequestError(fromHttpStatusCode: httpResponse.statusCode)
        }
        
        return httpResponse
    }
    
    /// Decodes response data into a given `Codable` type.
    ///
    /// - Parameters:
    ///   - type: The expected type to decode.
    ///   - data: The raw response data.
    /// - Returns: A decoded object of the given type.
    /// - Throws: `FNLRequestError.decodingError` if decoding fails.
    private func decodeData<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws -> T {
        do {
            let decodedType = try decoder.decode(type, from: data)
            return decodedType
        } catch {
            throw FNLRequestError.decodingError(error.localizedDescription)
        }
    }
    
    /// Converts common system or transport-level errors into `FNLRequestError`.
    ///
    /// - Parameter error: The error to handle.
    /// - Returns: A mapped `FNLRequestError`.
    private func handleError(_ error: Error) -> FNLRequestError {
        if let error = error as? FNLRequestError {
            return error
        }

        if let urlError = error as? URLError {
            return FNLRequestError(fromURLError: urlError)
        }

        let errorCode = (error as NSError).code
        switch errorCode {
        case NSURLErrorTimedOut:
            return .timeout
        case NSURLErrorNotConnectedToInternet, NSURLErrorDataNotAllowed:
            return .noConnection
        case NSURLErrorNetworkConnectionLost:
            return .lostConnection
        default:
            return .unknown(error.localizedDescription)
        }
    }
    
    /// Performs a Combine-based HTTP request with customizable data transformation.
    ///
    /// This method abstracts the common request, validation, and transformation logic.
    /// It supports both raw data and decoded model use cases.
    ///
    /// - Parameters:
    ///   - endpoint: The `FNLEndpoint` representing the request.
    ///   - transform: A closure that maps the received `Data` to the expected return type `T`.
    /// - Returns: A publisher that emits either a transformed result of type `T` or a `FNLRequestError`.
    private func performCombineRequest<T>(
        for endpoint: FNLEndpoint,
        transform: @escaping (Data) throws -> T
    ) -> AnyPublisher<T, FNLRequestError> {
        do {
            let request = try buildRequest(from: endpoint)
            return session.dataTaskPublisher(for: request)
                .tryMap { [weak self] data, response in
                    guard let self else { throw FNLRequestError.unknown("Self deallocated") }
                    _ = try self.validateResponse(response)
                    return try transform(data)
                }
                .mapError { [weak self] in
                    self?.handleError($0) ?? .unknown($0.localizedDescription)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: handleError(error)).eraseToAnyPublisher()
        }
    }
}

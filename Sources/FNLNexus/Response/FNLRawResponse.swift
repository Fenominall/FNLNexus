//
//  FNLRawResponse.swift
//  FNLNexus
//
//  Created by Fenominall on 6/2/25.
//

import Foundation

/// A structure representing a raw HTTP response, including the response data,
/// the associated URL response, and the original URL request.
///
/// `FNLRawResponse` is typically used in a network abstraction layer to
/// capture and inspect the full details of a network transaction. It provides
/// utility methods for decoding JSON responses and inspecting metadata like
/// headers and status codes.
public struct FNLRawResponse {
    
    /// The raw body data returned by the server.
    public let data: Data
    
    /// The HTTP response received from the server, including status code and headers.
    public let urlResponse: HTTPURLResponse
    
    /// The original URL request that initiated the network call. Useful for debugging or retry logic.
    public let reqeust: URLRequest?
    
    /// Initializes a new instance of `FNLRawResponse`.
    ///
    /// - Parameters:
    ///   - data: The raw data received from the network call.
    ///   - urlResponse: The HTTP response object containing status code and headers.
    ///   - reqeust: The original URL request (optional).
    public init(
        data: Data,
        urlResponse: HTTPURLResponse,
        request: URLRequest? = nil
    ) {
        self.data = data
        self.urlResponse = urlResponse
        self.reqeust = request
    }
    
    /// Decodes the raw response data into a strongly typed model using a `JSONDecoder`.
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type to decode the data into.
    ///   - decoder: A custom `JSONDecoder` instance to use. Defaults to a new instance.
    /// - Returns: An instance of the specified `Decodable` type.
    /// - Throws: A decoding error if the data cannot be decoded.
    public func decode<T: Decodable>(as type: T.Type, using decoder: JSONDecoder = .init()) throws -> T {
        try decoder.decode(type, from: data)
    }
    
    /// Converts the raw response data into a Foundation object using `JSONSerialization`.
    ///
    /// - Parameter options: Options that affect the reading of the JSON data. Defaults to `[]`.
    /// - Returns: A Foundation object representing the JSON structure (e.g., dictionary or array).
    /// - Throws: An error if the data is not valid JSON.
    public func jsonObject(options: JSONSerialization.ReadingOptions = []) throws -> Any {
        try JSONSerialization.jsonObject(with: data, options: options)
    }
    
    /// The HTTP status code returned by the server.
    public var statusCode: Int {
        urlResponse.statusCode
    }
    
    /// All HTTP header fields returned in the response.
    public var headers: [AnyHashable: Any] {
        urlResponse.allHeaderFields
    }
}

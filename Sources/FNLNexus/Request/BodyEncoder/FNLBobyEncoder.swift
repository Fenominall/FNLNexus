//
//  BobyEncoder.swift
//  FNLNexus
//
//  Created by Fenominall on 5/31/25.
//

import Foundation

/// A protocol that defines an abstraction for encoding body parameters into `Data` and determining appropriate `Content-Type` headers.
public protocol FNLBodyEncoder: Sendable {
    
    /// Encodes a given `FNLBodyParameter` into a `Data` object suitable for transmission in an HTTP request.
    ///
    /// - Parameter body: The `FNLBodyParameter` to encode.
    /// - Returns: A `Data` object containing the encoded body, or `nil` if no encoding is necessary.
    /// - Throws: An error if the encoding process fails.
    func encode(_ body: FNLBodyParameter) throws -> Data?
    
    /// Returns the appropriate `Content-Type` header for a given `FNLBodyParameter`.
    ///
    /// - Parameter body: The body parameter for which to determine the content type.
    /// - Returns: A `String` representing the MIME type, or `nil` if no content type should be set.
    func contentType(for body: FNLBodyParameter) -> String?
}

/// A concrete implementation of `BodyEncoder` that supports JSON-based encoding using `JSONEncoder`.
public struct FNLJSONBodyEncoder: FNLBodyEncoder {
    
    public init() {}

    /// Encodes a `FNLBodyParameter` using JSON encoding.
    ///
    /// - Parameter body: The body parameter to encode.
    /// - Returns: The encoded `Data`, or `nil` if no encoding is needed.
    /// - Throws: An error if the encoding fails.
    public func encode(_ body: FNLBodyParameter) throws -> Data? {
        switch body {
        case .data(let data):
            return data
        case .encodable(let encodable, let encoder):
            return try encoder.encodeAny(encodable)
        case .jsonDictionary(let dict):
            return try JSONEncoder().encode(dict)
        }
    }

    /// Returns the `Content-Type` for a given `FNLBodyParameter`.
    ///
    /// - Parameter body: The body parameter.
    /// - Returns: `"application/json"` for encodable and JSON dictionary types; `nil` for raw data.
    public func contentType(for body: FNLBodyParameter) -> String? {
        switch body {
        case .data:
            return nil
        case .encodable, .jsonDictionary:
            return "application/json"
        }
    }
}

private extension JSONEncoder {
    /// Encodes a type-erased `Encodable` using the current `JSONEncoder` instance.
    ///
    /// - Parameter value: The `AnyEncodable` value to encode.
    /// - Returns: A `Data` object representing the encoded value.
    /// - Throws: An encoding error if the process fails.
    func encodeAny(_ value: AnyEncodable) throws -> Data {
        let wrapped = AnyEncodable(value)
        return try self.encode(wrapped)
    }
}

//
//  FNLBodyParameter.swift
//  FNLNexus
//
//  Created by Fenominall on 5/31/25.
//

import Foundation

/// Represents the body of an HTTP request.
///
/// Use `.data` for raw data payloads,
/// `.encodable` to wrap any `Encodable` type,
/// or `.jsonDictionary` to send a JSON object represented as a dictionary of key-value pairs.
public enum FNLBodyParameter: Sendable {
    /// Raw `Data` payload.
    case data(Data)
    
    /// An `Encodable` type wrapped in `AnyEncodable` for type-erased encoding.
    case encodable(AnyEncodable, encoder: JSONEncoder = .init())
    
    /// A JSON dictionary payload where values are typed as `CodableValue`.
    case jsonDictionary([String: CodableValue])
}

/// A type-erased `Encodable` wrapper that supports concurrency safety via `Sendable`.
///
/// This enables storing and encoding heterogeneous `Encodable` values
/// without exposing their concrete types, while preserving `Sendable` compliance.
public struct AnyEncodable: Encodable, Sendable {
    private let _encode: @Sendable (Encoder) throws -> Void

    /// Creates an instance that wraps the given `Encodable` and `Sendable` value.
    ///
    /// - Parameter wrapped: The concrete value to wrap and encode.
    public init<T: Encodable & Sendable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    /// Encodes the wrapped value into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: Propagates encoding errors from the wrapped value.
    @Sendable
    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

/// A type that can represent any JSON-compatible value in a type-safe manner.
///
/// Conforms to `Codable` and `Sendable`, enabling encoding, decoding,
/// and safe concurrent access.
public enum CodableValue: Codable, Sendable {
    /// A JSON string value.
    case string(String)
    /// A JSON integer number.
    case int(Int)
    /// A JSON floating-point number.
    case double(Double)
    /// A JSON boolean value.
    case bool(Bool)
    /// A JSON null value.
    case null

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// Supports decoding of JSON primitives: string, int, double, bool, or null.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if the value is not a supported JSON primitive.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(String.self) {
            self = .string(v)
        } else if let v = try? container.decode(Int.self) {
            self = .int(v)
        } else if let v = try? container.decode(Double.self) {
            self = .double(v)
        } else if let v = try? container.decode(Bool.self) {
            self = .bool(v)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.typeMismatch(
                CodableValue.self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid JSON value"
                )
            )
        }
    }

    /// Encodes this value into the given encoder.
    ///
    /// Writes the corresponding JSON primitive to the encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: Propagates encoding errors from the encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let v): try container.encode(v)
        case .int(let v): try container.encode(v)
        case .double(let v): try container.encode(v)
        case .bool(let v): try container.encode(v)
        case .null: try container.encodeNil()
        }
    }
}

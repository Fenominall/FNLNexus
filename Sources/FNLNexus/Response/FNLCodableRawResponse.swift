//
//  FNLCodablleRawResponse.swift
//  FNLNexus
//
//  Created by Fenominall on 6/15/25.
//

import Foundation

/// A wrapper for raw data received from a network response, intended for
/// use as an input for decoding operations.
///
/// Use `FNLCodableRawResponse` when a `Mapper` or other decoding component
/// needs to process the raw `Data` payload from an HTTP response, especially
/// when that data is expected to be `Codable`.
public struct FNLCodableRawResponse: Codable, Sendable {
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public func decode<T: Decodable>(as type: T.Type, using decoder: JSONDecoder = .init()) async throws -> T {
        try decoder.decode(type, from: data)
    }
}

//
//  FNLAPIResponse.swift
//  FNLNexus
//
//  Created by Fenominall on 6/1/25.
//

import Foundation

public struct FNLAPIResponse<T: Decodable>: Decodable {
    public let success: Bool
    public let message: String?
    public let result: T?
    public let fails: [String: [String]]?

    public var resultKey: String = "data" // Default, but can be overridden for different APIs

    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        func key(_ string: String) -> DynamicCodingKeys? {
            DynamicCodingKeys(stringValue: string)
        }

        guard let successKey = key("success"),
              let messageKey = key("message"),
              let failsKey = key("fails") else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Missing 'success' key.")
            )
        }
        self.success = try container.decode(Bool.self, forKey: successKey)

        self.message = try container.decode(String.self, forKey: messageKey)
        self.fails = try container.decode([String: [String]].self, forKey: failsKey)

        if let resultCodingKey = key(resultKey), container.contains(resultCodingKey) {
            self.result = try? container.decode(T.self, forKey: resultCodingKey)
        } else {
            self.result = nil
        }
    }
}

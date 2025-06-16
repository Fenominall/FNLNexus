//
//  DeepLinkQueryItems 2.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// A utility for safely extracting typed query values from a list of URLQueryItem.
public struct FNLDeepLinkQueryItems {
    private let items: [URLQueryItem]
    
    public init(items: [URLQueryItem]) {
        self.items = items
    }
    
    public enum ParsingError: LocalizedError {
        case missing(String)
        case invalidType(String, String)
        
        public var errorDescription: String? {
            switch self {
            case .missing(let key): return "Missing parameter: \(key)"
            case .invalidType(let key, let expected): return "Invalid type for \(key). Expected \(expected)."
            }
        }
    }
    
    public func string(for key: String) throws -> String {
        guard let value = items.first(where: { $0.name == key })?.value else {
            throw ParsingError.missing(key)
        }
        return value
    }
    
    public func int(for key: String) throws -> Int {
        let stringValue = try string(for: key)
        guard let value = Int(stringValue) else {
            throw ParsingError.invalidType(key, "Int")
        }
        return value
    }
}

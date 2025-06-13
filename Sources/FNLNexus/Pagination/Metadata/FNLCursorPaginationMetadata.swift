//
//  FNLCursorPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// Metadata for cursor-based pagination using a cursor token.
public struct FNLCursorPaginationMetadata: FNLPaginationMetadata {
    public let nextCursor: String?

    public init(nextCursor: String?) {
        self.nextCursor = nextCursor
    }
    
    public var hasMorePages: Bool {
        return nextCursor != nil
    }

    public func nextQueryItems() -> [URLQueryItem]? {
        guard let cursor = nextCursor else { return nil }
        return [URLQueryItem(name: "cursor", value: cursor)]
    }
}

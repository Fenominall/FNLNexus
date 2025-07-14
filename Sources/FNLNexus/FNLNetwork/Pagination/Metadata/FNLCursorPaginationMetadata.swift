//
//  FNLCursorPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// Metadata for cursor-based pagination using a cursor token.
public struct FNLCursorPaginationMetadata: FNLPaginationMetadata {
    private let nextCursor: String?
    private let perPage: Int
    
    public init(nextCursor: String?, perPage: Int) {
        self.nextCursor = nextCursor
        self.perPage = perPage
    }
    
    public var hasMorePages: Bool {
        return nextCursor != nil
    }

    public func nextQueryItems() -> [URLQueryItem]? {
        guard let cursor = nextCursor else { return nil }
        return [
            .init(name: "cursor", value: cursor),
            .init(name: "per_page", value: "\(perPage)")
        ]
    }
}

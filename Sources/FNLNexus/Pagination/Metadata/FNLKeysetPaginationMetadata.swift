//
//  FNLKeysetPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// Metadata for keyset-based pagination using an `after_id` marker.
public struct FNLKeysetPaginationMetadata: FNLPaginationMetadata {
    public let lastSeenId: String?
    public let hasMore: Bool

    public init(lastSeenId: String? = nil, hasMore: Bool) {
        self.lastSeenId = lastSeenId
        self.hasMore = hasMore
    }
    
    public var hasMorePages: Bool {
        return hasMore
    }

    public func nextQueryItems() -> [URLQueryItem]? {
        guard let id = lastSeenId else { return nil }
        return [URLQueryItem(name: "after_id", value: id)]
    }
}


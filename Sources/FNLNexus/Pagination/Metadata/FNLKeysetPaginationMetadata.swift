//
//  FNLKeysetPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// Metadata for keyset-based pagination using an `after_id` marker.
public struct FNLKeysetPaginationMetadata: FNLPaginationMetadata {
    private let lastSeenId: String?
    private let perPage: Int
    
    public init(lastSeenId: String?, perPage: Int) {
        self.lastSeenId = lastSeenId
        self.perPage = perPage
    }

    public var hasMorePages: Bool {
        return lastSeenId != nil
    }

    public func nextQueryItems() -> [URLQueryItem]? {
        guard let id = lastSeenId else { return nil }
        return [
            .init(name: "after_id", value: id),
            .init(name: "per_page", value: "\(perPage)")
        ]
    }
}


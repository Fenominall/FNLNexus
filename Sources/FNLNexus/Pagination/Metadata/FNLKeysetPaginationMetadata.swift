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
    public let perPage: Int

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


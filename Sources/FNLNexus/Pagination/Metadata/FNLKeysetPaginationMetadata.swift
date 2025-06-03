//
//  FNLKeysetPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

public struct KeysetPaginationMetadata: FNLPaginationMetadata {
    public let lastSeenId: String?
    public let hasMore: Bool

    public var hasMorePages: Bool {
        return hasMore
    }

    public func nextQueryItems() -> [URLQueryItem]? {
        guard let id = lastSeenId else { return nil }
        return [URLQueryItem(name: "after_id", value: id)]
    }
}


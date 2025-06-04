//
//  FNLOffsetPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// Metadata for traditional offset-based pagination.
public struct FNLOffsetPaginationMetadata: FNLPaginationMetadata {
    public let currentOffset: Int
    public let limit: Int
    public let totalCount: Int

    public var hasMorePages: Bool {
        return currentOffset + limit < totalCount
    }

    public func nextQueryItems() -> [URLQueryItem]? {
        guard hasMorePages else { return nil }
        return [
            URLQueryItem(name: "offset", value: "\(currentOffset + limit)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
    }
}


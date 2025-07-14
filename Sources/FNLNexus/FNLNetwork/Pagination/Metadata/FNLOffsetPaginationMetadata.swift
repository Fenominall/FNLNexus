//
//  FNLOffsetPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// Metadata for traditional offset-based pagination.
public struct FNLOffsetPaginationMetadata: FNLPaginationMetadata {
    private let currentOffset: Int
    private let limit: Int
    private let totalCount: Int
    
    public init(
        currentOffset: Int,
        limit: Int,
        totalCount: Int
    ) {
        self.currentOffset = currentOffset
        self.limit = limit
        self.totalCount = totalCount
    }
    
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


//
//  FNLAsyncPaginated.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// Holds a paginated result, including metadata and a loadMore closure.
public struct FNLAsyncPaginated<Item> {
    // Holds the current page of data
    public let items: [Item]
    // Allows to attach nextPageLoader logic and conditionally provide a loadMore
    public let metadata: FNLPaginationMetadata?
    // Holds logic to load the next page
    public let loadMore: (() async throws -> FNLAsyncPaginated<Item>)?
    
    public init(
        items: [Item],
        metadata: FNLPaginationMetadata? = nil,
        loadMore: (() async throws -> FNLAsyncPaginated<Item>)? = nil
    ) {
        self.items = items
        self.metadata = metadata
        self.loadMore = loadMore
    }
}

//
//  FNLCursorPaginationStrategy.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

public struct FNLGenericPaginationStrategy<Item, Metadata: FNLPaginationMetadata>: FNLPaginationStrategy {
    public typealias PageMetadata = Metadata
    
    private let endpoint: FNLEndpoint
    private let metadata: Metadata
    private let mapper: (FNLEndpoint) async throws -> ([Item], Metadata)
    
    public init(
        endpoint: FNLEndpoint,
        metadata: Metadata,
        mapper: @escaping (FNLEndpoint) async throws -> ([Item], Metadata)
    ) {
        self.endpoint = endpoint
        self.metadata = metadata
        self.mapper = mapper
    }
    
    public func loadPage() async throws -> FNLAsyncPaginated<Item> {
        let updatedEndpoint = FNLPaginatedRequestBuilder()
            .buildNextPageEndpoint(baseEndpoint: endpoint, metadata: metadata)
        
        let (items, newMetadata) = try await mapper(updatedEndpoint)
        
        let loadMoreClosure: (() async throws -> FNLAsyncPaginated<Item>)? = newMetadata.hasMorePages ? {
            let nextStrategy = FNLGenericPaginationStrategy<Item, Metadata>(
                endpoint: self.endpoint,
                metadata: newMetadata,
                mapper: self.mapper
            )
            return try await nextStrategy.loadPage()
        } : nil
        
        return FNLAsyncPaginated(
            items: items,
            metadata: newMetadata,
            loadMore: loadMoreClosure
        )
    }
}

//
//  FNLCursorPaginationStrategy.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// A generic pagination strategy that allows you to paginate over items using any metadata type
/// conforming to `FNLPaginationMetadata`.
///
/// This strategy builds the next endpoint using provided metadata, calls a custom mapper to load
/// and transform the response, and recursively creates `loadMore` closures when more pages are available.
///
/// Use this strategy when you need flexible pagination behavior across offset, cursor, or keyset
/// pagination systems.
public struct FNLGenericPaginationStrategy<Item, Metadata: FNLPaginationMetadata>: FNLPaginationStrategy {

    /// The type of metadata used to keep track of pagination progress.
    public typealias PageMetadata = Metadata

    // MARK: - Private Properties

    /// The base endpoint representing the current request configuration.
    private let endpoint: FNLEndpoint

    /// The metadata describing the current state of pagination.
    private let metadata: Metadata

    /// A closure that maps a paginated `FNLEndpoint` to a tuple containing a list of items
    /// and updated pagination metadata.
    ///
    /// This enables full customization of how paginated data is decoded or parsed.
    private let mapper: (FNLEndpoint) async throws -> ([Item], Metadata)

    // MARK: - Initialization

    /**
     Initializes a new instance of `FNLGenericPaginationStrategy`.

     - Parameters:
       - endpoint: The base endpoint used to construct paginated requests.
       - metadata: The pagination metadata describing the current pagination state.
       - mapper: A closure responsible for mapping the paginated endpoint response to items and new metadata.
     */
    public init(
        endpoint: FNLEndpoint,
        metadata: Metadata,
        mapper: @escaping (FNLEndpoint) async throws -> ([Item], Metadata)
    ) {
        self.endpoint = endpoint
        self.metadata = metadata
        self.mapper = mapper
    }

    // MARK: - Public Methods

    /// Loads the current page of paginated data.
    ///
    /// This method uses the internal pagination metadata to construct the next paginated endpoint,
    /// fetches the data using the `mapper` closure, and determines whether additional pages can be loaded.
    ///
    /// - Returns: An `FNLAsyncPaginated<Item>` containing the loaded items, metadata, and optional `loadMore` closure.
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

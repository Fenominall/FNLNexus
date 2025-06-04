//
//  FNLPaginationStrategy.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// A pagination strategy that can fetch a page of items.
public protocol FNLPaginationStrategy {
    associatedtype Item
    associatedtype PageMetadata: FNLPaginationMetadata

    /// Loads the current page and prepares for the next one.
    func loadPage() async throws -> FNLAsyncPaginated<Item>
}

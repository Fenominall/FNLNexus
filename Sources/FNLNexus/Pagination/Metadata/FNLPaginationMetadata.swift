//
//  FNLPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// Describes pagination metadata used to determine if more pages exist,
/// and how to build query items for fetching them.
public protocol FNLPaginationMetadata {
    /// Whether more pages are available.
    var hasMorePages: Bool { get }

    /// Generates URL query items for the next page.
    func nextQueryItems() -> [URLQueryItem]?
}


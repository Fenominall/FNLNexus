//
//  FNLPaginatedMapper.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// A protocol for mapping raw input into paginated results and metadata.
public protocol FNLPaginatedMapper: FNLMappable {
    associatedtype PageMetadata: FNLPaginationMetadata

    /// Current page's metadata
    var metadata: PageMetadata { get }

    /// Maps a raw input into a page of outputs and new metadata.
    func mapPage(_ input: Input) async throws -> ([Output], PageMetadata)
}

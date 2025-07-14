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

    /// Maps a raw input into a page of outputs and new metadata.
    func mapPage(_ input: Input) async throws -> (Output, PageMetadata)
}

extension FNLPaginatedMapper {
    public func map(_ input: Input) async throws -> Output {
        let (items, _) = try await mapPage(input)
        return items
    }
}

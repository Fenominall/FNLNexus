//
//  FNLDefaultPaginationMapper.swift
//  FNLNexus
//
//  Created by Fenominall on 6/15/25.
//

import Foundation

/// A default implementation of `FNLPaginatedMapper` for common JSON-based pagination.
public struct FNLDefaultPaginationMapper<Item: Decodable, Metadata: Decodable & FNLPaginationMetadata>: FNLPaginatedMapper & Sendable {
    public typealias PageMetadata = Metadata
    public typealias Input = FNLCodableRawResponse
    public typealias Output = [Item]

    public func mapPage(_ input: FNLCodableRawResponse) async throws -> (Output, Metadata) {
        let items = try JSONDecoder().decode([Item].self, from: input.data)
        let metadata = try JSONDecoder().decode(Metadata.self, from: input.data)
        return (items, metadata)
    }
}

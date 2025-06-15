//
//  FNLPaginationType.swift
//  FNLNexus
//
//  Created by Fenominall on 6/15/25.
//

import Foundation

/// Protocol that provides a convinient way for the client the use `FNLPaginationMetadata` strategy by using `FNLPaginationType`
public protocol FNLPaginationMetadataConvertible {
    func makeMetadata() -> FNLPaginationMetadata
}

/// An enumeration representing various standard pagination strategies.
///
/// Use `FNLPaginationType` to specify the initial configuration for how a
/// paginated request should behave, such as page-based, offset-based,
/// cursor-based, or keyset-based pagination.
public enum FNLPaginationType {
    /// Page-based pagination, defined by a starting page, items per page, and optional total pages.
    case page(start: Int, perPage: Int, totalpages: Int? = nil)
    /// Offset-based pagination, defined by a starting offset, a limit of items, and optional total count.
    case offset(start: Int, limit: Int, totalCount: Int?)
    /// Cursor-based pagination, defined by an optional starting cursor and items per page.
    case cursor(startCursor: String?, perPage: Int)
    /// Keyset-based pagination, defined by an optional last seen ID and items per page.
    case keyset(lastSeenId: String?, perPage: Int)
}

extension FNLPaginationType: FNLPaginationMetadataConvertible {
    /// Converts the `FNLPaginationType` case into a concrete `FNLPaginationMetadata` object.
    /// - Returns: A specific pagination metadata struct (e.g., `FNLPagePaginationMetadata`)
    ///   that conforms to `FNLPaginationMetadata`.
    public func makeMetadata() -> any FNLPaginationMetadata {
        switch self {
            
        case .page(start: let start, perPage: let perPage, totalpages: let totalpages):
            return FNLPagePaginationMetadata(currentPage: start, perPage: perPage, totalPages: totalpages)
            
        case .offset(start: let start, limit: let limit, totalCount: let totalCount):
            return FNLOffsetPaginationMetadata(currentOffset: start, limit: limit, totalCount: totalCount ?? .max)
            
        case .cursor(startCursor: let startCursor, perPage: let perPage):
            return FNLCursorPaginationMetadata(nextCursor: startCursor, perPage: perPage)
            
        case .keyset(lastSeenId: let lastSeenId, perPage: let perPage):
            return FNLKeysetPaginationMetadata(lastSeenId: lastSeenId, perPage: perPage)
        }
    }
}

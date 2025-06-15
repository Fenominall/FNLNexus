//
//  FNLPagePaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/13/25.
//

import Foundation

/// Metadata for  page-based pagination.
public struct FNLPagePaginationMetadata: FNLPaginationMetadata {
    let currentPage: Int
    let perPage: Int
    let totalPages: Int?
    
    public var hasMorePages: Bool {
        guard let totalPages else { return true }
        return currentPage < totalPages
    }
    
    public func nextQueryItems() -> [URLQueryItem]? {
        guard hasMorePages else { return nil }
        return [
            .init(name: "page", value: "\(currentPage + 1)"),
            .init(name: "per_page", value: "\(perPage)")
        ]
    }
}

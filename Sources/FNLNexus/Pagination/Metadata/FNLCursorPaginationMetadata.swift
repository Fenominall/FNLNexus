//
//  FNLCursorPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

public struct FNLCursorPaginationMetadata: FNLPaginationMetadata {
    public let nextCursor: String?
    
    public var hasMorePages: Bool {
        return nextCursor != nil
    }

    public func nextQueryItems() -> [URLQueryItem]? {
        guard let cursor = nextCursor else { return nil }
        return [URLQueryItem(name: "cursor", value: cursor)]
    }
}

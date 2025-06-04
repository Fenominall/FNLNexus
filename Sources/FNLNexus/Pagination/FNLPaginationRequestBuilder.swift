//
//  FNLPaginationRequestBuilder.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

/// Constructs a new endpoint for fetching the next page based on metadata.
public struct FNLPaginatedRequestBuilder {
    public init() {}
    
    public func buildNextPageEndpoint(
        baseEndpoint: FNLEndpoint,
        metadata: FNLPaginationMetadata
    ) -> FNLEndpoint {
        var nextItems = baseEndpoint.params ?? []
        if let next = metadata.nextQueryItems() {
            for item in next where !nextItems.contains(where: { $0.name == item.name }) {
                nextItems.append(contentsOf: next)
            }
        }
        
        return FNLAPIEndpoint(
            method: baseEndpoint.method,
            headers: baseEndpoint.headers,
            scheme: baseEndpoint.scheme,
            host: baseEndpoint.host,
            path: baseEndpoint.path,
            body: baseEndpoint.body,
            params: nextItems
        )
    }
}

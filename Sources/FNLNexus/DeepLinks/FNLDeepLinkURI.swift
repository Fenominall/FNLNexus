//
//  DeepLinkURI 2.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// Parses a URL into its path, query parameters, scheme, etc.
/// Used for resolving registered handlers.
public struct FNLDeepLinkURI: Sendable {
    public let url: URL
    public let scheme: String?
    public let host: String?
    public let path: String
    public let queryItems: [URLQueryItem]
    public let fragment: String?
    
    public init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        self.url = url
        self.scheme = components.scheme
        self.host = components.host
        self.path = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.queryItems = components.queryItems ?? []
        self.fragment = components.fragment
    }
    
    public func queryValue(for key: String) -> String? {
        queryItems.first { $0.name == key }?.value
    }
}

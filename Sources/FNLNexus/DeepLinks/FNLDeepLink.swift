//
//  DeepLink 2.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// Represents a parsed deep link, typically modeled as a value type (e.g., struct). Includes its path and associated query parameters.
public protocol FNLDeepLink: Sendable {
    associatedtype Result = Void
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

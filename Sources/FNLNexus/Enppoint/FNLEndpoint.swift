//
//  FNLEndpoint.swift
//  FNLNexus
//
//  Created by Fenominall on 5/31/25.
//

import Foundation

/// Represents HTTP headers as a dictionary of key-value pairs.
///
/// The keys and values are both `String`s representing header field names and their values.
public typealias Header = [String: String]

/// Defines the requirements for an HTTP API endpoint.
///
/// Conforming types describe the components needed to build a network request,
/// including the HTTP method, headers, URL components, body, and query parameters.
///
/// The protocol conforms to `Sendable` for safe concurrent usage.
public protocol FNLEndpoint: Sendable {
    /// The HTTP method of the request (e.g., GET, POST, PUT, DELETE).
    var method: FNLRequestMethod { get }
    
    /// Optional HTTP headers to include in the request.
    var headers: Header? { get }
    
    /// The URL scheme (e.g., "https", "http") for the request.
    var scheme: FNLScheme { get }
    
    /// The host (domain or IP address) of the endpoint.
    var host: String { get }
    
    /// The path component of the URL (e.g., "/users", "/api/v1/data").
    var path: String { get }
    
    /// Optional body parameter to send with the request.
    var body: FNLBodyParameter? { get }
    
    /// Optional query parameters appended to the URL.
    var params: [URLQueryItem]? { get }
}


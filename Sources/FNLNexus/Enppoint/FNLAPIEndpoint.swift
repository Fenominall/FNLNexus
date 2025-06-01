//
//  FNLAPIEndpoint.swift
//  FNLNexus
//
//  Created by Fenominall on 6/1/25.
//

import Foundation

/// A concrete implementation of `FNLEndpoint` representing a standard API request definition.
///
/// `FNLAPIEndpoint` encapsulates all the necessary components required to build a complete
/// `URLRequest`, including HTTP method, headers, URL components, request body, and query parameters.
///
/// Use this type to define endpoints in a type-safe, decoupled manner across your networking layer.
///
/// Example usage:
/// ```
/// let endpoint = FNLAPIEndpoint(
///     method: .get,
///     scheme: .https,
///     host: "api.example.com",
///     path: "/users",
///     params: [URLQueryItem(name: "page", value: "1")]
/// )
/// ```
///
/// This type is particularly useful when paired with a `FNLRequestBuilder` to transform
public struct FNLAPIEndpoint: FNLEndpoint {
    public var method: FNLRequestMethod
    public var headers: Header?
    public var scheme: FNLScheme
    public var host: String
    public var path: String
    public var body: FNLBodyParameter?
    public var params: [URLQueryItem]?
    
    public init(
        method: FNLRequestMethod,
        headers: Header? = nil,
        scheme: FNLScheme,
        host: String,
        path: String,
        body: FNLBodyParameter? = nil,
        params: [URLQueryItem]? = nil
    ) {
        self.method = method
        self.headers = headers
        self.scheme = scheme
        self.host = host
        self.path = path
        self.body = body
        self.params = params
    }
}

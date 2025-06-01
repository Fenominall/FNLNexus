//
//  FNLRequestBuilder.swift
//  FNLNexus
//
//  Created by Fenominall on 5/31/25.
//

import Foundation

/// A builder responsible for constructing `URLRequest` instances from `FNLEndpoint` definitions.
public struct FNLRequestBuilder: FNLRequestBuildable {
    
    /// The encoder used to serialize the request body, defaulting to `JSONBodyEncoder`.
    private let bodyEncoder: FNLBodyEncoder

    /// Initializes a new `FNLRequestBuilder` with a given body encoder.
    ///
    /// - Parameter bodyEncoder: An optional `BodyEncoder` to use. Defaults to `JSONBodyEncoder`.
    public init(bodyEncoder: FNLBodyEncoder = FNLJSONBodyEncoder()) {
        self.bodyEncoder = bodyEncoder
    }

    /// Constructs a `URLRequest` from the specified `FNLEndpoint`.
    ///
    /// - Parameter endpoint: The endpoint describing the request configuration.
    /// - Returns: A configured `URLRequest` or `nil` if the URL is invalid or encoding fails.
    public func buildURLRequest(from endpoint: FNLEndpoint) -> URLRequest? {
        var components = URLComponents()
        components.scheme = endpoint.scheme.rawValue
        components.host = endpoint.host
        components.path = endpoint.path
        components.queryItems = endpoint.params

        guard let url = components.url else { return nil }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.allHTTPHeaderFields = endpoint.headers ?? [:]

        if let body = endpoint.body {
            do {
                if let encodedBody = try bodyEncoder.encode(body) {
                    urlRequest.httpBody = encodedBody
                    if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil,
                       let contentType = bodyEncoder.contentType(for: body) {
                        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
                    }
                }
            } catch {
                return nil
            }
        }

        return urlRequest
    }
}

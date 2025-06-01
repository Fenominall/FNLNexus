//
//  FNLAPIEndpoint.swift
//  FNLNexus
//
//  Created by Fenominall on 6/1/25.
//

import Foundation

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

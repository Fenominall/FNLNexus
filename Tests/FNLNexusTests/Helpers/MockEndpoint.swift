//
//  MockEndpoint.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import FNLNexus
import Foundation

struct MockEndpoint: FNLEndpoint {
    var method: FNLRequestMethod
    var headers: Header?
    var scheme: FNLScheme
    var host: String
    var path: String
    var body: FNLNexus.FNLBodyParameter?
    var params: [URLQueryItem]?
    
    init(
        method: FNLRequestMethod = .get,
        headers: Header? = nil,
        scheme: FNLScheme = .https,
        host: String = "api.example.com",
        path: String = "/test",
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

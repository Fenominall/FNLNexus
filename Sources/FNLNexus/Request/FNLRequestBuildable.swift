//
//  FFNLRequestBuildableile.swift
//  FNLNexus
//
//  Created by Fenominall on 5/31/25.
//

import Foundation

public protocol FNLRequestBuildable: Sendable {
    func buildURLRequest(from endpoint: FNLEndpoint) -> URLRequest?
}

//
//  FNLDeepLinkContext 2.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// A tuple used internally to pass dependencies into a handler factory closure.
public typealias FNLDeepLinkContext = (
    uri: FNLDeepLinkURI,
    dependencies: FNLDeepLinkHandlerDependencies,
    container: FNLDependencyContainer
)

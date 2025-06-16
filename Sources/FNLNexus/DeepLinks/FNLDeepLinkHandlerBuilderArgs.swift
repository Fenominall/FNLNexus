//
//  FNLDeepLinkHandlerBuilderArgs.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// Passed into a handler factory to allow injection of the deep link, dependencies, and DI container.
public struct FNLDeepLinkHandlerBuilderArgs<D: FNLDeepLink> {
    public let deepLink: D
    public let dependencies: FNLDeepLinkHandlerDependencies
    public let container: FNLDependencyContainer
    
    public init(deepLink: D, dependencies: FNLDeepLinkHandlerDependencies, container: FNLDependencyContainer) {
        self.deepLink = deepLink
        self.dependencies = dependencies
        self.container = container
    }
}

public protocol DeepLinksRegisterHelper: Actor {
    func register<D: FNLDeepLink>(
        path: String,
        builder: @escaping (FNLDeepLinkQueryItems) throws -> D,
        handler: @escaping (FNLDeepLinkHandlerBuilderArgs<D>) -> some FNLDeepLinkHandler
    )
}

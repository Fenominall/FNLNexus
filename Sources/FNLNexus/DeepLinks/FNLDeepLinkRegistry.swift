//
//  FNLDeepLinkRegistry.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// Used by features/modules to register their handlers.
/// Call registerDeepLinkHandlers(using:) during app startup.
public protocol FNLDeepLinkHandlerRegister {
    func registerDeepLinkHandlers(using helper: DeepLinksRegisterHelper)
}

public actor FNLDeepLinkRegistry: DeepLinksRegisterHelper, Sendable {
    private var handlers: [String: (FNLDeepLinkContext) async throws -> (any FNLDeepLink, any FNLDeepLinkHandler)?] = [:]

    public init() {}

    public func register<D: FNLDeepLink>(
        path: String,
        builder: @escaping (FNLDeepLinkQueryItems) throws -> D,
        handler: @escaping (FNLDeepLinkHandlerBuilderArgs<D>) -> some FNLDeepLinkHandler
    ) {
        handlers[path] = { context in
            let (uri, dependencies, container) = context
            let query = FNLDeepLinkQueryItems(items: uri.queryItems)
            let deepLink = try builder(query)
            let args = FNLDeepLinkHandlerBuilderArgs(deepLink: deepLink, dependencies: dependencies, container: container)
            let builtHandler = handler(args)
            return (deepLink, builtHandler)
        }
    }

    public func resolve(
        for uri: FNLDeepLinkURI,
        dependencies: FNLDeepLinkHandlerDependencies,
        container: FNLDependencyContainer
    ) async throws -> (any FNLDeepLink, any FNLDeepLinkHandler)? {
        guard let resolver = handlers[uri.path] else { return nil }
        return try await resolver((uri, dependencies, container))
    }

    public func registerAll(_ modules: [FNLDeepLinkHandlerRegister]) {
        modules.forEach { $0.registerDeepLinkHandlers(using: self) }
    }
}

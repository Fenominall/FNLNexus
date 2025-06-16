//
//  FNLDeepLinkHandlingServiceManager.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public protocol FNLDeepLinkHandlingService: Sendable {
    func handle(deepLinkUrl: URL) async -> FNLDeepLinkHandlingResult
}

public final class FNLDeepLinkHandlingServiceManager: FNLDeepLinkHandlingService {
    private let registry: FNLDeepLinkRegistry
    private let dependencies: FNLDeepLinkHandlerDependencies
    private let container: FNLDependencyContainer

    public init(registry: FNLDeepLinkRegistry, dependencies: FNLDeepLinkHandlerDependencies, container: FNLDependencyContainer) {
        self.registry = registry
        self.dependencies = dependencies
        self.container = container
    }

    public func handle(deepLinkUrl: URL) async -> FNLDeepLinkHandlingResult {
        guard let uri = FNLDeepLinkURI(url: deepLinkUrl) else {
            dependencies.messageDisplayable.displayError(FNLDeepLinkHandlingError.invalidURL)
            return .failure(FNLDeepLinkHandlingError.invalidURL)
        }

        var deepLink: (any FNLDeepLink)?
        var handler: (any FNLDeepLinkHandler)?
        
        do {
            guard let resolved = try await registry.resolve(for: uri, dependencies: dependencies, container: container) else {
                let error = FNLDeepLinkHandlingError.noHandler(uri.path)
                dependencies.messageDisplayable.displayError(error)
                return .failure(error)
            }

            (deepLink, handler) = resolved
            
            try await handler?.handle()
            return .success

        } catch {
            let resolvedError = FNLDeepLinkHandlingError.handlerFailure(path: uri.path, originalError: error, deepLink: deepLink)
            dependencies.messageDisplayable.displayError(resolvedError)
            return .failure(resolvedError)
        }
    }
}

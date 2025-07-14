//
//  FNLBaseDeepLinkHandler.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// A generic deep link handler that injects the deep link and a service.
public final class BaseDeepLinkHandler<DL: FNLDeepLink, S: Sendable>: FNLDeepLinkHandler {
    private let deepLink: DL
    private let dependencies: FNLDeepLinkHandlerDependencies
    private let service: S
    private let handleLogic: @Sendable (DL, S, FNLDeepLinkHandlerDependencies) async throws -> Void

    public init(
        deepLink: DL,
        dependencies: FNLDeepLinkHandlerDependencies,
        container: FNLDependencyContainer,
        resolveService: (FNLDependencyContainer) throws -> S,
        handleLogic: @escaping @Sendable (DL, S, FNLDeepLinkHandlerDependencies) async throws -> Void
    ) throws {
        self.deepLink = deepLink
        self.dependencies = dependencies
        self.service = try resolveService(container)
        self.handleLogic = handleLogic
    }

    public func handle() async throws {
        try await handleLogic(deepLink, service, dependencies)
    }
}

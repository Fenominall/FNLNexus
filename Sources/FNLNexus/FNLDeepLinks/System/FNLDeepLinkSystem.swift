//
//  FNLDeepLinkSystem.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public struct FNLDeepLinkSystem {
    public let registry: FNLDeepLinkRegistryService
    public let handlerService: FNLDeepLinkHandlingService

    public init(
        container: FNLDependencyContainer,
        uiAdapter: ComposedUIAdapter,
        modules: [FNLDeepLinkHandlerRegister]
    ) async {
        let registry = FNLDeepLinkRegistryService()
        let dependencies = FNLDeepLinkHandlerDependencies(
            messageDisplayable: uiAdapter,
            activityDisplayable: uiAdapter,
            contentReloadable: uiAdapter,
            completionHandler: uiAdapter
        )

        await registry.registerAll(modules)
        let service = FNLMainActorDeepLinkHandlingDecorator(
            decoratee: FNLDeepLinkHandlingServiceManager(
                registry: registry,
                dependencies: dependencies,
                container: container
            )
        )

        self.registry = registry
        self.handlerService = service
    }
}

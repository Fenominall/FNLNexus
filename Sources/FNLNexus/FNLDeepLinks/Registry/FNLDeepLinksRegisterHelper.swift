//
//  File.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public protocol FNLDeepLinksRegisterHelper: Actor {
    func register<D: FNLDeepLink>(
        path: String,
        builder: @escaping (FNLDeepLinkQueryItems) throws -> D,
        // Make the handler throwing
        handler: @escaping (FNLDeepLinkHandlerBuilderArgs<D>) throws -> some FNLDeepLinkHandler
    )
}

extension FNLDeepLinksRegisterHelper {
    public func register<DL: FNLDeepLink, S>(
        path: String,
        builder: @escaping (FNLDeepLinkQueryItems) throws -> DL,
        serviceType: S.Type,
        handler: @escaping @Sendable (DL, S, FNLDeepLinkHandlerDependencies) async throws -> Void
    ) where S: Sendable {
        self.register(
            path: path,
            builder: builder,
            handler: { args in
                try BaseDeepLinkHandler(
                    deepLink: args.deepLink,
                    dependencies: args.dependencies,
                    container: args.container,
                    resolveService: { _ in try args.container.resolve() as S },
                    handleLogic: handler
                )
            }
        )
    }
}

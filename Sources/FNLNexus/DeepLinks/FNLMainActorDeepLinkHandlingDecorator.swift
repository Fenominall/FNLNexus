//
//  FNLMainActorDeepLinkHandlingDecorator.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// Decorator ensures that deep link handling runs on the main actor.
public final class FNLMainActorDeepLinkHandlingDecorator: FNLDeepLinkHandlingService {
    private let decoratee: FNLDeepLinkHandlingService

    public init(decoratee: FNLDeepLinkHandlingService) {
        self.decoratee = decoratee
    }

    public func handle(deepLinkUrl: URL) async -> FNLDeepLinkHandlingResult {
        let decoratee = self.decoratee
        return await Task { @MainActor in
            await decoratee.handle(deepLinkUrl: deepLinkUrl)
        }.value
    }
}

//
//  FNLComposedUIAdapter.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public final class ComposedUIAdapter:
    FNLMessageDisplayable,
    FNLActivityDisplayable,
    FNLContentReloadable,
    FNLDeepLinkCompletionHandler
{
    private let messageDisplayable: FNLMessageDisplayable
    private let activityDisplayable: FNLActivityDisplayable
    private let contentReloadable: FNLContentReloadable
    private let deepLinkCompletionHandler: FNLDeepLinkCompletionHandler

    public init(
        messageDisplayable: FNLMessageDisplayable,
        activityDisplayable: FNLActivityDisplayable,
        contentReloadable: FNLContentReloadable,
        deepLinkCompletionHandler: FNLDeepLinkCompletionHandler
    ) {
        self.messageDisplayable = messageDisplayable
        self.activityDisplayable = activityDisplayable
        self.contentReloadable = contentReloadable
        self.deepLinkCompletionHandler = deepLinkCompletionHandler
    }

    public func displayMessage(_ message: String) {
        messageDisplayable.displayMessage(message)
    }

    public func displayError(_ error: Error) {
        messageDisplayable.displayError(error)
    }

    public func displayActivity() {
        activityDisplayable.displayActivity()
    }

    public func hideActivity() {
        activityDisplayable.hideActivity()
    }

    public func reloadContent() {
        contentReloadable.reloadContent()
    }

    public func handleDeepLinkCompletion(deepLink: any FNLDeepLink, result: FNLDeepLinkHandlingResult) {
        deepLinkCompletionHandler.handleDeepLinkCompletion(deepLink: deepLink, result: result)
    }
}

//
//  FNLDeepLinkHandlerDependencies.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// A container for UI-related services passed to handlers:
public struct FNLDeepLinkHandlerDependencies: Sendable {
    public let messageDisplayable: MessageDisplayable
    public let activityDisplayable: ActivityDisplayable
    public let contentReloadable: ContentReloadable
    public let completionHandler: DeepLinkCompletionHandler
    
    public init(
        messageDisplayable: MessageDisplayable,
        activityDisplayable: ActivityDisplayable,
        contentReloadable: ContentReloadable,
        completionHandler: DeepLinkCompletionHandler
    ) {
        self.messageDisplayable = messageDisplayable
        self.activityDisplayable = activityDisplayable
        self.contentReloadable = contentReloadable
        self.completionHandler = completionHandler
    }
}

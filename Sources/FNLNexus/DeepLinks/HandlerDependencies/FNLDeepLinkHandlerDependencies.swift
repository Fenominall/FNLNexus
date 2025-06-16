//
//  FNLDeepLinkHandlerDependencies.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// A container for UI-related services passed to handlers:
public struct FNLDeepLinkHandlerDependencies: Sendable {
    public let messageDisplayable: FNLMessageDisplayable
    public let activityDisplayable: FNLActivityDisplayable
    public let contentReloadable: FNLContentReloadable
    public let completionHandler: DeepLinkCompletionHandler
    
    public init(
        messageDisplayable: FNLMessageDisplayable,
        activityDisplayable: FNLActivityDisplayable,
        contentReloadable: FNLContentReloadable,
        completionHandler: DeepLinkCompletionHandler
    ) {
        self.messageDisplayable = messageDisplayable
        self.activityDisplayable = activityDisplayable
        self.contentReloadable = contentReloadable
        self.completionHandler = completionHandler
    }
}

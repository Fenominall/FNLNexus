//
//  FNLDeepLinkHandlerRegister.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// Used by features/modules to register their handlers.
/// Call registerDeepLinkHandlers(using:) during app startup.
public protocol FNLDeepLinkHandlerRegister: Sendable {
    func registerDeepLinkHandlers(using helper: FNLDeepLinksRegisterHelper)
}

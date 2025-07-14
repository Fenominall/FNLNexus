//
//  FNLDeepLinkCompletionHandler.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public protocol FNLDeepLinkCompletionHandler: AnyObject, Sendable {
    func handleDeepLinkCompletion(deepLink: any FNLDeepLink, result: FNLDeepLinkHandlingResult)
}

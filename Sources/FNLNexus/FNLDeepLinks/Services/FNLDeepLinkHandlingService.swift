//
//  FNLDeepLinkHandlingService.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public protocol FNLDeepLinkHandlingService: Sendable {
    func handle(deepLinkUrl: URL) async -> FNLDeepLinkHandlingResult
}

//
//  File 2.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// Handles the behavior for a given deep link. Can throw and supports async operations.
public protocol FNLDeepLinkHandler: Sendable {
    func handle() async throws
}


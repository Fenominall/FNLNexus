//
//  File 2.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

/// Indicates the result of a deep link handling attempt.
public enum FNLDeepLinkHandlingResult: Sendable {
    case success
    case failure(Error)
    case cancelled
}

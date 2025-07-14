//
//  FNLScheme.swift
//  FNLNexus
//
//  Created by Fenominall on 5/31/25.
//

import Foundation

/// Represents the URL scheme used in an HTTP request.
///
/// This enum defines the supported URL schemes for network requests,
/// indicating whether the connection uses HTTP or HTTPS.
///
/// Conforms to `Sendable` for safe usage in concurrent contexts.
public enum FNLScheme: String, Sendable {
    /// The unsecured HTTP scheme.
    case http
    
    /// The secured HTTPS scheme.
    case https
}


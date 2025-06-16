//
//  FNLDeepLinkHandlingError.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public enum FNLDeepLinkHandlingError: LocalizedError {
    case invalidURL
    case noHandler(String)
    case handlerFailure(path: String, originalError: Error, deepLink: (any FNLDeepLink)?)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .noHandler(let path):
            return "No handler registered for path '\(path)'."
        case .handlerFailure(let path, let error, _):
            return "Handler for path '\(path)' failed: \(error.localizedDescription)"
        case .unknown:
            return "Unknown error occurred while handling deep link."
        }
    }
}

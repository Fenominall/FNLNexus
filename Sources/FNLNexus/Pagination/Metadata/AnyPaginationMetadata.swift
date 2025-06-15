//
//  AnyPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/15/25.
//

import Foundation

import Foundation

/// A type-erasing wrapper for any `FNLPaginationMetadata` conforming instance.
///
/// Use `AnyPaginationMetadata` when you need to store or pass around a
/// `FNLPaginationMetadata` instance without knowing its specific underlying type.
/// This is particularly useful in generic contexts, such as a pagination
/// strategy that needs to work with various kinds of pagination metadata
/// (e.g., page-based, offset-based, cursor-based).
///
/// It forwards calls to `hasMorePages` and `nextQueryItems()` to the
/// underlying `base` metadata instance.
public struct AnyPaginationMetadata: FNLPaginationMetadata {
    // Private closures to capture and forward calls to the underlying base object.
    private let _hasMorePages: () -> Bool
    private let _nextQueryItems: () -> [URLQueryItem]?

    /// The underlying `FNLPaginationMetadata` instance that this wrapper holds.
    public let base: any FNLPaginationMetadata

    /// Creates a type-erased pagination metadata wrapper around a given base instance.
    ///
    /// - Parameter base: The concrete instance of `FNLPaginationMetadata` to wrap.
    public init(_ base: any FNLPaginationMetadata) {
        self.base = base
        self._hasMorePages = { base.hasMorePages }
        self._nextQueryItems = { base.nextQueryItems() }
    }

    /// A Boolean value indicating whether there are more pages of data available
    /// from the underlying metadata.
    ///
    /// This property simply forwards the call to the `hasMorePages` property
    /// of the wrapped `base` instance.
    public var hasMorePages: Bool {
        _hasMorePages()
    }

    /// Returns an array of `URLQueryItem`s required to fetch the next page of results
    /// from the underlying metadata.
    ///
    /// This method forwards the call to the `nextQueryItems()` method
    /// of the wrapped `base` instance.
    ///
    /// - Returns: An optional array of `URLQueryItem`s. Returns `nil` if there are
    ///   no more pages or if the underlying metadata does not provide parameters
    ///   for the next page.
    public func nextQueryItems() -> [URLQueryItem]? {
        _nextQueryItems()
    }
}

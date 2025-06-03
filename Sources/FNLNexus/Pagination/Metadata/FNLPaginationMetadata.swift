//
//  FNLPaginationMetadata.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

public protocol FNLPaginationMetadata {
    var hasMorePages: Bool { get }
    
    func nextQueryItems() -> [URLQueryItem]?
}

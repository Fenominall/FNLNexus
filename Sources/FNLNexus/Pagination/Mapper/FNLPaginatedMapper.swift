//
//  FNLPaginatedMapper.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation

// Type that can be implemented for the reusable mapping and next page logic.
public protocol FNLPaginatedMapper: FNLMappable {
    associatedtype PageMetadata: FNLPaginationMetadata
    
    var medata: PageMetadata { get }
    
    func mapPage(_ input: Input) async throws -> ([Output], PageMetadata)
}

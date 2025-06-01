//
//  FNLMappable.swift
//  FNLNexus
//
//  Created by Fenominall on 6/1/25.
//

import Foundation

public protocol FNLMappable {
    associatedtype Input: Codable & Sendable
    associatedtype Output
    
    func map(_ input: Input) async throws -> Output
}

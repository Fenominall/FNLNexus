//
//  FNLServiceResolvable.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public protocol ServiceResolvable: Sendable {
    associatedtype Service
    func resolveService(from container: FNLDependencyContainer) throws -> Service
}

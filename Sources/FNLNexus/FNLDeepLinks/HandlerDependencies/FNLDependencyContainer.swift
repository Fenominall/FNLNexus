//
//  FNLDependencyContainer 2.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public protocol FNLDependencyContainer: Sendable {
    func resolve<T>() throws -> T
}

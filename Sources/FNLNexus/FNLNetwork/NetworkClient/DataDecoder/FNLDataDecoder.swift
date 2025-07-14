//
//  FNLDataDecoder.swift
//  FNLNexus
//
//  Created by Fenominall on 6/2/25.
//

import Foundation

public protocol FNLDataDecoder: Sendable {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: FNLDataDecoder {}

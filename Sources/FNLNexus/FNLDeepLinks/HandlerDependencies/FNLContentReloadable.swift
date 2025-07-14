//
//  FNLContentReloadable.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public protocol FNLContentReloadable: AnyObject, Sendable {
    func reloadContent()
}

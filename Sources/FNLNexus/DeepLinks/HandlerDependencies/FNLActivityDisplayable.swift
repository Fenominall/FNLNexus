//
//  FNLActivityDisplayable.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public protocol FNLActivityDisplayable: AnyObject, Sendable {
    func displayActivity()
    func hideActivity()
}

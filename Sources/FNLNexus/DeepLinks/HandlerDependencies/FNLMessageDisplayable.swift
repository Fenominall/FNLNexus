//
//  FNLMessageDisplayable.swift
//  FNLNexus
//
//  Created by Fenominall on 6/16/25.
//

import Foundation

public protocol FNLMessageDisplayable: AnyObject, Sendable {
    func displayMessage(_ message: String)
    func displayError(_ error: Error)
}

//
//  FNLRequestMethod.swift
//  FNLNexus
//
//  Created by Fenominall on 5/31/25.
//

import Foundation

/// Represents the HTTP request method used in a network request.
///
/// This enum defines standard HTTP methods commonly used
/// to specify the desired action to be performed on the resource.
public enum FNLRequestMethod: String {
    /// The HTTP DELETE method, used to delete a resource.
    case delete = "DELETE"
    
    /// The HTTP GET method, used to retrieve data from a resource.
    case get = "GET"
    
    /// The HTTP PATCH method, used to apply partial modifications to a resource.
    case patch = "PATCH"
    
    /// The HTTP POST method, used to create a new resource or submit data.
    case post = "POST"
    
    /// The HTTP PUT method, used to create or replace a resource.
    case put = "PUT"
}


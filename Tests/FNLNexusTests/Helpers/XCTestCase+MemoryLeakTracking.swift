//
//  XCTestCase+MemoryLeakTracking.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let weakObject = WeakTestRef(instance)
        
        XCTAssertNil(
            weakObject,
            "Instance should have been deallocated. Potenially memory leak",
            file: file,
            line: line
        )
    }
}


private class WeakTestRef<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T) {
        self.value = value
    }
}

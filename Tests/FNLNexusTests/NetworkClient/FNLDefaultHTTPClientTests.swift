//
//  FNLDefaultHTTPClientTests.swift
//  FNLNexus
//
//  Created by Fenominall on 6/3/25.
//

import Foundation
import XCTest
import FNLNexus

final class FNLDefaultHTTPClientTests: XCTestCase {
    // MARK: - Setup
    override func tearDown() async throws {
        try await super.tearDown()
        
        await URLProtocolStub.removeStub()
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> FNLHTTPCleint {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let requestBuilder = FNLRequestBuilder()
        let sut = FNLDefaultHTTPClient(
            session: session,
            requestBuilder: requestBuilder
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultValuesFor(
        _ values: (data: Data?, response: URLResponse?, error: Error?),
        file: StaticString = #filePath,
        line: UInt = #line
    ) async -> (data: Data, response: HTTPURLResponse)? {
        do {
            let result = try await resultFor(values, file: file, line: line)
            return (result.data, result.urlResponse)
        } catch {
            XCTFail("Expected success, but got \(error) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(
        _ values: (data: Data?, response: URLResponse?, error: Error?)? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async -> Error? {
        do {
            let result  = try await resultFor(values, file: file, line: line)
            XCTFail("Expected failure, but got \(result) instead", file: file, line: line)
            return nil
        } catch {
            return error
        }
    }
    
    private func resultFor(
        _ values: (data: Data?, response: URLResponse?, error: Error?)?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> FNLRawResponse {
        if let values = values {
            await URLProtocolStub.stub(
                data: values.data,
                response: values.response,
                error: values.error
            )
        }
        
        let sut = makeSUT(file: file, line: line)
        let endpoint = MockEndpoint()
        return try await sut.sendRequest(endpoint)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}

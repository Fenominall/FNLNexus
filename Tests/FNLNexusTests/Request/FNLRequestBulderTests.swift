//
//  File.swift
//  FNLNexus
//
//  Created by Fenominall on 6/2/25.
//

import Foundation
import XCTest
import FNLNexus

final class FNLRequestBulderTests: XCTestCase {
    
    func test_buildURLRequest_withGETRequestWithoutBodyShouldBuildCorrectURLRequest() {
        let endpoint = MockEndpoint(
            headers: ["Accept": "application/json"],
            path: "/users",
            params: [URLQueryItem(name: "page", value: "1")]
        )
        
        let sut = makeSUT()
        let request = sut.buildURLRequest(from: endpoint)
        
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.url?.absoluteString, "https://api.example.com/users?page=1")
        XCTAssertEqual(request?.httpMethod, endpoint.method.rawValue)
        XCTAssertEqual(request?.allHTTPHeaderFields?["Accept"], endpoint.headers?.values.first)
        XCTAssertNil(request?.httpBody)
    }
    
    
    
    func test_buildURLRequest_withEncodableBodyShouldSetBodyAndContentType() {
        struct DummyBody: Encodable { let name: String }
        
        let endpoint = MockEndpoint(
            method: .post,
            body: .encodable(AnyEncodable(DummyBody(name: "Jhon"))),
        )
        
        let sut = makeSUT()
        let request = sut.buildURLRequest(from: endpoint)
        
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.httpMethod, endpoint.method.rawValue)
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(request?.httpBody)
    }
    
    func test_buildURLRequest_withBodyEncodingFailsShouldReturnNil() {
        struct FailingBody: Encodable {
            func encode(to encoder: Encoder) throws {
                throw NSError(domain: "TestError", code: -1, userInfo: nil)
            }
        }
        
        let endpoint = MockEndpoint(
            method: .post,
            body: .encodable(AnyEncodable(FailingBody()))
        )
        
        let sut = makeSUT()
        let request = sut.buildURLRequest(from: endpoint)
        
        XCTAssertNil(request)
    }
    
    func test_buildURLRequest_withInvalidURLShouldReturnNil() {
        let endpoint = MockEndpoint(
            host: ""
        )
        let sut = makeSUT()
        let request = sut.buildURLRequest(from: endpoint)
        
        XCTAssertNil(request)
    }
    
    func test_buildURLRequest_bodyAsDataShouldSetHTTPBody() {
        let rawData = anyData()
        
        let endpoint = MockEndpoint(
            method: .post,
            body: .data(rawData),
        )
        
        let sut = makeSUT()
        let request = sut.buildURLRequest(from: endpoint)
        
        XCTAssertEqual(request?.httpBody, rawData)
    }
    
    func test_buildURLRequest_withBodyAsJSONDictionaryShouldEncodeAndSetHttpBody() throws {
        let dictionary: [String: CodableValue] = [
            "name": .string("Alice"),
            "age": .int(30)
        ]
        
        let endpoint = MockEndpoint(
            method: .post,
            body: .jsonDictionary(dictionary),
        )
        
        let sut = FNLRequestBuilder()
        let request = sut.buildURLRequest(from: endpoint)
        
        let data = try XCTUnwrap(request?.httpBody)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        XCTAssertEqual(json?["name"] as? String, "Alice")
        XCTAssertEqual(json?["age"] as? Int, 30)
    }
    
    func test_buildURLRequest_withQueryParametersShouldBeEncodedInURL() {
        let endpoint = MockEndpoint(
            params: [URLQueryItem(name: "q", value: "Swift")],
        )
        
        let sut = FNLRequestBuilder()
        let request = sut.buildURLRequest(from: endpoint)
        
        XCTAssertTrue(request?.url?.absoluteString.contains("q=Swift") ?? false)
    }
    
    func test_buildURLRequest_CustomHeadersShouldBeSet() {
        let endpoint = MockEndpoint(
            headers: ["Authorization": "Bearer 123"]
        )
        
        let sut = FNLRequestBuilder()
        let request = sut.buildURLRequest(from: endpoint)
        
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Authorization"), "Bearer 123")
    }
    
    func test_buildURLRequest_existingContentTypeShouldNotBeOverwritten() {
        let endpoint = MockEndpoint(
            headers: ["Content-Type": "application/xml"],
            body: .encodable(AnyEncodable(["key": "value"]))
        )
        
        let sut = FNLRequestBuilder()
        let request = sut.buildURLRequest(from: endpoint)
        
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/xml")
    }
    // MARK: - Helpers
    private func makeSUT() -> FNLRequestBuilder {
        return FNLRequestBuilder()
    }
    
    private struct MockEndpoint: FNLEndpoint {
        var method: FNLRequestMethod
        var headers: Header?
        var scheme: FNLScheme
        var host: String
        var path: String
        var body: FNLNexus.FNLBodyParameter?
        var params: [URLQueryItem]?
        
        init(
            method: FNLRequestMethod = .get,
            headers: Header? = nil,
            scheme: FNLScheme = .https,
            host: String = "api.example.com",
            path: String = "/test",
            body: FNLBodyParameter? = nil,
            params: [URLQueryItem]? = nil
        ) {
            self.method = method
            self.headers = headers
            self.scheme = scheme
            self.host = host
            self.path = path
            self.body = body
            self.params = params
        }
    }
}

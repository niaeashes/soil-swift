//
//  SoilEndpoint.swift
//  
//
//  Created by niaeashes on 2022/08/07.
//

import XCTest
import SoilSwift

class SoilEndpointTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    struct MockEndpoint: SoilEndpoint {
        var path: String = "/sample"
        var method: String = "GET"
        var queryData: Dictionary<String, String> = [
            "q": "Search Query",
            "sample": "",
        ]
        typealias Response = Void
    }

    func testExample() throws {
        let endpoint = MockEndpoint()
        let url = endpoint.buildUrl()

        XCTAssertEqual(url!.absoluteString, "/sample?sample&q=Search%20Query")
    }

    // Check buildable
    struct NonQueryDataEndpoint: SoilEndpoint {
        var path: String = "/sample"
        var method: String = "GET"
        typealias Response = Void
    }

}

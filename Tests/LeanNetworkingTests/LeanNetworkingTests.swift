import XCTest
@testable import LeanNetworking
import Combine

final class LeanNetworkingTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    func test_GET_request_building_HAPPY_PATH() {
        let baseURL = "https://fewlinesofcode.com"
        let endpoint = try! Endpoint<String>(baseURL: baseURL)
                .appendingPathParameter("blog")
                .appendingPathParameter("10")
                .usingUserAgent("firefox")
                .usingContentType("application/json")
                .usingDateDecodingStrategy(.fullDateFormatter)
                .usingMethod(.GET)
                .appendingQueryItem(key: "limit", value: "10")
                .build()
        
        XCTAssertEqual("https://fewlinesofcode.com/blog/10?limit=10", endpoint.request.url?.absoluteString)
        XCTAssertEqual(endpoint.request.allHTTPHeaderFields?["User-Agent"], "firefox")
        XCTAssertEqual(endpoint.request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(endpoint.request.httpMethod, "GET")
    }
    
    func test_POST_request_building_HAPPY_PATH() {
        struct Send: Encodable {
            let name: String
        }
        
        struct Receive: Decodable {
            let ok: Bool
        }
        
        let baseURL = "https://fewlinesofcode.com"
        
        let endpoint = try! Endpoint<Receive>(baseURL: baseURL)
                .appendingPathParameter("update")
                .usingUserAgent("firefox")
                .usingContentType("application/json")
                .bySettingBody(Send(name: "Morpheus"))
                .usingDateDecodingStrategy(.fullDateFormatter)
                .usingMethod(.POST)
                .build()
        
        XCTAssertEqual("https://fewlinesofcode.com/update", endpoint.request.url?.absoluteString)
        XCTAssertEqual(endpoint.request.allHTTPHeaderFields?["User-Agent"], "firefox")
        XCTAssertEqual(endpoint.request.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(endpoint.request.httpMethod, "POST")
    }
}

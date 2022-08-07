//
//  SoilEndpoint.swift
//
//  Created by niaeashes on 2022/08/04.
//

import Foundation
import Combine

public class InvalidEndpointError: Error {}
public class InvalidResponseError: Error {}

public protocol SoilEndpoint {
    associatedtype RequestBody
    associatedtype Response
    var path: String { get }
    var method: String { get }
    var queryData: Dictionary<String, String> { get }
    var body: Self.RequestBody { get }

    func getBody(config: SoilEndpointConfiguration?) throws -> Data?
    func decode(config: SoilEndpointConfiguration?, response data: Data) throws -> Response
}

public extension SoilEndpoint {
    var queryData: Dictionary<String, String> { [:] }
}

// MARK: - get body method.

public extension SoilEndpoint where RequestBody: Encodable {

    func getBody(config: SoilEndpointConfiguration?) throws -> Data? {
        let encoder = JSONEncoder()
        if let config = config {
            encoder.keyEncodingStrategy = config.keyEncodingStrategy
        }
        return try encoder.encode(body)
    }
}

public extension SoilEndpoint where RequestBody == Void  {

    var body: Void { () }

    func getBody(config: SoilEndpointConfiguration?) throws -> Data?{
        nil
    }
}

// MARK: - `decode` method.

public extension SoilEndpoint where Response: Decodable {

    func decode(config: SoilEndpointConfiguration?, response data: Data) throws -> Response {
        let decoder = JSONDecoder()
        if let config = config {
            decoder.keyDecodingStrategy = config.keyDecodingStrategy
        }
        return try decoder.decode(Response.self, from: data)
    }
}

public extension SoilEndpoint where Response == Void {

    func decode(config: SoilEndpointConfiguration?, response data: Data) throws -> Response {
        ()
    }
}

// MARK: - `request` method.

extension SoilEndpoint {

    public func buildUrl(configuration: SoilEndpointConfiguration? = .shared) -> URL? {

        guard var url = URLComponents(string: "\(configuration?.baseUrl ?? "")\(path)") else {
            return nil
        }

        url.queryItems = []

        self.queryData.forEach { key, value in
            if (value.isEmpty) {
                url.queryItems?.append(.init(name: key, value: nil))
            } else {
                url.queryItems?.append(.init(name: key, value: value))
            }
        }

        url.queryItems?.sort { $0.name.compare($1.name) != .orderedAscending }

        return url.url
    }

    public func request(configuration: SoilEndpointConfiguration? = .shared) -> AnyPublisher<Self.Response, Error> {

        guard let url = buildUrl(configuration: configuration) else {
            assertionFailure("Invalid url with path: \(path)")
            return Fail(error: InvalidEndpointError()).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = try? getBody(config: configuration)

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { data, response -> Response in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode > 299 {
                    assertionFailure("Invalid response")
                } else {
                    return try self.decode(config: configuration, response: data)
                }
                throw InvalidResponseError()
            }
            .eraseToAnyPublisher()
    }
}

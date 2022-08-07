//
//  SoilEndpointConfiguration.swift
//  
//
//  Created by niaeashes on 2022/08/05.
//

import Foundation

public struct SoilEndpointConfiguration {
    public var baseUrl: String

    public var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    public var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys

    public static var shared: Self? = nil

    public init(baseUrl: String) {
        self.baseUrl = baseUrl
    }

    public static func configuration(baseUrl: String, _ builder: (inout Self) -> Void) {
        var config = Self(baseUrl: baseUrl)
        builder(&config)
        Self.shared = config
    }
}

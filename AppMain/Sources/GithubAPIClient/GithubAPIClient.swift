//
//  GithubAPIClient.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/01.
//

import Foundation

public struct GithubAPIClient {
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    public init() {}
    
    public func send<Request: GithubAPIBaseRequest>(request: Request) async throws -> Request.Response {
        
        let result = try await session.data(for: request.buildURLRequest())
        try validate(data: result.0, response: result.1)
        return try decoder.decode(Request.Response.self, from: result.0)
    }
    
    func validate(data: Data, response: URLResponse) throws {
        guard let code = (response as? HTTPURLResponse)?.statusCode else {
            throw GithubAPIClientError.connectionError(data)
        }
        
        guard (200..<300).contains(code) else {
            throw GithubAPIClientError.apiError
        }
    }
}


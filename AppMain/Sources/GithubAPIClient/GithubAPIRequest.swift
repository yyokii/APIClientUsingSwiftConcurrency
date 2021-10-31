//
//  GithubAPIRequest.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/01.
//

import Foundation

let baseURLString: String = "https://api.github.com"

/// Get a user
public struct UserInformationRequest: GithubAPIBaseRequest {
    public typealias Response = UserInformation
    
    public var baseURL: URL = URL(string: baseURLString)!
    public var path: String = "users"
    public var method: HTTPMethod = .get
    public var body: String = ""
    public var queryItems: [URLQueryItem] = []
    
    public init(userName: String) {
        path += "/\(userName)"
    }
}

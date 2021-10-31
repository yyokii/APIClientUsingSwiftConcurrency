//
//  GithubAPIClientError.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/01.
//

import Foundation

enum GithubAPIClientError: Error {
    case connectionError(Data)
    case apiError
}

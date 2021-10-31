//
//  File.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/01.
//

import Combine
import GithubAPIClient

actor HomeViewModel: ObservableObject {

    @MainActor @Published var id: Int = -1
    @MainActor @Published var login: String = ""
    @MainActor @Published var followers: Int = 0
    @MainActor @Published var following: Int = 0
    
    let client = GithubAPIClient()
    
    init() {}
    
    func fetchChrisInfo() async {
        let req = UserInformationRequest(userName: "defunkt")
        
        do {
            let data: UserInformation = try await client.send(request: req)
            await MainActor.run { [weak self] in
                self?.id = data.id
                self?.login = data.login
                self?.followers = data.followers
                self?.following = data.following
            }
        } catch {
            print(error)
        }
    }
}


//
//  HomeView.swift
//  GithubSearch
//
//  Created by Higashihara Yoki on 2021/11/01.
//

import SwiftUI

public struct HomeView: View {
    @StateObject private var vm: HomeViewModel = HomeViewModel()

    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("ID: \(vm.id)")
            Text("Login: \(vm.login)")
            Text("Followers: \(vm.followers)")
            Text("Following: \(vm.following)")
        }
        .onAppear {
            Task {
                await vm.fetchChrisInfo()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

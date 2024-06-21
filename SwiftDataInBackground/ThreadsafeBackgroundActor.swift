//
//  ThreadsafeBackgroundActor.swift
//  SwiftDataInBackground
//
//  Created by sam hastings on 12/06/2024.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@ModelActor
actor ThreadsafeBackgroundActor: Sendable { //ModelActor, Sendable {
    
    private var context: ModelContext { modelExecutor.modelContext }
    
    func persistUsers(_ numUsers: Int) {
        var newUsers = [User]()
        for i in 0..<numUsers { // Creates a lot of model objects!
            newUsers.append(User(name: "User \(i)"))
        }
        newUsers.forEach{ context.insert($0) }
        try? context.save()
        print("Data persisted")
    }
    
    func fetchData() async throws -> [UsersDTO] {
        let fetchDescriptor = FetchDescriptor<User>(sortBy: [SortDescriptor(\User.name)])
        let users: [User] = try context.fetch(fetchDescriptor)
        let userViewModels = users.map{UsersDTO(id: $0.id, name: $0.name)}
        return userViewModels
    }
    
    func fetchCount() async -> Int {
        let descriptor = FetchDescriptor<User>()
        let existingModelsCount = try? context.fetchCount(descriptor)
        return existingModelsCount ?? 0
    }
    
}


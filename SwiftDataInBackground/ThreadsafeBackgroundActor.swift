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
    
    //let modelContainer: ModelContainer // Provided automatically when actor annotated with @ModelActor
    //let modelExecutor: any ModelExecutor // Provided automatically when actor annotated with @ModelActor
    private var context: ModelContext { modelExecutor.modelContext }
    
    // The initiliazer is provided automatically when actor annotated with @ModelActor
//    init(modelContainer: ModelContainer) {
//        let modelContext = ModelContext(modelContainer)
//        self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
//        self.modelContainer = modelContainer
//    }
    
    func persist(_ models: [User]) {
        models.forEach{ context.insert($0) }
        try? context.save()
        print("Data persisted")
    }
    
    func fetchData(
        predicate: Predicate<User>? = nil,
        sortBy: [SortDescriptor<User>] = []
    ) async throws -> [User] {
        let fetchDescriptor = FetchDescriptor<User>(predicate: predicate, sortBy: sortBy)
        let list: [User] = try context.fetch(fetchDescriptor)
        return list
    }
    
    func fetchCount() async -> Int {
        let descriptor = FetchDescriptor<User>()
        let existingModelsCount = try? context.fetchCount(descriptor)
        return existingModelsCount ?? 0
    }
    
}


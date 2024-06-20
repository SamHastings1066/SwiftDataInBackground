//
//  ThreadsafeBackgroundDatabaseActor.swift
//  SwiftDataInBackground
//
//  Created by sam hastings on 12/06/2024.
//

import Foundation
import SwiftData

@available(iOS 17, *)
actor ThreadsafeBackgroundDatabaseActor: ModelActor, Sendable {
    
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    private var context: ModelContext { modelExecutor.modelContext }
    
    init(container: ModelContainer) {
        self.modelContainer = container
        let context = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }
    
    func persist(_ models: [User]) {
        models.forEach{ context.insert($0) }
        try? context.save()
    }
    
    func fetchData<T: PersistentModel>(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) async throws -> [T] {
        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        let list: [T] = try context.fetch(fetchDescriptor)
        return list
    }
    
    func fetchCount() async -> Int {
        let descriptor = FetchDescriptor<User>()
        let existingModelsCount = try? context.fetchCount(descriptor)
        return existingModelsCount ?? 0
    }
    
    func fetchBatch<T: PersistentModel>(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = [],
        limit: Int,
        offset: Int
    ) async throws -> [T] {
        var fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        fetchDescriptor.fetchLimit = limit
        fetchDescriptor.fetchOffset = offset
        let list: [T] = try context.fetch(fetchDescriptor)
        return list
    }
}


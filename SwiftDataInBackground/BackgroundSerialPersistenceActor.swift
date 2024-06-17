//
//  BackgroundSerialPersistenceActor.swift
//  SwiftDataInBackground
//
//  Created by sam hastings on 12/06/2024.
//

import Foundation
import SwiftData

@available(iOS 17, *)
public actor BackgroundSerialPersistenceActor: ModelActor {
    
    public let modelContainer: ModelContainer
    public let modelExecutor: any ModelExecutor
    private var context: ModelContext { modelExecutor.modelContext }
    
    public init(container: ModelContainer) {
        self.modelContainer = container
        let context = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }
    
    public func fetchData<T: PersistentModel>(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) async throws -> [T] {
        let fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        let list: [T] = try context.fetch(fetchDescriptor)
        return list
    }
}


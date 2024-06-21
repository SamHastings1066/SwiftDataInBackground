////
////  ContentView.swift
////  SwiftDataInBackground
////
////  Created by sam hastings on 12/06/2024.
////
//
//import SwiftUI
//import SwiftData
//
//struct ContentView: View {
//    let modelContainer: ModelContainer
//    
//    @Query private var models2: [User]
//    
//    @State private var models: [User] = []
//    //private var backgroundActor: ThreadsafeBackgroundActor
//
//    init(modelContainer: ModelContainer) {
//        self.modelContainer = modelContainer
//        //self.backgroundActor = ThreadsafeBackgroundDatabaseActor(container: modelContainer)
//    }
//    
//    var body: some View {
//        VStack {
//            Button("Background retrieval") {
//                Task(priority: .background) {
//                    // I think I need to create a ViewModel and make that sendable and then call this code from there. i.e.
//                    /* class ViewModel: Sendable {
//                     func backgroundFetch
//                     }
//                     then call it here with:
//                     try await viewModel.background fetcg
//                     Why?
//                     ContentView conforms to View protocol, and therefore is run on the MainActor.
//                     currently backgroundFetch is defined within the View and therefore is isolated to the Main Actor.
//                     Running this inside of a task means it can be run on a thread other than the main thread - unless ContentView is marked Sendable (and therefore is safe to share across actors) this could lead to data races.
//                    */
//                    models = try await backgroundFetch()
//                }
//            }
//            .buttonStyle(.bordered)
//            
//            Button("Background \"parallel\" batch retrieval") {
//                Task(priority: .background) {
//                    models = try await backgroundBatchFetch()
//                }
//            }
//            .buttonStyle(.bordered)
//            
//            Button("Background serial batch retrieval") {
//                backgroundSerialFetch()
//            }
//            .buttonStyle(.bordered)
//            
//            Button("Main thread retrieval") {
//                models = mainThreadFetch()
//            }
//            .buttonStyle(.bordered)
//
//            
//            Button("Clear results") {
//                models = []
//                print("Results cleared")
//                print(models2.count)
//            }
//            .buttonStyle(.bordered)
//            
//            List(models2){ model in
//                Text(model.name)
//            }
//            
////            List(users) { model in
////                Text(model.name)
////            }
//        }
//    }
//    
//    private func backgroundSerialFetch() {
//        Task(priority: .background) {
//            let backgroundActor = ThreadsafeBackgroundDatabaseActor(container: modelContainer)
//            do {
//                let batchSize = 1000
//                let totalCount = 10000
//                for offset in stride(from: 0, to: totalCount, by: batchSize) {
//                    let batch = try await backgroundActor.fetchBatch(limit: batchSize, offset: offset) as [User]
//                    models.append(contentsOf: batch)
//                }
//            } catch {
//                print("Error fetching data: \(error)")
//            }
//            
//        }
//    }
//    
//    private func backgroundBatchFetch() async throws -> [User] {
//        // Batch size and total count
//        let batchSize = 1000
//        let backgroundActor = ThreadsafeBackgroundDatabaseActor(container: modelContainer)
//        let totalCount = 10000
//        
//        let start = Date()
//        var results: [User] = []
//        
//        try await withThrowingTaskGroup(of: [User].self) { group in
//            for offset in stride(from: 0, to: totalCount, by: batchSize) {
//                group.addTask {
//                    try await backgroundActor.fetchBatch(limit: batchSize, offset: offset)
//                }
//            }
//            
//            for try await batch in group {
//                results.append(contentsOf: batch)
//            }
//        }
//        
//        print("Background batch fetch takes \(Date().timeIntervalSince(start))")
//        return results
//        
//    }
//    
//    private func backgroundFetch() async throws -> [User] {
//                let backgroundActor = ThreadsafeBackgroundDatabaseActor(container: modelContainer)
//                let start = Date()
//                let result = try await backgroundActor.fetchData() as [User]
//                print("Background fetch takes \(Date().timeIntervalSince(start))")
//                return result
//    }
//    
//    private func mainThreadFetch() -> [User] {
//        let context = ModelContext(modelContainer)
//        do {
//            let start = Date()
//            let result = try context.fetch(FetchDescriptor<User>())
//            print("Main thread fetch takes \(Date().timeIntervalSince(start))")
//            //print("Main thread fetch thread: \(Thread.current)")
//            return result
//        } catch {
//            print(error)
//            return []
//        }
//    }
//    
//}
//
//#Preview {
//    do {
//        let config = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try ModelContainer(for: User.self, configurations: config)
//        
//        // check we haven't already added the exercises
//        let descriptor = FetchDescriptor<User>()
//        let existingModels = try container.mainContext.fetchCount(descriptor)
//        guard existingModels == 0 else { return ContentView(modelContainer: container) }
//        
//        
//        
//        for i in 0..<10000 { // Create a LOT of model objects
//            let newModel = User(name: "User \(i)")
//            container.mainContext.insert(newModel)
//        }
//        print("DATABASE created")
//        return ContentView(modelContainer: container)
//    } catch {
//        fatalError("Failed to pre-seed database")
//    }
//    
//}

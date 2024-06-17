//
//  ContentView.swift
//  SwiftDataInBackground
//
//  Created by sam hastings on 12/06/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    let modelContainer: ModelContainer
    @State private var models: [MyModel] = []
    //private var backgroundActor: BackgroundSerialPersistenceActor

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        //self.backgroundActor = BackgroundSerialPersistenceActor(container: modelContainer)
    }
    
    var body: some View {
        VStack {
            Button("Background retrieval") {
                Task(priority: .background) {
                    models = []
                    models = try await backgroundFetch()
                }
            }
            .padding()
            
            Button("Main thread retrieval") {
                models = []
                models = mainThreadFetch()
            }
            .padding()
            
            Button("Nexx button") {
                print("Tapped")
            }
            .padding()
            
            List(models, id: \.id) { model in
                Text(model.name)
            }
        }
    }
    
    private func backgroundFetch() async throws -> [MyModel] {
        //try? await Task.sleep(nanoseconds: 3_000_000_000)
        let backgroundActor = BackgroundSerialPersistenceActor(container: modelContainer)
        let start = Date()
        let result = try await backgroundActor.fetchData() as [MyModel]
        print("Background fetch takes \(Date().timeIntervalSince(start))")
        return result
    }
    
    private func mainThreadFetch() -> [MyModel] {
        let context = ModelContext(modelContainer)
        do {
            let start = Date()
            let result = try context.fetch(FetchDescriptor<MyModel>())
            print("Main thread fetch takes \(Date().timeIntervalSince(start))")
            //print("Main thread fetch thread: \(Thread.current)")
            return result
        } catch {
            print(error)
            return []
        }
    }
    
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: MyModel.self, configurations: config)
        
        // check we haven't already added the exercises
        let descriptor = FetchDescriptor<MyModel>()
        let existingModels = try container.mainContext.fetchCount(descriptor)
        guard existingModels == 0 else { return ContentView(modelContainer: container) }
        
        
        
        for i in 0..<100000 { // Create a LOT of model objects
            let newModel = MyModel(name: "Model\(i)")
            container.mainContext.insert(newModel)
        }
        print("DATABASE created")
        return ContentView(modelContainer: container)
    } catch {
        fatalError("Failed to pre-seed database")
    }
    
}

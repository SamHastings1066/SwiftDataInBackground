//
//  SwiftDataInBackgroundApp.swift
//  SwiftDataInBackground
//
//  Created by sam hastings on 12/06/2024.
//

import SwiftUI
import SwiftData

@main
struct SwiftDataInBackgroundApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: MyModel.self)
            
            // check we haven't already added the exercises
            let descriptor = FetchDescriptor<MyModel>()
            let existingModels = try container.mainContext.fetchCount(descriptor)
            guard existingModels == 0 else { return }
            
            
            
            for i in 0..<100 {
                let newModel = MyModel(name: "Model\(i)")
                container.mainContext.insert(newModel)
            }
            print("DATABASE created")
        } catch {
            fatalError("Failed to pre-seed database")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(modelContainer: container)
        }
    }
}

//
//  QueryMacroNameView.swift
//  SwiftDataInBackground
//
//  Created by sam hastings on 19/06/2024.
//

import SwiftUI
import SwiftData

struct QueryMacroNameView: View {
    @Environment(\.modelContext) private var context
    @Query private var models: [User]
    
    
    
    var body: some View {
        List(models) { model in
            Text(model.name)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, configurations: config)
        
        // check we haven't already added the exercises
        let descriptor = FetchDescriptor<User>()
        let existingModels = try container.mainContext.fetchCount(descriptor)
        guard existingModels == 0 else { return QueryMacroNameView().modelContainer(container) }
        
        
        
        for i in 0..<100000 { // Create a LOT of model objects
            let newModel = User(name: "User \(i)")
            container.mainContext.insert(newModel)
        }
        print("DATABASE created")
        return QueryMacroNameView().modelContainer(container)
    } catch {
        fatalError("Failed to pre-seed database")
    }
    
}

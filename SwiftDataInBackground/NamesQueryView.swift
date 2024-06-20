//
//  NamesQueryView.swift
//  SwiftDataInBackground
//
//  Created by sam hastings on 19/06/2024.
//

import SwiftUI

//
//  ContentView.swift
//  SwiftDataInBackground
//
//  Created by sam hastings on 12/06/2024.
//

import SwiftUI
import SwiftData

@Observable
final class NamesQueryViewViewModel: Sendable { // N.B. must be Sendable to let the Swift compiler know that it is safe to share the view model across model contexts.
    
    
    let modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    func backgroundFetch() async throws -> [User] {
        let backgroundActor = BackgroundSerialPersistenceActor(container: modelContainer) // N.B. backgroundActor must be created within an async context off the main actor, or else its associated model context will be on the main actor and any work done will be done on the main thread
        let start = Date()
        let result = try await backgroundActor.fetchData() as [User]
        print("Background fetch takes \(Date().timeIntervalSince(start))")
        return result
    }
    
    func createDatabase() async {
        let backgroundActor = BackgroundSerialPersistenceActor(container: modelContainer)
        let existingUsersCount = await backgroundActor.fetchCount()
        guard existingUsersCount == 0 else {
            return
        }
        var newUsers = [User]()
        for i in 0..<10000 { // Create a LOT of model objects
            newUsers.append(User(name: "User \(i)"))
        }
        await backgroundActor.persist(newUsers)
    }
    
}

struct NamesQueryView: View {
    let modelContainer: ModelContainer
    @State var isCreatingDatabase = true
    @State var isFetchingUsers = false
    @State private var users: [User] = []
    var viewModel: NamesQueryViewViewModel
    
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        viewModel = NamesQueryViewViewModel(modelContainer: modelContainer)
    }
    
    var body: some View {
        VStack {
            if isCreatingDatabase {
                ProgressView("Creating database")
            } else {
                Button("Background retrieval") {
                    isFetchingUsers = true
                    Task(priority: .background) {
                        users = try await viewModel.backgroundFetch()
                        isFetchingUsers = false
                    }
                }
                .buttonStyle(.bordered)
                
                
                Button("Tapped") {
                    print("tapped")
                }
                .buttonStyle(.bordered)
                
                if isFetchingUsers {
                    List {
                        Text("Fetching users...")
                    }
                } else {
                    if users.count == 0 {
                        ContentUnavailableView("No Users fetched", systemImage: "person.crop.circle.badge.exclamationmark")
                    } else {
                        List(users) { model in
                            Text(model.name)
                        }
                    }
                }
            }
        }
        .task(priority: .background) {
            await viewModel.createDatabase()
            isCreatingDatabase = false
            print(isCreatingDatabase)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, configurations: config)
        return NamesQueryView(modelContainer: container)
    } catch {
        fatalError("Failed to pre-seed database")
    }
    
}


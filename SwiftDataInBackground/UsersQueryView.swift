//
//  UsersQueryView.swift
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
final class UsersQueryViewViewModel: Sendable { // Must be Sendable to let the Swift compiler know that it is safe to share the view model across model contexts.
    
    
    let modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    func backgroundFetch() async throws -> [User] {
        let backgroundActor = ThreadsafeBackgroundDatabaseActor(container: modelContainer) // backgroundActor must be created within an async context off the main actor, or else its associated model context will be on the main actor and any work done will be done on the main thread.
        let start = Date()
        let sortDescriptor = [SortDescriptor(\User.name)]
        let result = try await backgroundActor.fetchData(sortBy: sortDescriptor)
        print("Background fetch takes \(Date().timeIntervalSince(start))")
        return result
    }
    
    func createDatabase() async {
        let backgroundActor = ThreadsafeBackgroundDatabaseActor(container: modelContainer)
        let existingUsersCount = await backgroundActor.fetchCount()
        guard existingUsersCount == 0 else {
            print("User models already exists")
            return
        }
        var newUsers = [User]()
        for i in 0..<10000 { // Creates a lot of model objects!
            newUsers.append(User(name: "User \(i)"))
        }
        await backgroundActor.persist(newUsers)
    }
    
}

struct UsersQueryView: View {
    let modelContainer: ModelContainer
    @State var isCreatingDatabase = true
    @State var isFetchingUsers = false
    @State private var users: [User] = []
    var viewModel: UsersQueryViewViewModel
    
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        viewModel = UsersQueryViewViewModel(modelContainer: modelContainer)
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
                
                Button("Main thread retrieval") {
                    users = mainThreadFetch()
                }
                .buttonStyle(.bordered)
                
                Button("Check UI responsive") {
                    print("Responsive!")
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
        }
    }
    
    private func mainThreadFetch() -> [User] {
        let context = ModelContext(modelContainer)
        do {
            let start = Date()
            let result = try context.fetch(FetchDescriptor<User>(sortBy: [SortDescriptor(\User.name)]))
            print("Main thread fetch takes \(Date().timeIntervalSince(start))")
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
        let container = try ModelContainer(for: User.self, configurations: config)
        return UsersQueryView(modelContainer: container)
    } catch {
        fatalError("Failed to create container")
    }
    
}

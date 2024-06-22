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
final class UsersQueryViewModel: Sendable { // Must be Sendable to let the Swift compiler know that it is safe to share the view model across contexts.
    
    
    let modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    func backgroundFetch() async throws -> [UserDTO] {
        let backgroundActor = ThreadsafeBackgroundActor(modelContainer: modelContainer) // backgroundActor must be created within an async context off the main actor, or else its associated model context will be on the main actor and any work done will be done on the main thread.
        let start = Date()
        let result = try await backgroundActor.fetchData()
        print("Background fetch takes \(Date().timeIntervalSince(start))")
        return result
    }
    
    func createDatabase() async {
        let backgroundActor = ThreadsafeBackgroundActor(modelContainer: modelContainer)
        let existingUsersCount = await backgroundActor.fetchCount()
        guard existingUsersCount == 0 else {
            print("User models already exists")
            return
        }
        await backgroundActor.persistUsers(10000)
    }
    
}

struct UsersQueryView: View {
    let modelContainer: ModelContainer
    @State var isCreatingDatabase = true
    @State var isFetchingUsers = false
    @State private var users: [UserDTO] = []
    var viewModel: UsersQueryViewModel
    
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        viewModel = UsersQueryViewModel(modelContainer: modelContainer)
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
    
    private func mainThreadFetch() -> [UserDTO] {
        let context = ModelContext(modelContainer)
        do {
            let start = Date()
            let result = try context.fetch(FetchDescriptor<User>(sortBy: [SortDescriptor(\User.name)]))
            print("Main thread fetch takes \(Date().timeIntervalSince(start))")
            return result.map{UserDTO(id: $0.id, name: $0.name)}
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


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
            container = try ModelContainer(for: User.self)
        } catch {
            fatalError("Failed to create container")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            UsersQueryView(modelContainer: container)
        }
    }
}

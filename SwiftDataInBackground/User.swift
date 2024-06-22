//
//  MyModel.swift
//  SwiftDataInBackground
//
//  Created by sam hastings on 12/06/2024.
//

import Foundation
import SwiftData

@Model
class User {
    let id: UUID
    let name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

/// Creates User Data Transfer Objects
final class UserDTO: Sendable, Identifiable {
    let id: UUID
    let name: String
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}

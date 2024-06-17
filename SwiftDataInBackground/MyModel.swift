//
//  MyModel.swift
//  SwiftDataInBackground
//
//  Created by sam hastings on 12/06/2024.
//

import Foundation
import SwiftData

@Model
class MyModel {
    var id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}


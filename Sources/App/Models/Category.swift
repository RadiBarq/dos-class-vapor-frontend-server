//
//  Category.swift
//  App
//
//  Created by Harri on 2/8/20.
//

import FluentSQLite
import Vapor

/// Category
final class Category {
 
    // Id
    var id: Int?
    
    // Title
    var title: String
    
    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Category: Content {}

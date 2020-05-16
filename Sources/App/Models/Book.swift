//
//  Book.swift
//  App
//
//  Created by Harri on 2/9/20.
//

import Vapor
import FluentSQLite

/// Book
final class Book {
    
    /// book Id
    var id: Int?
    
    /// Book title
    var title: String
    
    /// Book category
    var category: String
    
    /// Book price
    var price: Int
    
    /// Book number of items
    var numberOfItems: Int
    
    /// Creates a new 'Book'
    init(id: Int? = nil, title: String, category: String, price: Int, numberOfItems: Int) {
        self.id = id
        self.title = title
        self.category = category
        self.price = price
        self.numberOfItems = numberOfItems
    }
}

/// Allows `Book` to be encoded to and decoded from HTTP messages.
extension Book: Content {}

/// Allow  `Book` to be a SQLite database model.
extension Book: SQLiteModel {}

/// Allow `Book` to be migrated with the mogration process.
extension Book: Migration {}

/// Allow `Book` to be used as a router parameter.
extension Book: Parameter {}

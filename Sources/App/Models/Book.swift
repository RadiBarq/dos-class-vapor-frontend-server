//
//  Book.swift
//  App
//
//  Created by Harri on 2/8/20.
//

import FluentSQLite
import Vapor

/// Book
final class Book {
    
    /// id
    var id: Int?
    
    /// Title
    var title: String
    
    /// Category
    var category: Category
    
    /// Price
    var price: Int?
    
    /// Number of items
    var numberOfItems: Int?
    
    /// Creates a new 'Book'
    init(id: Int? = nil, title: String, category: Category, price: Int? = nil, numberOfItems: Int? = nil) {
        self.id = id
        self.title = title
        self.category = category
        self.price = price
        self.numberOfItems = numberOfItems
    }
}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Book: Content {}

//
//  Book.swift
//  App
//
//  Created by Harri on 2/9/20.
//

import Vapor

/// Book
final class Book {
    
    /// id
    var id: Int?
    
    /// Title
    var title: String
    
    /// Category
    var category: String
    
    /// Price
    var price: Int
    
    /// Number of items
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

//
//  RequestCache.swift
//  App
//
//  Created by Harri on 5/15/20.
//

import Vapor
import FluentSQLite

/// RequestCache
final class RequestCache {
    
    /// Id
    var id: Int?
    
    /// Book
    var book: Book
    
    /// Valid
    var valid: Bool
    
    /// Create new request cahce object
    init(id: Int? = nil, book: Book, valid: Bool) {
        self.id = id
        self.book = book
        self.valid = valid
    }
}


/// Allows `RequestCahce` to be encoded to and decoded from HTTP messages.
extension RequestCache: Content {}

/// Allow  `Book` to be a SQLite database model.
extension RequestCache: SQLiteModel {}

/// Allow `Book` to be migrated with the mogration process.
extension RequestCache: Migration {}

/// Allow `Book` to be used as a router parameter.
extension RequestCache: Parameter {}

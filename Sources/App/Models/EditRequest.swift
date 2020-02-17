//
//  EditRequest.swift
//  App
//
//  Created by Harri on 2/13/20.
//

import Vapor

/// Edit Request.
final class EditRequest {
    
    /// Book id.
    let id: Int
    
    /// Numbe of items of specific book.
    let numberOfItems: Int
    
    /// Book price
    let price: Int
    
    /// Create `EditRequest`.
    init(numberOfItems: Int, price: Int, id: Int) {
        self.id = id
        self.numberOfItems = numberOfItems
        self.price = price
    }
}

/// Allows `EditRequest` to be encoded to and decoded from HTTP messages.
extension EditRequest: Content {}




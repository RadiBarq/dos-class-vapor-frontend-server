//
//  EditResponse.swift
//  App
//
//  Created by Harri on 2/13/20.
//

import Vapor

/// Edit Response.
final class EditResponse {
    
    /// The edited book.
    let book: Book

    /// Create `EditResponse`.
    init(book: Book) {
        self.book = book
    }
}
/// Allows `EditRequest` to be encoded to and decoded from HTTP messages.
extension EditResponse: Content {}



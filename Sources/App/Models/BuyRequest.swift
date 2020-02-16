//
//  BuyRequest.swift
//  App
//
//  Created by Harri on 2/10/20.
//

import Vapor

final class BuyRequest {
    /// Book id
    let bookId: Int

    /// Create `BuyRequest`
    init(bookId: Int) {
        self.bookId = bookId
    }
}

/// Allows `BuyRequest` to be encoded to and decoded from HTTP messages.
extension BuyRequest: Content {}

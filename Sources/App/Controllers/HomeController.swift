//
//  WebsiteController.swift
//  App
//
//  Created by Harri on 2/8/20.
//

import Vapor
import Leaf

/// Home Controller
struct HomeController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(use: homePage)
        router.get("lookup", use: lookupPage)
        router.get("buy", use: buyPage)
        router.get("search", use: searchBook)
        router.get("lookupBook", use: lookupBook)
        router.get("edit", Int.parameter, use: editPage)
        router.post("buyBook", use: buyBook)
        router.post("edit", Int.parameter, use: editBook)
    }
    
    func homePage(_ req: Request) throws -> Future<View> {
        let context = SearchContext(websiteTitle: "Search Books", books: nil)
        return try req.view().render("search", context)
    }
    
    func lookupPage(_ req: Request) throws -> Future<View> {
        let context = LookupContext(websiteTitle: "Lookup Books", book: nil, initialOpen: true)
        return try req.view().render("lookup", context)
    }
    
    func buyPage(_ req: Request) throws -> Future<View> {
        let context = BuyContext(websiteTitle: "Buy Books", buyResponse: BuyResponse(success: false) , initialOpen: true)
        return try req.view().render("buy", context)
    }

    func editPage(_ req: Request) throws -> Future<View> {
        let bookId = try req.parameters.next(Int.self)
        let context = EditContext(websiteTitle: "Edit Book", bookId: bookId, book: nil)
        return try req.view().render("edit", context)
    }
    func searchBook(_ req: Request) throws -> Future<View> {
        guard let searchCategory = req.query[String.self, at: "category"] else {
            throw Abort(.badRequest)
        }
        let headers: HTTPHeaders = HTTPHeaders([("Content-Type", "application/json")])
        let checkAvailableRequest = HTTPRequest(
            method: .GET,
            url: URL(string: "/books/search?category=" + (searchCategory.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))!,
            headers: headers
        )
        let client = HTTPClient.connect(hostname: "40.68.168.196", port: 80, on: req)
        return client.flatMap(to: View.self) { client in
            return client.send(checkAvailableRequest).flatMap(to: [Book].self) { response in
                let decoder = JSONDecoder()
                let books = try decoder.decode([Book].self, from: response.body.data!)
                return req.future(books)
            }.flatMap(to: View.self) { books in
                let context = SearchContext(websiteTitle: "Search Books", books: books)
                return try req.view().render("search", context)
            }
        }
    }
    
    func lookupBook(_ req: Request) throws -> Future<View> {
        guard let bookId = req.query[String.self, at: "id"] else {
            throw Abort(.badRequest)
        }
        let headers: HTTPHeaders = HTTPHeaders([("Content-Type", "application/json")])
        let checkAvailableRequest = HTTPRequest(
            method: .GET,
            url: URL(string: "/books/" + bookId)!,
            headers: headers
        )
        let client = HTTPClient.connect(hostname: "40.68.168.196", port: 80, on: req)
        return client.flatMap(to: View.self) { client in
            return client.send(checkAvailableRequest).flatMap(to: View.self) { response in
                if response.status == .notFound {
                    let context = LookupContext(websiteTitle: "Lookup Books", book: nil, initialOpen: false)
                    return try req.view().render("lookup", context)
                } else {
                    let decoder = JSONDecoder()
                    let book = try decoder.decode(Book.self, from: response.body.data!)
                    return req.future(book).flatMap(to: View.self) { book in
                        let context = LookupContext(websiteTitle: "Lookup Books", book: book, initialOpen: false)
                        return try req.view().render("lookup", context)
                    }
                }
            }
        }
    }
    
    func buyBook(_ req: Request) throws -> Future<View> {
        return try req.content.decode(BuyRequest.self).flatMap(to: View.self) { buyRequest in
            let headers: HTTPHeaders = HTTPHeaders([("Content-Type", "application/json")])
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(buyRequest)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            let buyBookRequest = HTTPRequest(
                method: .POST,
                url: URL(string: "/books/buy")!,
                headers: headers,
                body: HTTPBody(string: jsonString)
                )
            let client = HTTPClient.connect(hostname: "13.94.233.209", port: 80, on: req)
            return client.flatMap(to: BuyResponse.self) { client in
                return client.send(buyBookRequest).flatMap(to: BuyResponse.self) { response in
                    let decoder = JSONDecoder()
                    let buyResponse = try decoder.decode(BuyResponse.self, from: response.body.data!)
                    return req.future(buyResponse)
                }
            }.flatMap(to: View.self) { buyRespponse in
                let buyContext = BuyContext(websiteTitle: "Buy Books", buyResponse: buyRespponse, initialOpen: false)
                return try req.view().render("buy", buyContext)
            }
        }
    }
    
    func editBook(_ req: Request) throws -> Future<View> {
        return try req.content.decode(EditRequest.self).map(to: EditRequest.self) { editRequest in
            return editRequest
        }.flatMap(to: Book.self) { editRequest in
            let bookId = try req.parameters.next(Int.self)
            let book = Book(id: bookId, title: "", category: "", price: editRequest.price, numberOfItems: editRequest.numberOfItems)
            let encoder = JSONEncoder()
            let headers: HTTPHeaders = HTTPHeaders([("Content-Type", "application/json")])
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(book)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            let editBookRequest = HTTPRequest(
            method: .PUT,
            url: URL(string: "/books/\(bookId)")!,
            headers: headers,
            body: HTTPBody(string: jsonString))
            let client = HTTPClient.connect(hostname: "40.68.168.196", port: 80, on: req)
            return client.flatMap(to: Book.self) { client in
                return client.send(editBookRequest).flatMap(to: Book.self) { response in
                    let decoder = JSONDecoder()
                    return req.future(try decoder.decode(Book.self, from: response.body.data!))
                }
            }
        }.flatMap(to: View.self) { book in
            let editContext = EditContext(websiteTitle: "Edit Book", bookId: book.id ?? 0, book: book)
            return try req.view().render("edit", editContext)
        }
    }
}

struct SearchContext: Encodable {
    let websiteTitle: String
    let books: [Book]?
}

struct LookupContext: Encodable {
    let websiteTitle: String
    let book: Book?
    let initialOpen: Bool
}

struct BuyContext: Encodable {
    let websiteTitle: String
    let buyResponse: BuyResponse
    let initialOpen: Bool
}

struct EditContext: Encodable {
    let websiteTitle: String
    let bookId: Int
    let book: Book?
}

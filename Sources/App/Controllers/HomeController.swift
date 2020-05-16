//
//  WebsiteController.swift
//  App
//
//  Created by Harri on 2/8/20.
//

import Vapor
import Leaf

/// Home Controller.
struct HomeController: RouteCollection {
    
    let orderServerIps = ["localhost", "localhost"]
    let orderServerPorts = [8080, 8200]
    
    let catalogServerIps = ["localhost", "localhost"]
    let catalogServerPorts = [8100,  8210]
    
    /// Registers routes to the incoming router.
    ///
    /// - parameters:
    ///     - router: `Router` to register any new routes to.
    /// - returns: rendered web page.
    func boot(router: Router) throws {
        router.get(use: homeWebPage)
        router.get("lookup", use: lookupWebPage)
        router.get("buy", use: buyWebPage)
        router.get("search", use: searchBooks)
        router.get("lookupBook", use: lookupBook)
        router.get("edit", Int.parameter, use: editWebPage)
        router.post("buyBook", use: buyBook)
        router.post("edit", Int.parameter, use: editBook)
        router.delete("invalidateBook", Int.parameter, use: invalidate)
    }
    
    /// Listen to home web page `GET` requests.
    ///
    /// - parameters:
    ///     - req: `Request` the upcoming request sent.
    /// - returns: rendered web page.
    func homeWebPage(_ req: Request) throws -> Future<View> {
        let context = SearchBooksContext(title: "Search Books", books: nil)
        return try req.view().render("search", context)
    }
    
    /// Listen to lookup web page `GET` requests.
    ///
    /// - parameters:
    ///     - req: `Request` the upcoming request sent.
    /// - returns: rendered web page.
    func lookupWebPage(_ req: Request) throws -> Future<View> {
        let context = LookupBookContext(title: "Lookup Books", book: nil, initialOpen: true)
        return try req.view().render("lookup", context)
    }
    
    /// Listen to buy web page `GET` requests.
    ///
    /// - parameters:
    ///     - req: `Request` the upcoming request sent.
    func buyWebPage(_ req: Request) throws -> Future<View> {
        let context = BuyBookContext(title: "Buy Books", buyResponse: BuyResponse(success: false) , initialOpen: true)
        return try req.view().render("buy", context)
    }
    
    /// Listen to edit web page `GET` requests.
    ///
    /// - parameters:
    ///     - req: `Request` the upcoming request sent.
    /// - returns: rendered web page.
    func editWebPage(_ req: Request) throws -> Future<View> {
        let bookId = try req.parameters.next(Int.self)
        let context = EditBookContext(title: "Edit Book", bookId: bookId, book: nil)
        return try req.view().render("edit", context)
    }
    
    /// Listen to lookup books `GET` requests.
    ///
    /// - parameters:
    ///     - req: `Request` the upcoming request sent.
    /// - returns: rendered web page.
    func searchBooks(_ req: Request) throws -> Future<View> {
        guard let searchCategory = req.query[String.self, at: "category"] else {
            throw Abort(.badRequest)
        }
        let headers: HTTPHeaders = HTTPHeaders([("Content-Type", "application/json")])
        let checkAvailableRequest = HTTPRequest(
            method: .GET,
            url: URL(string: "/books/search?category=" + (searchCategory.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))!,
            headers: headers
        )
        let serverTurn = RoundRobinScheduler.getCatalogServerTurn()
        let client = HTTPClient.connect(hostname: self.catalogServerIps[serverTurn], port: self.catalogServerPorts[serverTurn], on: req)
        return client.flatMap(to: View.self) { client in
            return client.send(checkAvailableRequest).flatMap(to: [Book].self) { response in
                let decoder = JSONDecoder()
                let books = try decoder.decode([Book].self, from: response.body.data!)
                return req.future(books)
            }.flatMap(to: View.self) { books in
                let context = SearchBooksContext(title: "Search Books", books: books)
                return try req.view().render("search", context)
            }
        }
    }
    
    /// Listen to look up book `GET` requests.
    ///
    /// - parameters:
    ///     - req: `Request` the upcoming request sent.
    /// - returns: rendered web page.
    func lookupBook(_ req: Request) throws -> Future<View> {
        guard let bookId = req.query[String.self, at: "id"] else {
            throw Abort(.badRequest)
        }
        
        return RequestCache.find(Int(bookId)!, on: req).flatMap(to: View.self) { respone in
            if let cachedRequest = respone, cachedRequest.valid {
                let context = LookupBookContext(title: "Lookup Books", book: cachedRequest.book, initialOpen: false)
                return try req.view().render("lookup", context)
            } else {
                let headers: HTTPHeaders = HTTPHeaders([("Content-Type", "application/json")])
                let checkAvailableRequest = HTTPRequest(
                    method: .GET,
                    url: URL(string: "/books/" + bookId)!,
                    headers: headers
                )
                let serverTurn = RoundRobinScheduler.getCatalogServerTurn()
                let client = HTTPClient.connect(hostname: self.catalogServerIps[serverTurn], port: self.catalogServerPorts[serverTurn], on: req)
                return client.flatMap(to: View.self) { client in
                    return client.send(checkAvailableRequest).flatMap(to: View.self) { response in
                        if response.status == .notFound {
                            let context = LookupBookContext(title: "Lookup Books", book: nil, initialOpen: false)
                            return try req.view().render("lookup", context)
                        } else {
                            let decoder = JSONDecoder()
                            let book = try decoder.decode(Book.self, from: response.body.data!)
                            let requestCache = RequestCache(id: book.id, book: book, valid: true)
                            return requestCache.create(on: req).flatMap(to: View.self) { savedBook in
                                return req.future(book).flatMap(to: View.self) { book in
                                    let context = LookupBookContext(title: "Lookup Books", book: book, initialOpen: false)
                                    return try req.view().render("lookup", context)
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    /// Listen to buy book `POST` requests.
    ///
    /// - parameters:
    ///     - req: `Request` the upcoming request sent.
    /// - returns: rendered web page.
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
            
            let serverTurn = RoundRobinScheduler.getOrderServerTurn()
            
            let client = HTTPClient.connect(hostname: self.orderServerIps[serverTurn], port: self.orderServerPorts[serverTurn], on: req)
            return client.flatMap(to: BuyResponse.self) { client in
                return client.send(buyBookRequest).flatMap(to: BuyResponse.self) { response in
                    let decoder = JSONDecoder()
                    let buyResponse = try decoder.decode(BuyResponse.self, from: response.body.data!)
                    return req.future(buyResponse)
                }
            }.flatMap(to: View.self) { buyRespponse in
                let buyContext = BuyBookContext(title: "Buy Books", buyResponse: buyRespponse, initialOpen: false)
                return try req.view().render("buy", buyContext)
            }
        }
    }
    
    /// Listen to edit book `POST` requests.
    ///
    /// - parameters:
    ///     - req: `Request` the upcoming request sent.
    /// - returns: rendered web page.
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
            let serverTurn = RoundRobinScheduler.getCatalogServerTurn()
            let client = HTTPClient.connect(hostname: self.catalogServerIps[serverTurn], port: self.catalogServerPorts[serverTurn], on: req)
            return client.flatMap(to: Book.self) { client in
                return client.send(editBookRequest).flatMap(to: Book.self) { response in
                    let decoder = JSONDecoder()
                    return req.future(try decoder.decode(Book.self, from: response.body.data!))
                }
            }
        }.flatMap(to: View.self) { book in
            let editContext = EditBookContext(title: "Edit Book", bookId: book.id ?? 0, book: book)
            return try req.view().render("edit", editContext)
        }
    }
    
    /// Listen to invalidate `DELETE` requests.
    ///
    /// - parameters:
    ///     - req: `Request` the upcoming request sent.
    /// - returns: nothing
    func invalidate(req: Request) throws -> Future<HTTPStatus> {
             let bookId = try req.parameters.next(Int.self)
        return RequestCache.find(bookId, on: req).flatMap(to: HTTPStatus.self) { requestCache in
            guard let requestCache = requestCache else {
                return req.future(HTTPStatus.badRequest)
            }
            return requestCache.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
}

/// Search Books Web Page Content.
struct SearchBooksContext: Encodable {
    
    /// Page title.
    let title: String
    
    /// Book to show inside the web page when the user search for the book.
    let books: [Book]?
}

/// Lookup Book Web Page Content.
struct LookupBookContext: Encodable {
    
    /// Web page title.
    let title: String
    
    /// Book to show inside the web page.
    let book: Book?
    
    /// To indicate the initial state of the page when the user first open the web page.
    let initialOpen: Bool
}

/// Buy Book Web Page Content.
struct BuyBookContext: Encodable {
    
    /// Page Title.
    let title: String
    
    /// Buy Response.
    let buyResponse: BuyResponse
    
    /// To indicate the initial state of the page when the user first open the web page.
    let initialOpen: Bool
}

/// Edit Book Web Page Content.
struct EditBookContext: Encodable {
    
    /// Page Title.
    let title: String
    
    /// The unique id of the book.
    let bookId: Int
    
    /// The book to show inside the web page.
    let book: Book?
}

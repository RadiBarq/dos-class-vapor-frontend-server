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
        router.get(use: searchHandler)
        router.get("lookup", use: lookupHandler)
        router.get("buy", use: buyHandler)
    }
    
    func searchHandler(_ req: Request) throws -> Future<View> {
        let technologyCategory = Category(id: 20, title: "technology")
        let novelCategory = Category(id: 30, title: "novles")
        let technologyBook = Book(id: 20, title: "programming for dummies", category: technologyCategory)
        let novelBook = Book(id: 30, title: "novels for dummies", category: novelCategory)
        var books = [Book]()
        books.append(technologyBook)
        books.append(novelBook)
        books.append(technologyBook)
        books.append(novelBook)
        books.append(technologyBook)
        books.append(novelBook)
        let context = SearchContext(websiteTitle: "Search Books", books: books)
        return try req.view().render("search", context)
    }
    
    func lookupHandler(_ req: Request) throws -> Future<View> {
        let technologyCategory = Category(id: 20, title: "technology")
        let novelCategory = Category(id: 30, title: "novles")
        let technologyBook = Book(id: 20, title: "programming for dummies", category: technologyCategory)
        let novelBook = Book(id: 30, title: "novels for dummies", category: novelCategory)
        var books = [Book]()
        books.append(technologyBook)
        books.append(novelBook)
        books.append(technologyBook)
        books.append(novelBook)
        books.append(technologyBook)
        books.append(novelBook)
        let context = SearchContext(websiteTitle: "Lookup Books", books: books)
        return try req.view().render("lookup", context)
    }
    
   func buyHandler(_ req: Request) throws -> Future<View> {
       let technologyCategory = Category(id: 20, title: "technology")
       let novelCategory = Category(id: 30, title: "novles")
       let technologyBook = Book(id: 20, title: "programming for dummies", category: technologyCategory)
       let novelBook = Book(id: 30, title: "novels for dummies", category: novelCategory)
       var books = [Book]()
       books.append(technologyBook)
       books.append(novelBook)
       books.append(technologyBook)
       books.append(novelBook)
       books.append(technologyBook)
       books.append(novelBook)
       let context = SearchContext(websiteTitle: "Buy Books", books: books)
       return try req.view().render("buy", context)
   }
}

struct SearchContext: Encodable {
    let websiteTitle: String
    let books: [Book]?
}

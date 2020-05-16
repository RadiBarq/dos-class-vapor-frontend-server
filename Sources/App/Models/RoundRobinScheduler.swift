//
//  RoundRobinScheduler.swift
//  App
//
//  Created by Harri on 5/15/20.
//

import Foundation

/// Round Robin Scheduler
struct RoundRobinScheduler {
    
    /// Order Server Turn
    static var orderServerTurn = 0
    
    /// Catalog Server Turn
    static var catalogServerTurn = 0

    /// return the turn of the order server
    ///
    ///
    /// - returns: the turn of the order server 0, 1
    static func getOrderServerTurn() -> Int {
        let prevTurn = orderServerTurn
        orderServerTurn = (orderServerTurn + 1) % 2
        return prevTurn
    }

    /// return the turn of the order server
    ///
    ///
    /// - returns: the turn of the catalog server 0, 1
    static func getCatalogServerTurn() -> Int {
        let prevTurn = catalogServerTurn
        catalogServerTurn = (catalogServerTurn + 1) % 2
        return prevTurn
    }
}

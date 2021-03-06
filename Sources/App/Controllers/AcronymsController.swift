//
//  AcronymsController.swift
//  App
//

import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let acronymsRoutes = router.grouped("api", "acronyms")
        // POST /api/acronyms
        acronymsRoutes.post(use: createHandler)
        // GET /api/acronyms
        acronymsRoutes.get(Acronym.parameter, use: getHandler)
        // PUT /api/acronyms/:id
        acronymsRoutes.put(Acronym.parameter, use: updateHandler)
        // DELETE /api/acronyms/:id
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)
        // GET /api/acronyms/search
        acronymsRoutes.get("search", use: searchHandler)
        // GET First
        acronymsRoutes.get("first", use: getFirstHandler)
        // GET Sorted
        acronymsRoutes.get("sorted", use: sortedHandler)
        // GET User
        acronymsRoutes.get(Acronym.parameter, "user", use: getUserHandler)
        
        acronymsRoutes.get(Acronym.parameter, "categories", use: getCategoriesHandler)

    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    func createHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.content
            .decode(Acronym.self)
            .flatMap(to: Acronym.self) { acronym in
                return acronym.save(on: req)
        }
    }
    
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)) {
                            acronym, updatedAcronym in
                            acronym.short = updatedAcronym.short
                            acronym.long = updatedAcronym.long
                            acronym.userID = updatedAcronym.userID
                            return acronym.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request)
        throws -> Future<HTTPStatus> {
            
            return try req.parameters
                .next(Acronym.self)
                .delete(on: req)
                .transform(to: HTTPStatus.noContent)
    }
    
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self,
                                         at: "term"] else {
                                            throw Abort(.badRequest)
        }
        return try Acronym.query(on: req).group(.or) { or in
            try or.filter(\.short == searchTerm)
            try or.filter(\.long == searchTerm)
            }.all()
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req).first().map(to: Acronym.self) {
            acronym in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            return acronym
        }
    }
    
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self)
            .flatMap(to: User.self) { acronym in
                try acronym.user.get(on: req)
        }
    }
    
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self)
            .flatMap(to: [Category].self) { acronym in
                try acronym.categories.query(on: req).all()
        }
    }
}

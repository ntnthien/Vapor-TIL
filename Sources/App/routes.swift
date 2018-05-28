import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    // POST /api/acronyms
    router.post("api", "acronyms") { (req) -> Future<Acronym> in
        return try req.content.decode(Acronym.self)
            .flatMap(to: Acronym.self, { (acronym) in
                return acronym.save(on: req)
            })
    }
    
    // GET /api/acronyms
    router.get("api", "acronyms") { req -> Future<[Acronym]> in
        return try Acronym.query(on: req).all()
    }
    
    // GET /api/acronyms/:id
    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    // PUT /api/acronyms/:id
    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, updatedAcronym in
            
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            
            return acronym.save(on: req)
        }
    }
    
    // DELETE /api/acronyms/:id
    router.delete("api", "acronyms", Acronym.parameter) {
        req -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    // Search
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return try Acronym.query(on: req)
            .group(.or) { or in
                try or.filter(\.short == searchTerm)
                try or.filter(\.long == searchTerm)
                }.all()
    }
}

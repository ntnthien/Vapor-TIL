import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    // Acronyms
    let acronymsController = AcronymsController()
    try router.register(collection: acronymsController)
    
    // User
    let usersController = UsersController()
    try router.register(collection: usersController)
    
    let websiteController = WebsiteController()
    try router.register(collection: websiteController)

}

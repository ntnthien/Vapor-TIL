import Vapor
import Leaf

struct WebsiteController: RouteCollection {

    struct IndexContext: Encodable {
        let title: String
        let acronyms: [Acronym]?
    }
    
    struct AcronymContext: Encodable {
        let title: String
        let acronym: Acronym
        let user: User
    }
    
    struct UserContext: Encodable {
        let title: String
        let user: User
        let acronyms: [Acronym]
    }
    
    struct AllUsersContext: Encodable {
        let title: String
        let users: [User]
    }
    
    struct AllCategoriesContext: Encodable {
        let title = "All Categories"
        let categories: Future<[Category]>
    }
    
    struct CategoryContext: Encodable {
        // 1
        let title: String
        // 2
        let category: Category
        // 3
        let acronyms: Future<[Acronym]>
    }
    
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get("acronyms", Acronym.parameter, use: acronymHandler)
        router.get("users", User.parameter, use: userHandler)
        router.get("users", use: allUsersHandler)
        
        router.get("categories", use: allCategoriesHandler)
        router.get("categories", Category.parameter,
            use: categoryHandler)

    }
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req)
            .all()
            .flatMap(to: View.self, { (acronyms) in
                let acronymsData = acronyms.isEmpty ? nil : acronyms
                let context = IndexContext(title: "Home", acronyms: acronymsData)
                return try req.view().render("index", context)
            })
    }
    
    func acronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self).flatMap(to: View.self, { (acronym) in
            return try acronym.user.get(on: req).flatMap(to: View.self, { (user) in
                let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
                return try req.view().render("acronym", context)
            })
        })
        
    }
    
    func userHandler(_ req: Request) throws -> Future<View> {
        // 2
        return try req.parameters.next(User.self)
            .flatMap(to: View.self) { user in
                // 3
                return try user.acronyms
                    .query(on: req)
                    .all()
                    .flatMap(to: View.self) { acronyms in
                        // 4
                        let context = UserContext(title: user.name,
                                                  user: user,
                                                  acronyms: acronyms)
                        return try req.view().render("user", context)
                }
        }
    }
    
    func allUsersHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req)
            .all()
            .flatMap(to: View.self) { users in
                let context = AllUsersContext(title: "All Users",
                                              users: users)
                return try req.view().render("allUsers", context)
        }
    }
    
    func allCategoriesHandler(_ req: Request) throws
        -> Future<View> {
            let categories = Category.query(on: req).all()
            let context = AllCategoriesContext(categories: categories)
            return try req.view().render("allCategories", context)
    }
    
    func categoryHandler(_ req: Request) throws -> Future<View> {
        // 1
        return try req.parameters.next(Category.self)
            .flatMap(to: View.self) { category in
                // 2
                let acronyms = try category.acronyms.query(on: req).all()
                // 3
                let context = CategoryContext(title: category.name,
                                              category: category,
                                              acronyms: acronyms)
                // 4
                return try req.view().render("category", context)
        }
    }
}

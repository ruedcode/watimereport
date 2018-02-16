//
//  TimeController.swift
//  edcodePackageDescription
//
//  Created by Evgeniy Kalyada on 27/12/2017.
//

import Vapor
import HTTP

final class TimeController: ResourceRepresentable {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Time.all().makeJSON()
    }
    
    /// When consumers call 'POST' on '/posts' with valid JSON
    /// construct and save the post
    func store(_ req: Request) throws -> ResponseRepresentable {
        let time = try req.time()
        try time.save()
        return time
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
    func show(_ req: Request, time: Time) throws -> ResponseRepresentable {
        return time
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(_ req: Request, time: Time) throws -> ResponseRepresentable {
        try time.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/posts' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Time.makeQuery().delete()
        return Response(status: .ok)
    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, time: Time) throws -> ResponseRepresentable {
        // See `extension Post: Updateable`
        try time.update(for: req)
        try time.save()
        return time
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Post with the same ID.
    func replace(_ req: Request, time: Time) throws -> ResponseRepresentable {
        // First attempt to create a new Post from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.time()
        
        // Update the post with all of the properties from
        // the new post
//        employee.content = new.content
        try time.save()
        
        // Return the updated post
        return time
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Time> {
        return Resource(
            index: nil, //index,
            store: store,
            show: show,
            update: update,
            replace: nil, //replace,
            destroy: delete,
            clear: nil// clear
        )
    }
}

extension Request {
    /// Create a post from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func time() throws -> Time {
        guard let json = json else { throw Abort.badRequest }
        return try Time(json: json)
    }
}

/// Since PostController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension TimeController: EmptyInitializable { }


//
//  Time.swift
//  edcodePackageDescription
//
//  Created by Evgeniy Kalyada on 27/12/2017.
//
import Debugging
import Vapor
import FluentProvider
import HTTP

final class Time: Model {

    var date: Date
    var note: String
    let employeeId: Identifier
    
    let storage = Storage()
    
    struct Keys {
        static let id = "id"
        static let note = "note"
        static let date = "date"
        static let employeeId = "employee_id"
    }
    
    
    /// Creates a new
    init(employee: Employee, date: Date, note: String) {
//        let employee = try! Employee.find(employeeId)
        self.employeeId = employee.id!
        self.note = note
        self.date = date
    }
    
    // MARK: Fluent Serialization
    /// Initializes the Employee from the
    /// database row
    init(row: Row) throws {
        employeeId = try row.get(Time.Keys.employeeId)
        note = try row.get(Time.Keys.note)
        date = try row.get(Time.Keys.date)
    }
    
    // Serializes the Employee to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Time.Keys.note, note)
        try row.set(Time.Keys.employeeId, employeeId)
        try row.set(Time.Keys.date, date)
        return row
    }
}

extension Time {
    
    var employee: Parent<Time, Employee> {
        return parent(id: employeeId)
    }
}

extension Time: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Time.Keys.note)
            builder.date(Time.Keys.date)
            builder.parent(Employee.self)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Time: JSONConvertible {
    convenience init(json: JSON) throws {
        let employeeId: Identifier = try json.get(Time.Keys.employeeId)
        guard let employee = try Employee.find(employeeId) else {
            throw Abort.badRequest
        }
        self.init(
            employee: employee,
            date: try json.get(Time.Keys.date),
            note: try json.get(Time.Keys.note)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Time.Keys.id, id)
        try json.set(Time.Keys.note, note)
        try json.set(Time.Keys.date, date)
        try json.set(Time.Keys.employeeId, employeeId)
        return json
    }
}

extension Time: ResponseRepresentable { }

extension Time: Updateable {
    
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Time>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Time.Keys.note, String.self) { item, note in
                item.note = note
            },
            UpdateableKey(Time.Keys.date, Date.self) { item, date in
                item.date = date
            }
        ]
    }
}

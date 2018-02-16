import Vapor
import Foundation

struct DateReport {
    var name : String
    var isHoliday : Bool = false
    var reports: [ReportRecord]
}

struct ReportRecord {
    var id: String?
    var text: String
    var date: Date
    var empId: String
}

extension DateReport: JSONConvertible {
    init(json: JSON) throws {
        name = try json.get("name") ?? ""
        reports = try json.get("reports") ?? []
        isHoliday = try json.get("isHoliday") ?? false
    }
    
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("name", name)
        try json.set("reports", reports)
        try json.set("isHoliday", isHoliday)
        return json
    }
}

extension ReportRecord :JSONConvertible {
    
    init(json: JSON) throws {
        text = try json.get("text") ?? ""
        id = try json.get("id")
        date = try json.get("date") ?? Date()
        empId = try json.get("empId")
    }
    
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("text", text)
        try json.set("id", id)
        try json.set("date", date)
        try json.set("empId", empId)
        return json
    }
}

final class Routes: RouteCollection {
    public static var droplet: Droplet?
    
    let view: ViewRenderer
    init(_ view: ViewRenderer, _ droplet: Droplet) {
        self.view = view
        Routes.droplet = droplet
    }

    func build(_ builder: RouteBuilder) throws {
        /// GET /
        builder.get { req in
            return try self.view.make("welcome")
        }
    
        let skype = SkypeController()
        
        let report = ReportController(view)
        
        builder.get("report", ":id", handler: report.index)
        builder.get("report", handler: report.index)
        
        builder.post("skype", handler: skype.index)
        try builder.resource("times", TimeController.self)
        

//        // response to requests to /info domain
//        // with a description of the request
//        builder.get("info") { req in
//            return req.description
//        }
        
        builder.get("time") { req in
            var res = ""
            var tz = NSTimeZone.default
            res.append(tz.identifier)
//            NSTimeZone.default = TimeZone(identifier: "Asia/Yekaterinburg")!
//            tz = NSTimeZone.default
//            res.append(tz.identifier)
            let formatter = DateFormatter()
            let date = Date()
            formatter.dateFormat = "dd.MM.yyyy HH:00"
            let actualDate = formatter.string(from: date)
            res.append(actualDate)
            return res
        }

    }
}

import Vapor
import Foundation

struct DateReport {
    var name : String
    var reports: [String]
}

extension DateReport: JSONConvertible {
    init(json: JSON) throws {
        name = try json.get("name") ?? ""
        reports = try json.get("reports") ?? []
    }
    
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("name", name)
        try json.set("reports", reports)
        return json
    }
}

final class Routes: RouteCollection {
    let view: ViewRenderer
    init(_ view: ViewRenderer) {
        self.view = view
    }

    func build(_ builder: RouteBuilder) throws {
        /// GET /
        builder.get { req in
            return try self.view.make("welcome")
        }
        
        builder.get("report") { req in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "yyyy-MM"
            
            var date = Date()
            if let string = req.query?["date"]?.string, let selDate = formatter.date(from: string) {
                date = selDate
            }
            
            
            let calendar = Calendar.current
            let range = calendar.range(of: .day, in: .month, for: date)!
            let numDays = range.count
            formatter.dateFormat = "MMMM"
            
            var components = calendar.dateComponents([.day, .month, .year], from: date)
            
            let employees = try! Employee.all()
            
            var reports: [DateReport] = []
            
            for day in 1...numDays {
                components.day = day
                let tmpDate = calendar.date(from: components)!
                var tmpReports : [String] = []
                for employee in employees {
                    do {
                        guard let report = try employee.times?.filter(Time.Keys.date, .equals, tmpDate).first() else {
                            tmpReports.append("-")
                            continue
                        }
                        tmpReports.append(report.note)
                    }
                    catch {
                        tmpReports.append("-")
                    }
                }
                reports.append(DateReport(name: "\(day) \(formatter.string(from: date))", reports: tmpReports))
            }
            var context = [String: Any]()
            
            context["employees"] = try! employees.makeJSON()
            context["reports"] = try! reports.makeJSON()
            formatter.dateFormat = "LLLL yyyy"
            context["title"] = formatter.string(from: date)
            
            components = calendar.dateComponents([.month, .year], from: date)
            formatter.dateFormat = "yyyy-MM"
            components.day = 1
            components.month = components.month! - 1
            context["prev"] = formatter.string(from: calendar.date(from: components)!)
            components.month = components.month! + 2
            context["next"] = formatter.string(from: calendar.date(from: components)!)
            return try self.view.make("report", context)
        }

//        /// GET /hello/...
//        builder.resource("hello", HelloController(view))
    
        let skype = SkypeController()
        
        builder.post("skype", handler: skype.index)
//        builder.resource("skype", skype.index)
        

        // response to requests to /info domain
        // with a description of the request
        builder.get("info") { req in
            return req.description
        }

    }
}

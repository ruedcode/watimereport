//
//  ReportController.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 10.02.2018.
//

import Vapor
import HTTP
import Foundation

final class ReportController {
    
    let view: ViewRenderer
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "yyyy-MM"

        var date = Date()
        if let string = req.query?["date"]?.string, let selDate = formatter.date(from: string) {
            date = selDate
        }
        
        let emp = req.parameters["id"]?.int

        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        formatter.dateFormat = "MMMM"

        var components = calendar.dateComponents([.day, .month, .year], from: date)

        var employees = try! Employee.all()
        if let emp = emp {
            employees = employees.filter({ (row) -> Bool in
                return row.id?.int == emp
            })
        }

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
    
    
    
}


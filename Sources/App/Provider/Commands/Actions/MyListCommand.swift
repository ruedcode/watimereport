//
//  MyListCommand.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 30.01.2018.
//

import Foundation

class MyListCommand: BaseCommandAction {
    
    override var command: String {
        return "лист"
    }
    
    override var description: String {
        return "Показывает историю отмеченного времени за последние 7 дней"
    }
    
    override func validate(message: Skype.Entity.RecieveMessage) -> Bool {
        if message.from.state != .registered {
            return false
        }
        return super.validate(message: message)
    }
    
    override func perform(message: Skype.Entity.RecieveMessage) -> Skype.Entity.ResponseMessage? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.day, .month, .year], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        let to = calendar.date(from: components)
        let from = to?.addingTimeInterval(-7*24*60*60)
        
        do {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateStyle = .short
            guard let reports = try message.from.employee?.times?.makeQuery()
                .filter(Time.Keys.date, .greaterThanOrEquals, from)
                .filter(Time.Keys.date, .lessThanOrEquals, to)
                .all() else {
                    return nil
            }
            
            var text = ""
            for report in reports {
                if text.count > 0 {
                    text.append("<br /><br />")
                }
                text.append("<b raw_pre=\"*\" raw_post=\"*\">\(formatter.string(from: report.date))</b><br />\(report.note)")
            }
            if text.count > 0 {
                return message.makeResponse(text)
            }
            else {
                return message.makeResponse("Нет записей за последние 7 дней")
            }
        }
        catch {
            
        }
        return nil
    }
    
}

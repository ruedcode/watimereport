//
//  BaseTrackCommand.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 29.01.2018.
//

import Foundation

class BaseTrackCommand: BaseCommandAction {
    
    enum Button : String {
        case append = "дополнить"
        case change = "заменить"
    }
    
    internal var text : String {
        return ""
    }
    
    internal var prevMessage : Skype.Entity.RecieveMessage?
    
    
    internal var question: String {
        return "Что вы хотите сделать?"
    }
    
    internal var buttons: [(String, String)] {
        return [("Дополнить", Button.append.rawValue),("Заменить", Button.change.rawValue)]
    }
    
    private var currentButton : Button?
    
    
    internal var dateComponents : DateComponents {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.day, .month, .year], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        return components
    }
    
    override func validate(message: Skype.Entity.RecieveMessage) -> Bool {
        _ = super.validate(message: message)
        //если есть прошлое собщение
        if prevMessage != nil, let button = findButton(message: message) {
            currentButton = button
            return true
        }
        else {
            currentButton = nil
        }
        return false
    }
    
    override func perform(message: Skype.Entity.RecieveMessage) -> Skype.Entity.ResponseMessage? {
        guard let employee = message.from.employee else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .short
        
        if let button = currentButton, let prevMessage = prevMessage  {
            let parsed = parseMessage(message: prevMessage)
            let report = self.report(date: parsed.date, employee: employee)
            report.note = button == .append ? report.note + "\n\n" + parsed.note : parsed.note
            do {
                try! report.save()
            }
            self.currentButton = nil
            return message.makeResponse("\(formatter.string(from: report.date))<br /><i raw_pre=\"_\" raw_post=\"_\">\(report.note)</i><br />(highfive)")
        }
        else {
            let parsed = parseMessage(message: message)
            
            if parsed.date > Date() {
                return message.makeResponse("(nerd) Нельзя сохранять на будущие даты.")
            }
            
            let report = self.report(date: parsed.date, employee: employee)
            if report.exists {
                
                prevMessage = message
                let text = "(wait) На дату \(formatter.string(from: parsed.date)) уже есть запись о работе:<br /><i raw_pre=\"_\" raw_post=\"_\">\(report.note)</i>. <br/>Вы можете заменить или дополнить запись"
                return message.makeAnswerResponse(text, question: question, buttons: buttons)
            }
            report.note = parsed.note
            try! report.save()
            return message.makeResponse("\(formatter.string(from: report.date))<br /><i raw_pre=\"_\" raw_post=\"_\">\(report.note)</i><br />(highfive)")
        }
    }
    
    private func report(date: Date, employee: Employee) -> Time {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let time = try employee.times?.makeQuery().filter(raw: "DATE(\(Time.Keys.date, date)) = '\(formatter.string(from:date))'").first() {
                return time
            }
        }
        catch {
        }
        return Time(employee: employee, date: date, note: "")
        
    }
    
    private func findButton(message: Skype.Entity.RecieveMessage) -> Button? {
        let text = self.text(message)
        for item in [Button.append, Button.change] {
            if item.rawValue == text {
                return item
            }
        }
        return nil
    }
    
    
    internal func parseMessage(message: Skype.Entity.RecieveMessage) -> (date: Date, note: String) {
        fatalError("This is abstract class")
    }
    
    internal func buttonAction(message: Skype.Entity.RecieveMessage) -> Skype.Entity.ResponseMessage? {
        return nil
    }
}

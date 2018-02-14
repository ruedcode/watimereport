//
//  JobList.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 11.02.2018.
//

@_exported import Vapor
import Jobs
import Foundation

class JobList {
    
    var lastSend = ""
    
    func start() {
		
        Jobs.add(interval: 1.seconds ) {
            let formatter = DateFormatter()
            let date = Date()
            formatter.dateFormat = "dd.MM.yyyy 09:00"
            let dateMask = formatter.string(from: date)
            formatter.dateFormat = "dd.MM.yyyy HH:00"
            let actualDate = formatter.string(from: date)
            
            if dateMask == actualDate && actualDate != self.lastSend {
                self.checkTimeReports()
                self.lastSend = actualDate
            }
        }
    }
    
    private func checkTimeReports() {
        print("check time")
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "yyyy-MM-dd"
        let items = try! Employee.makeQuery().filter(Employee.Keys.isActive, true).all()
        for employee in items {
            let count = try! employee.times?.filter(raw: "DATE(date) = '\(formatter.string(from: date))'").count()
            if count == 0 {
                sendMessage(employee: employee)
            }
        }
    }
    
    private func sendMessage(employee: Employee) {
        let text = "(wave) Спиши время за сегодняшний день!"
        let recipient = Skype.Entity.Contact(name: employee.name, id: employee.skypeId!)
        let convesation = Skype.Entity.Conversation(id: employee.skypeId!)
        let from = Skype.Entity.Contact(name: "watrackerbot", id: "28:515506f8-f218-4683-a0cc-60bc300f67d9")
        let message = Skype.Entity.ResponseMessage(type: "message",
                                     serviceUrl: employee.serviceUrl!,
                                     text: text,
                                     from: from,
                                     recipient: recipient,
                                     conversation: convesation,
                                     attachments: []
        )
        let sender = Skype.Messenger()
        sender.send(message)
    }
}

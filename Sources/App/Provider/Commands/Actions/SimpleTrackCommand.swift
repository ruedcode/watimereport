//
//  SimpleTrackCommand.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 29.01.2018.
//

import Foundation

class SimpleTrackCommand: BaseTrackCommand {
    
    override var command: String {
        return "текст"
    }
    
    override var description: String {
        return  "Отмечает время за текущий день. Текст должен быть длиннее чем 3 символа"
    }

    
    override func validate(message: Skype.Entity.RecieveMessage) -> Bool {
        if message.from.state != .registered {
            return false
        }
        if super.validate(message: message) {
            return true
        }
        return self.text(message).count > 3 
    }
    
    override func parseMessage(message: Skype.Entity.RecieveMessage) -> (date: Date, note: String) {
        
        let text = self.text(message)
        var components = dateComponents
        components.hour = 0
        components.minute = 0
        let date = Calendar.current.date(from: components)
        return (date!, text)
    }
}

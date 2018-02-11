//
//  TackByNumDayCommand.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 29.01.2018.
//

import Foundation

class TrackByNumDayCommand: BaseTrackCommand {

    override var command: String {
        return "d текст"
    }
    
    override var description: String {
        return  "d - день месяца (1, 3, 4, 27). Отмечает время за указанный день текущего месяца."
    }
    
    internal func matches(message: Skype.Entity.RecieveMessage) -> [String] {
        let string = text(message)
        let res = string.capturedGroups(withRegex: "(\\d{1,2})\\s.+")
        
        return res
    }
    
    override func validate(message: Skype.Entity.RecieveMessage) -> Bool {
        if message.from.state != .registered {
            return false
        }
        if super.validate(message: message) {
            return true
        }
        return matches(message: message).count > 0
    }
    
    override func parseMessage(message: Skype.Entity.RecieveMessage) -> (date: Date, note: String) {
        let day = matches(message: message).first!
        var text = self.text(message)
        
        text = text.stringByReplacingFirstOccurrenceOfString(target: day, withString: "")
        var components = dateComponents
        components.day = day.int
        components.hour = 0
        components.minute = 0
        
        let date = Calendar.current.date(from: components)
        return (date!, text)
    }
}

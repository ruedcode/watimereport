//
//  TrackByDayMonthCommand.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 30.01.2018.
//

import Foundation

class TrackByDayMonthCommand : TrackByNumDayCommand {
    
    override var command: String {
        return "d.m текст"
    }
    
    override var description: String {
        return  "d - день, m - месяц (1, 3, 4, 27). Отмечает время за указанный день месяц."
    }
    
    internal override func matches(message: Skype.Entity.RecieveMessage) -> [String] {
        let string = text(message)
        let res = string.capturedGroups(withRegex: "(\\d{1,2}).(\\d{1,2})\\s.+")
        
        return res
    }
    
    override func validate(message: Skype.Entity.RecieveMessage) -> Bool {
        if message.from.state != .registered {
            return false
        }
        if super.validate(message: message) {
            return true
        }
        let matches = self.matches(message: message);
        
        return matches.count == 2 && matches.last!.int! <= 12
    }
    
    override func parseMessage(message: Skype.Entity.RecieveMessage) -> (date: Date, note: String) {
        let day = matches(message: message).first!
        let month = matches(message: message).last!
        var text = self.text(message)
        
        text = text.stringByReplacingFirstOccurrenceOfString(target: "\(day).\(month)", withString: "")
        var components = dateComponents
        components.timeZone = TimeZone(abbreviation: "UTC")!
        components.day = day.int
        components.month = month.int
        components.hour = 0
        components.minute = 0
        
        let date = Calendar.current.date(from: components)
        return (date!, text)
    }
}

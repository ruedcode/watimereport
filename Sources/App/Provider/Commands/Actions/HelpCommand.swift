//
//  HelpCommand.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 30.01.2018.
//

import Foundation

class HelpCommand : BaseCommandAction {
    
    override var command: String {
        return "помощь"
    }
    
    override var description: String {
        return "Показыват список досупных команд для управления ботом."
    }
    
    override func perform(message: Skype.Entity.RecieveMessage) -> Skype.Entity.ResponseMessage? {
        var helpText = ""
        for item in Command.actions {
            if item.command.count > 0 {
                if helpText.count > 0 {
                    helpText.append("<br /><br />")
                }
                helpText.append("<b raw_pre=\"*\" raw_post=\"*\">\(item.command)</b> - \(item.description)")
            }
        }
        if helpText.count > 0 {
            return message.makeResponse(helpText)
        }
        return nil
    }
    
}


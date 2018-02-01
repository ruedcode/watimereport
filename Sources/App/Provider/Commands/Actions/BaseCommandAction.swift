//
//  BaseCommandAction.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 28.01.2018.
//

import Foundation

class BaseCommandAction : CommandActionProtocol {
    
    var command: String {
        return ""
    }
    
    var description: String {
        return ""
    }
    
    func perform(message: Skype.Entity.RecieveMessage) -> Skype.Entity.ResponseMessage? {
        return nil
    }
    
    func validate(message: Skype.Entity.RecieveMessage) -> Bool {
        return text(message) == command
    }
    
    internal func response(message: Skype.Entity.RecieveMessage, text: String) -> Skype.Entity.ResponseMessage {
        return message.makeResponse(text)
    }
    
    internal func text(_ message: Skype.Entity.RecieveMessage) -> String {
        return message.text.trim().lowercased()
    }
    
    
}

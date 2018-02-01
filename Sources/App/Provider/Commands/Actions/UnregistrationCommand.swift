//
//  UnregisterCommand.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 28.01.2018.
//

import Foundation

class UnregistrationCommand : BaseCommandAction {
    
    override var command: String {
        return "стоп"
    }
    
    override var description: String {
        return  "Прекратить отслеживать мой контакт для учета времени и больше не уведомлять меня о необходимости списать время."
    }
    
    override func perform(message: Skype.Entity.RecieveMessage) -> Skype.Entity.ResponseMessage? {
        if message.from.state == .unregistered {
            return message.makeResponse("Вообще-то я тебя еще не регистрировал!(facepalm)")
        }
        else if let empl = message.from.employee {
            do {
                empl.isActive = false;
                try empl.save()
            }
            catch {
            }
            return message.makeResponse("(bomb)")
        }
        return nil
    }
}

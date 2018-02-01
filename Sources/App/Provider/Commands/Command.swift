//
//  Command.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 28.01.2018.
//

import Foundation

final class Command {
    
    static var actions : [CommandActionProtocol] = []
    
    private var _action : CommandActionProtocol?
    var action : CommandActionProtocol? {
        return _action
    }
    
    private var message: Skype.Entity.RecieveMessage
    private var messenger: Skype.Messenger
    
    init(message: Skype.Entity.RecieveMessage, on messenger: Skype.Messenger) {
        self.message = message
        self.messenger = messenger
        findAction()
    }
    
    private func findAction() {
        for item in Command.actions {
            if item.validate(message: message){
                _action = item
                break
            }
        }
    }
    
    public func perform(action: String) {
        let action = Command.actions.first { (item) -> Bool in
            return item.command == action
        }
        performOrRegister(action)
    }
    
    public func perform() {
        performOrRegister(self.action)
    }
    
    public func responseWelcome() {
        send(message.makeResponse("Отправьте <b raw_pre=\"*\" raw_post=\"*\">\(RegistrationCommand().command)</b> чтобы начать работу с ботом"))
    }
    
    private func performOrRegister(_ action: CommandActionProtocol?) {
        if message.from.state == .unregistered && (action is RegistrationCommand) == false {
            responseWelcome()
        }
        else if let action = action {
            let response = action.perform(message: message)
            send(response)
            if response != nil && action is RegistrationCommand  && message.from.state == .registered {
                perform(action: HelpCommand().command)
            }
        }
        else {
            perform(action: HelpCommand().command)
        }
    }
    
    private func send(_ response : Skype.Entity.ResponseMessage?) {
        if let response = response {
            messenger.send(response)
        }
    }

}

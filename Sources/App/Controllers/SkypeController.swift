//
//  SkypeController.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 27.01.2018.
//

import Vapor
import HTTP


final class SkypeController {
    
    typealias RMessage = Skype.Entity.RecieveMessage
    typealias SMessage = Skype.Entity.ResponseMessage
    typealias Contact = Skype.Entity.Contact

    let messenger = Skype.Messenger()
    
    init() {
        Command.actions.append(RegistrationCommand())
        Command.actions.append(UnregistrationCommand())
        Command.actions.append(HelpCommand())
        Command.actions.append(MyListCommand())
        Command.actions.append(TrackByDayMonthCommand())
        Command.actions.append(TrackByNumDayCommand())
        Command.actions.append(SimpleTrackCommand())
        
    }
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        do {
            print("\(String(bytes: req.body.bytes!))")
            let message = try req.decodeJSONBody(RMessage.self)
            return performCommand(message: message)
        }
        catch {
            print(error.localizedDescription)
            throw Abort(.badRequest)
        }
    }
    
    private func performCommand(message: RMessage) -> ResponseRepresentable {
        let command = Command(message: message, on: messenger)

        command.perform()
        return ""
    }
    
}

extension Skype.Entity.Contact {

    enum State {
        case registered
        case unregistered
    }
    
    var employee: Employee? {
        do {
            return try Employee.makeQuery()
                .filter(Employee.Keys.skypeId, id)
                .first()
        }
        catch {
            return nil
        }
    }
    
    var state : State {
        return employee != nil ? .registered : .unregistered
    }
}

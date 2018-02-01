//
//  CommandActionProtocol.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 28.01.2018.
//

protocol CommandActionProtocol {
    var command: String { get }
    var description: String { get }
    func validate(message: Skype.Entity.RecieveMessage) -> Bool
    func perform(message: Skype.Entity.RecieveMessage) -> Skype.Entity.ResponseMessage?
}


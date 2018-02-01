//
//  RegistrationCommand.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 28.01.2018.
//


class RegistrationCommand : BaseCommandAction {
    override var command: String {
        return "старт"
    }
    
    override var description: String {
        return  "Отслеживать  мой контакт для учета времени и уведомлять о необходимости списать время."
    }
    
    override func perform(message: Skype.Entity.RecieveMessage) -> Skype.Entity.ResponseMessage? {
        if message.from.state == .registered {
            return message.makeResponse("Я тебя уже зарегистрировал!(facepalm)")
        }
        else {
            do {
                var employee = Employee(name: message.from.name, serviceUrl: message.serviceUrl, position: nil, phone: nil, note: nil)
                do {
                    let saved = try Employee.makeQuery().filter(Employee.Keys.skypeId, message.from.id).first()
                    if saved != nil {
                        employee = saved!
                    }
                }
                catch {
                    
                }
                employee.skypeId = message.from.id
                try employee.save()
                let text = """
(rock) Ура! Теперь ты с нами. Теперь ты будешь каждый раз получать уведомления если будет необходимо списать время.
"""
                return message.makeResponse(text)
            }
            catch {
            }
        }
        return nil
    }
}

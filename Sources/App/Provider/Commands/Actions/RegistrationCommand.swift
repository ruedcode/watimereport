//
//  RegistrationCommand.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 28.01.2018.
//


class RegistrationCommand : BaseCommandAction {
    
    var regex : String {
        return "\(self.command)\\s([а-яА-Яa-zA-Z]{2,})\\s([а-яА-Яa-zA-Z]{2,})"
    }
    
    override var command: String {
        return "старт"
    }
    
    override var description: String {
        return  "Отслеживать  мой контакт для учета времени и уведомлять о необходимости списать время."
    }
    
    override func validate(message: Skype.Entity.RecieveMessage) -> Bool {
        let text = self.text(message)
        if ( text == command ) {
            return true;
        }
        let names = text.capturedGroups(withRegex: regex)
        return names.count == 2
    }
    
    override func perform(message: Skype.Entity.RecieveMessage) -> Skype.Entity.ResponseMessage? {
        let string = self.text(message)
        let names = string.capturedGroups(withRegex: regex)
        if message.from.state == .registered {
            return message.makeResponse("Я тебя уже зарегистрировал!(facepalm)")
        }
        else if (message.from.name == nil || message.from.name!.count == 0) && names.count == 0 {
            return message.makeResponse("Не удалось получить ваше имя. Введите <b raw_pre=\"*\" raw_post=\"*\">старт фаимлия имя</b>, где имя ваше имя а фамилия - ваша фамилия. И фамилия и имя должны состоять как минимум из 2 букв.")
        }
        else {
            do {
                var employee = Employee(name: message.from.name, serviceUrl: message.serviceUrl, position: nil, phone: nil, note: nil, isActive: true)
                do {
                    let saved = try Employee.makeQuery().filter(Employee.Keys.skypeId, message.from.id).first()
                    if saved != nil {
                        employee = saved!
                    }
                }
                catch {
                    
                }
                if names.count == 2 {
                    employee.name = "\(names.first!.capitalizingFirstLetter()) \(names.last!.capitalizingFirstLetter())"
                }
                employee.skypeId = message.from.id
                employee.isActive = true
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

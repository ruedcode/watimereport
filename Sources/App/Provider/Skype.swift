//
//  BotAuthProvider.swift
//  watimetrackerPackageDescription
//
//  Created by Evgeniy Kalyada on 28.01.2018.
//

import Foundation
import HTTP
import Vapor

class Skype {
    
    public final class Provider: Vapor.Provider {
        
        fileprivate static var drop : Droplet?
        
        public static let repositoryName = "skype-provider"
        
        /// Use this to create a provider instance
        public init() {}
        
        public convenience init(config: Config) throws {
            self.init()
        }
        
        public func boot(_ config: Config) throws {
//            config.addConfigurable(view: LeafRenderer.init, name: "skype")
        }
        
        public func boot(_ drop: Droplet) throws {
            Provider.drop = drop
        }
        
        public func beforeRun(_ drop: Droplet) throws {}
    }
    
    public struct Entity {
        
        fileprivate struct Token : Codable {
            var token_type: String = ""
            var expires_in: Int = 0
            var ext_expires_in: Int = 0
            var access_token: String = ""
            
            func isEmpty() -> Bool {
                return token_type.count == 0 || access_token.count == 0
            }
        }
        
        public struct Contact : Codable {
            let name : String?
            let id : String
        }
        
        public struct Conversation : Codable {
            let id : String
        }
        
        public struct RecieveMessage : Codable {
            let type : String
            let text : String
            let serviceUrl : String
            let from : Contact
            let recipient : Contact
            let conversation: Conversation
            
            public func makeResponse(_ text: String) -> ResponseMessage {
                return ResponseMessage(type: type,
                                       serviceUrl: serviceUrl,
                                       text: text,
                                       from: recipient,
                                       recipient: from,
                                       conversation: conversation,
                                       attachments: []
                )
            }
            
            public func makeAnswerResponse(_ text: String, question:String, buttons: [(String, String)]) -> ResponseMessage {
                var tmp : [AttachmentButton] = []
                for row in buttons {
                    tmp.append(AttachmentButton(title: row.0, value: row.1))
                }
                let attachment = AttachmentCard(content: AttachmentContent(title: question, subtitle: "", text: "", buttons: tmp))
                return ResponseMessage(type: type,
                                       serviceUrl: serviceUrl,
                                       text: text,
                                       from: recipient,
                                       recipient: from,
                                       conversation: conversation,
                                       attachments: [attachment]
                    
                )
            }
        }
        
        public struct ResponseMessage : Codable {
            var type: String
            let serviceUrl : String
            var text : String
            var from : Contact
            var recipient : Contact
            var conversation: Conversation
            var attachments : [AttachmentCard] = []
        }
        
        public struct AttachmentCard : Codable {
            let contentType = "application/vnd.microsoft.card.hero"
            var content: AttachmentContent = AttachmentContent()
        }
        
        public struct AttachmentContent : Codable {
            var title = ""
            var subtitle = ""
            var text = ""
            var buttons: [AttachmentButton] = []
        }
        
        public struct AttachmentButton : Codable {
            let type = "imBack"
            var title = ""
            var value = ""
        }
    
    }
    
    public final class Auth {
        
        fileprivate var token = Entity.Token(token_type: "", expires_in: 0, ext_expires_in: 0, access_token: "")
        
        private var lastLogin : Date?
        
        private let authUrl  = "https://login.microsoftonline.com/botframework.com/oauth2/v2.0/token"
        
        private let authParams = "grant_type=client_credentials&client_id=515506f8-f218-4683-a0cc-60bc300f67d9&client_secret=mcjiebjGJQP7356%5DQMI4%2A%7D%2B&scope=https%3A%2F%2Fapi.botframework.com%2F.default"
        
        public var isLogin: Bool {
            if let lastLogin = lastLogin {
                let interval = Double(exactly: token.expires_in) ?? 0
                let date = lastLogin.addingTimeInterval(interval)
                return !token.isEmpty() && date > Date()
            }
            return false;
            
        }
        
        func login() {
            if let drop = Skype.Provider.drop {
                let resp = try! drop.client.request(.post, authUrl,
                                                    query: [:],
                                                    ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8"],
                                                    authParams.makeBody(),
                                                    through: []
                )
                
                if resp.status == .ok {
                    token = try! resp.decodeJSONBody(Entity.Token.self)
                    lastLogin = Date()
                }
                
                print(String(bytes: resp.body.bytes!))
            }
        }
    }
    
    public final class Messenger {
        
        
        let auth: Auth
        
        init() {
            auth = Auth()
        }
        
        func send(_ message: Entity.ResponseMessage) {
            if !auth.isLogin {
                auth.login()
            }
//            let string = String(data: try! JSONEncoder().encode(message), encoding: .utf8)
            let json = try! JSON(bytes: JSONEncoder().encode(message).makeBytes())
            let body = try! Body(json)
            let url =  "\(message.serviceUrl)/v3/conversations/\(message.conversation.id)/activities/"
//            let url =  "https://color-rain.ru/bit"
            
            if let drop = Skype.Provider.drop {
                let resp = try! drop.client.request(.post, url,
                    query: [:],
                    [
                        "Authorization": "\(auth.token.token_type) \(auth.token.access_token)",
                        "Content-Type" : "application/json"
                    ],
                    body.makeBody(),
                    through: []
                )
                print(String(bytes: resp.body.bytes!))
//                if resp.status == .ok {
//                    print(String(bytes: resp.body.bytes!))
//                }
            }
        }
    }
}

//
//  MessagingProxy.swift
//  Test2
//
//  Created by maciulek on 15/04/2022.
//

import Foundation

protocol MessagingProxy {
    func initialize(deviceToken: Data)
    func subscribeForMessages(topic: String)
}

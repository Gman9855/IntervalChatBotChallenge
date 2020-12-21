//
//  Message.swift
//  IntervalChallenge
//
//  Created by Gershy Lev on 12/18/20.
//

import Foundation
import MessageKit

struct Message: MessageType {    
    var sentDate: Date
    var sender: SenderType
    var messageId: String
    var kind: MessageKind
}

//
//  User.swift
//  IntervalChallenge
//
//  Created by Gershy Lev on 12/18/20.
//

import Foundation
import MessageKit

struct User: SenderType {
    var senderId: String
    var displayName: String
    var image: UIImage?
}

extension SenderType {
    var firstName: String {
        return displayName.components(separatedBy: " ").first ?? ""
    }
    var lastName: String {
        return displayName.components(separatedBy: " ").last ?? ""
    }
}

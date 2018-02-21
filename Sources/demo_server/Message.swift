//
//  Message.swift
//  demo_serverPackageDescription
//
//  Created by 민경준 on 2018. 2. 20..
//

import Foundation

class Message {
    
    var sender = ""
    var timeStamp = ""
    var comment = ""
    
    func asDictionary() -> [String: String]{
        return [
            "sender": self.sender,
            "timeStamp": self.timeStamp,
            "content": self.comment
        ]
    }
}

//
//  Update.swift
//  WebSupport DNS
//
//  Created by Pavel Kanzelsberger on 21/12/2018.
//  Copyright © 2018 Mediaware, s.r.o. All rights reserved.
//

import Foundation

class Update: CustomStringConvertible {
    
    var type: String
    var zone: String
    var record: String
    
    var description: String {
        return "Update {type:\(type), record:\(record), zone:\(zone)}"
    }

    init(type: String, zone: String, record: String) {
        self.type = type
        self.zone = zone
        self.record = record
    }

}

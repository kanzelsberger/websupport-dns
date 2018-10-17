//
//  Zone.swift
//  WebSupport DNS
//
//  Created by Pavel Kanzelsberger on 17/10/2018.
//  Copyright © 2018 Mediaware, s.r.o. All rights reserved.
//

import Foundation
import ObjectMapper

class Zone: Mappable, CustomStringConvertible {
    
    var id: Int = -1
    var name: String = ""
    
    var description: String {
        return "Zone {id:\(id), name:\(name)}"
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }

}

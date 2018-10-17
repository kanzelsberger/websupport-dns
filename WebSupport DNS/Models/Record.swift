//
//  Record.swift
//  WebSupport DNS
//
//  Created by Pavel Kanzelsberger on 17/10/2018.
//  Copyright © 2018 Mediaware, s.r.o. All rights reserved.
//

import Foundation
import ObjectMapper

class Record: Mappable, CustomStringConvertible {
    
    var id: Int = -1
    var type: String = ""
    var name: String = ""
    var content: String = ""
    var ttl: Int = 0

    var description: String {
        return "Record {id:\(id), type:\(type), name:\(name), content:\(content), ttl:\(ttl)}"
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        name <- map["name"]
        content <- map["content"]
        ttl <- map["ttl"]
    }
    
}

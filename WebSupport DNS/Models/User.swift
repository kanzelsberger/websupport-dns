//
//  User.swift
//  WebSupport DNS
//
//  Created by Pavel Kanzelsberger on 17/10/2018.
//  Copyright © 2018 Mediaware, s.r.o. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable, CustomStringConvertible {
    
    var id: Int = -1
    var login: String = ""
    var active: Bool = false
    var createTime: Int = 0
    var group: String = ""

    var description: String {
        return "User {id:\(id), login:\(login), active:\(active), group:\(group)}"
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        login <- map["login"]
        active <- map["active"]
        createTime <- map["createTime"]
        group <- map["group"]
    }
    
    
}

//
//  main.swift
//  WebSupport DNS
//
//  Created by Pavel Kanzelsberger on 16/10/2018.
//  Copyright © 2018 Mediaware, s.r.o. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

enum AppError: Error {
    case remoteAddressFailed
    case invalidResponse
}

extension Keys {
    static let login = Key<String>("Login")
    static let password = Key<String>("Password")
    static let updateInterval = Key<Int>("UpdateInterval")
}

class App {

    static let shared = App()
    
    var timeout: TimeInterval = 5
    var remoteAddress: String = "0.0.0.0"

    var authorizationToken: String = ""
    
    func getRemoteAddress(completion: @escaping (_ address: String?, _ error: Error?) -> ()) {
        Alamofire.request("https://api.ipify.org", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { (response) in
            if response.response?.statusCode == 200 {
                completion(response.result.value, nil)
            } else {
                completion(nil, AppError.remoteAddressFailed)
            }
        }
    }
    
    func headers() -> HTTPHeaders {
        return ["Authorization": authorizationToken]
    }
    
    func getUser(completion: @escaping (_ user: User?, _ error: Error?) -> ()) {
        Alamofire.request("https://rest.websupport.sk/v1/user", method: .get, parameters: nil, encoding: URLEncoding.default, headers: self.headers()).responseJSON { (response) in
            guard let json = response.result.value as? NSDictionary else {
                completion(nil, AppError.invalidResponse)
                assertionFailure()
                return
            }
            guard let items = json["items"] else {
                completion(nil, AppError.invalidResponse)
                assertionFailure()
                return
            }
            
            let users = Mapper<User>().mapArray(JSONObject: items) ?? []
            if let user = users.first {
                completion(user, nil)
            } else {
                completion(nil, AppError.invalidResponse)
            }
        }
    }
    
    func getZones(user: User, completion: @escaping (_ zones: [Zone]?, _ error: Error?) -> ()) {
        
    }
    
    func getRecords(user: User, zone: Zone, completion: @escaping (_ records: [Record]?, _ error: Error?) -> ()) {
        
    }
    
    func timer() {
        self.getRemoteAddress { (address, error) in
            if let ip = address {
                if ip != self.remoteAddress {
                    print("New remote address \(ip)")
                    self.remoteAddress = ip
                    
                    self.getUser(completion: { (user, error) in
                        if let user = user {
                            print("Retrieved user: \(user)")
                        } else {
                            print("Error retrieving user: \(error)")
                        }
                    })
                }
            } else {
                print("Error retrieving IP address: \(error)")
            }
        }
    }
    
    func run() {
        print(ProcessInfo.processInfo.arguments)
        self.timer()
        
        let configPath = "/Users/pavel/.websupport.plist"
        if let setup = Configuration.init(plistPath: configPath) {
            guard let login = setup.get(.login) else {
                assertionFailure()
                exit(1)
            }
            guard let password = setup.get(.password) else {
                assertionFailure()
                exit(1)
            }
            
            if let payload = "\(login):\(password)".data(using: String.Encoding.utf8)?.base64EncodedString() {
                self.authorizationToken = "Basic \(payload)"
                print("Authorization token: \(self.authorizationToken)")
            }
        }

        Timer.scheduledTimer(withTimeInterval: timeout * 60, repeats: true, block: { (timer) in
            self.timer()
        })
        RunLoop.main.run(until: Date(timeIntervalSinceNow: TimeInterval.infinity))
    }
}

App.shared.run()

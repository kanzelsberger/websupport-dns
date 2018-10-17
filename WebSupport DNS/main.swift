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
    case requestFailed
}

extension Keys {
    static let login = Key<String>("Login")
    static let password = Key<String>("Password")
    static let updateInterval = Key<Int>("UpdateInterval")
    static let zone = Key<String>("Zone")
    static let records = Key<Array<String>>("Records")
}

class App {

    static let shared = App()
    
    var timeout: TimeInterval = 5
    var remoteAddress: String = "0.0.0.0"

    var authorizationToken: String = ""
    
    var updateZone: String = ""
    var updateRecords: [String] = []
    
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
        Alamofire.request("https://rest.websupport.sk/v1/user/\(user.id)/zone", method: .get, parameters: nil, encoding: URLEncoding.default, headers: self.headers()).responseJSON { (response) in
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
            
            let zones = Mapper<Zone>().mapArray(JSONObject: items) ?? []
            completion(zones, nil)
        }
    }
    
    func getRecords(user: User, zone: Zone, completion: @escaping (_ records: [Record]?, _ error: Error?) -> ()) {
        Alamofire.request("https://rest.websupport.sk/v1/user/\(user.id)/zone/\(zone.name)/record", method: .get, parameters: nil, encoding: URLEncoding.default, headers: self.headers()).responseJSON { (response) in
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

            let records = Mapper<Record>().mapArray(JSONObject: items) ?? []
            completion(records, nil)
        }
    }
    
    func updateRecord(user: User, zone: Zone, record: Record, content: String, completion: @escaping (_ error: Error?) -> ()) {
        let payload: [String: Any] = [
            "name": record.name,
            "content": content,
            "ttl": record.ttl
        ]
        Alamofire.request("https://rest.websupport.sk/v1/user/\(user.id)/zone/\(zone.name)/record/\(record.id)", method: .put, parameters: payload, encoding: JSONEncoding.default, headers: self.headers()).responseJSON { (response) in
            if response.response?.statusCode == 200 {
                completion(nil)
            } else {
                print("Request failed: \(response)")
                completion(AppError.requestFailed)
            }
        }
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
                            
                            self.getZones(user: user, completion: { (zones, error) in
                                if let zones = zones {
                                    print("Got zones: \(zones)")
                                    
                                    if let zone = zones.filter({ $0.name == self.updateZone }).first {
                                        self.getRecords(user: user, zone: zone, completion: { (records, error) in
                                            if let records = records {
                                                print("Got records: \(records)")
                                                
                                                let list = records.filter({ self.updateRecords.contains($0.name) })
                                                for item in list {
                                                    print("Updating \(item.name).\(zone.name) ttl \(item.ttl) to \(ip) from \(item.content)")
                                                    self.updateRecord(user: user, zone: zone, record: item, content: ip, completion: { (error) in
                                                        if error != nil {
                                                            print("Failed to update record: \(item), error: \(error)")
                                                        }
                                                    })
                                                }
                                                
                                            } else {
                                                print("Error retrieveing records: \(error)")
                                            }
                                        })
                                    } else {
                                        print("Error: Cannot find zone to update")
                                    }
                                } else {
                                    print("Error retrieving zones: \(error)")
                                }
                            })
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
            
            guard let zone = setup.get(.zone) else {
                assertionFailure()
                exit(1)
            }
            guard let records = setup.get(.records) else {
                assertionFailure()
                exit(1)
            }
            
            print("Will update zone: \(zone), records: \(records)")
            self.updateZone = zone
            self.updateRecords = records
        }

        // Run timer once at startup
        
        self.timer()
        
        // Schedule timer that checks for remote IP address change periodically

        Timer.scheduledTimer(withTimeInterval: timeout * 60, repeats: true, block: { (timer) in
            self.timer()
        })
        RunLoop.main.run(until: Date(timeIntervalSinceNow: TimeInterval.infinity))
    }
}

App.shared.run()

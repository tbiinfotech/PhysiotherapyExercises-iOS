//
//  GetAcitivity.swift
//  SilverFox
//
//  Created by Satinderjeet Kaur on 03/05/21.
//

import Foundation
class GetActivityIncomming {
    var serverData : [String: Any] = [:]
    var msg : String?
    var status : Int?
    var data : [Data] = []
    init(dict: [String:Any], dataArray: [[String: Any]]){
        self.serverData = dict
        
        if let msg = dict["msg"] as? String {
            self.msg = msg
        }
        if let status = dict["status"] as? Int {
            self.status = status
        }
        for object in dataArray {
            let some =  Data()
            some.serverData = object
            if let description = object["description"] as? String {
                some.description = description
            }
            if let thumbnail = object["thumbnail"] as? String {
                some.thumbnail = thumbnail
            }
            if let video = object["video"] as? String {
                some.video = video
            }
            if let title = object["title"] as? String {
                some.title = title
            }
            if let id = object["id"] as? Int {
                some.id = id
            }
            self.data.append(some)
        }
        print("Count", self.data.count)
    }
    class Data {
        var serverData : [String: Any] = [:]
        var description : String?
        var thumbnail : String?
        var video : String?

        var title : String?
        var id : Int?
        
    }
}

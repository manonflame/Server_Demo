//
//  Messenger.swift
//  demo_serverPackageDescription
//
//  Created by 민경준 on 2018. 2. 17..
//

import Foundation
import StoreKit
import PostgresStORM
import PerfectPostgreSQL
import PerfectNotifications

class Messenger {
    
    static let notificationsAppId = "KJ.demo-FollowME"

    
    
    //유저 테이블에 데이터들을 넣음
    static func insertIntoUserTable(to: String, from: String, timeStamp: String, message: String){        
        Messenger.pushNotificationToUser(to: to, from: from, timeStamp: timeStamp, message: message)
    }
    
    static func pushNotificationToUser(to: String, from: String, timeStamp: String, message: String){
        
        //디바이스 토큰이 empty가 아니면 푸시 노티피케이션을 보냄
        do{
            let p = PGConnection()
            let status = p.connectdb("host=localhost dbname=demo_db")
            defer{
                p.close()
            }
            let result = p.exec(statement: "SELECT deviceToken from Users Where id = '\(to)';")
        
            if let gotdeviceToken = result.getFieldString(tupleIndex: 0, fieldIndex: 0){
                
                if gotdeviceToken == "empty" {
                    do{
                        print("디바이스 토큰이 없어서 디비에 저장")
                        let p = PGConnection()
                        let status = p.connectdb("host=localhost dbname=demo_db")
                        defer{
                            p.close()
                        }
                        let result = p.exec(statement: "INSERT INTO User_\(to) VALUES ('\(from)', '\(timeStamp)', '\(message)');")
                        print(result.errorMessage())
                        print(result.status())
                    }
                }
                else{
                    print("디바이스 토큰이 있어서 쏨")
                    let n = NotificationPusher(apnsTopic: Messenger.notificationsAppId)
                    n.pushAPNS(
                        configurationName: Messenger.notificationsAppId,
                        deviceToken: String(gotdeviceToken),
                        notificationItems: [.alertBody("\(from) : \(message)"), .sound("default"), .badge(69), .contentAvailable, .category("\(timeStamp)")]) {
                            responses in
                            print("ASDFASDF  \(timeStamp)")
                            print("\(responses)")
                    }
                }
                
                
            }
        }
    }
}

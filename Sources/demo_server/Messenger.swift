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

    static func checkMessage(checker: String, from: String){
        do{
            let p = PGConnection()
            let status = p.connectdb("host=localhost dbname=demo_db")
            defer{
                p.close()
            }
            //DELETE FROM User_\(checker) where sender = '\(from)';
            do{
                print("확인한 내용 지우기 checker : \(checker) sender : \(from)")
                let result = p.exec(statement: "DELETE FROM User_\(checker) WHERE sender = '\(from)'")
                print(result.errorMessage())
                print(result.status())
            }
            do{
            
                let result = p.exec(statement: "SELECT deviceToken from Users Where id = '\(checker)';")
                let countResult = p.exec(statement: "SELECT count(*) FROM User_\(checker);")
                let badgeCount = countResult.getFieldInt(tupleIndex: 0, fieldIndex: 0)
                if let gotdeviceToken = result.getFieldString(tupleIndex: 0, fieldIndex: 0){

                    if gotdeviceToken != "empty" {
                        print("디바이스 토큰이 있어서 쏨2 : \(badgeCount)")
                        let n = NotificationPusher(apnsTopic: Messenger.notificationsAppId)
                        n.pushAPNS(
                            configurationName: Messenger.notificationsAppId,
                            deviceToken: String(gotdeviceToken),
                            notificationItems: [ .badge(badgeCount!
                                )]) {
                                    responses in
                                    print("\(responses)")
                        }
                    }
                }
            }
        } 
    }
    
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
            do{
                print("대화 내용 데이터베이스에 저장")
                let result = p.exec(statement: "INSERT INTO User_\(to) VALUES ('\(from)', '\(timeStamp)', '\(message)');")
                print(result.errorMessage())
                print(result.status())
            }
            let result = p.exec(statement: "SELECT deviceToken from Users Where id = '\(to)';")
            let countResult = p.exec(statement: "SELECT count(*) FROM User_\(to);")
            let badgeCount = countResult.getFieldInt(tupleIndex: 0, fieldIndex: 0)
            print("badge : \(badgeCount!)")
            if let gotdeviceToken = result.getFieldString(tupleIndex: 0, fieldIndex: 0){
   
                if gotdeviceToken != "empty" {
                    print("디바이스 토큰이 있어서 쏨 : \(badgeCount!)")
                    let n = NotificationPusher(apnsTopic: Messenger.notificationsAppId)
                    n.pushAPNS(
                        configurationName: Messenger.notificationsAppId,
                        deviceToken: String(gotdeviceToken),
                        notificationItems: [.alertBody("\(from) : \(message)"), .sound("default"), .badge(badgeCount!
                            ), .contentAvailable, .category("\(timeStamp)")]) {
                            responses in
                            print("ASDFASDF  \(timeStamp)")
                            print("\(responses)")
                    }
                }
            }
        }
    }
}

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import PostgresStORM
import PerfectPostgreSQL
import PerfectNotifications

PostgresConnector.host = "localhost"
PostgresConnector.username = "demo"
PostgresConnector.password = "dkemffj"
PostgresConnector.database = "demo_db"
PostgresConnector.port = 5432


//APNS Configuartion
let notificationsAppId = "KJ.demo-FollowME"
let apnsKeyIdentifier = "9RL2PYA93U"
let apnsTeamIdentifier = "SMWAEJPYXQ"
let apnsPrivateKeyFilePath = "/Users/KyungjunMin/Desktop/ios/Certifications&CSR/AuthKey_9RL2PYA93U.p8"
NotificationPusher.addConfigurationAPNS(name: notificationsAppId, production: false, keyId: apnsKeyIdentifier, teamId: apnsTeamIdentifier, privateKeyPath: apnsPrivateKeyFilePath)


let setupInvitation = Invitation()
try? setupInvitation.setup()

let setupUser = User()
try? setupUser.setup()

let server = HTTPServer()
server.serverPort = 8080

//어레이 형태의 모든 루트 입력
let basic = BasicController()
server.addRoutes(Routes(basic.routes))

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg){
    print("Network error thrown: \(err) \(msg)")
}


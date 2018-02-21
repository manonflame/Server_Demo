import StoreKit
import PostgresStORM
import PerfectPostgreSQL

class UserAPI {
    static func usersToDictionary(_ users: [User]) -> [[String: Any]] {
        var usersJson: [[String: Any]] = []
        for row in users {
            usersJson.append(row.asDictionary())
        }
        return usersJson
    }
    
    //회원 가입용
    static func newUser(withId id: String, pw: String, languages: [String], deviceToken: String) throws -> [String: Any] {
        let user = User()
        user.id = id
        user.pw = pw
        user.languages = languages
        user.deviceToken = deviceToken
        print("saving")
        print(user.id)
        print(user.pw)
        print(user.languages)
        print(user.deviceToken)
        
        //회원 테이블에 유저 추가
        do{
            let p = PGConnection()
            let status = p.connectdb("host=localhost dbname=demo_db")
            defer{
                p.close()
            }
            let result = p.exec(statement: "INSERT INTO USERS VALUES ('\(user.id)', '\(user.pw)', '{ }', '');")
        }
        catch{
            var noUser = User()
            noUser.id = "no"
            noUser.pw = "no"
            return noUser.asDictionary()
        }
        
        //유저 테이블 만들기
        do{
            let p = PGConnection()
            let status = p.connectdb("host=localhost dbname=demo_db")
            defer{
                p.close()
            }
            let result = p.exec(statement: "CREATE TABLE User_\(user.id) (sender varchar(20), timeStamp varchar(20), content varchar(2000));")
            
            //demo_db권한 부여
            let grant = p.exec(statement: "GRANT ALL ON user_\(user.id) TO demo;")
        }
        
        
        return user.asDictionary()
    }
    
    
    static func newUser(withJSONRequest json: String?) throws -> String {
        guard let json = json,
        let dict = try json.jsonDecode() as? [String : Any],
            let id = dict["id"] as? String,
            let pw = dict["pw"] as? String,
            let languages = dict["languages"] as? [String],
            let deviceToken = dict["deviceToken"] as? String else {
                return "Invalid Parameters"
        }
        return try newUser(withId: id, pw: pw, languages: languages, deviceToken: deviceToken).jsonEncodedString()
    }
    
    
    static func loginUser(withJSONRequest json: String?) throws -> String{
        //decoding
        var userRequested = User()
        guard let json = json,
        let dict = try json.jsonDecode() as? [String: Any],
            let id = dict["id"] as? String,
            let pw = dict["pw"] as? String,
            let languages = dict["languages"] as? [String],
            let deviceToken = dict["deviceToken"] as? String else {
                var result = ["result": "Invalid Parameters"]
                return try result.jsonEncodedString()
        }

        //select user from db
        var user = try User.getUser(id: id)

        
        //no user - return no user
        if user.id == "" {
            var result = ["result": "no user"]
            return try result.jsonEncodedString()
        }
        
        //pw not matched - return not matched
        if user.pw != pw {
            var result = ["result": "not matched password"]
            return try result.jsonEncodedString()
        }else{
            //success - return success
            //디바이스 토큰 업데이트
            do {
                let p = PGConnection()
                let status = p.connectdb("host=localhost dbname=demo_db")
                defer{
                    p.close()
                }
                let result = p.exec(statement: "UPDATE users SET deviceToken = '\(deviceToken)' WHERE id = '\(user.id)';")
            }
            
            var arr = [[String : Any]]()
            //유저테이블을 검색함
            do {
                let p = PGConnection()
                let status = p.connectdb("host=localhost dbname=demo_db")
                defer{
                    p.close()
                }
                let queryResult = p.exec(statement: "SELECT * from User_\(user.id);")
                let count = queryResult.numTuples()
                
                for x in 0 ..< count {
                    var message = Message()
                    message.sender = queryResult.getFieldString(tupleIndex: x, fieldIndex: 0)!
                    message.timeStamp = queryResult.getFieldString(tupleIndex: x, fieldIndex: 1)!
                    message.comment = queryResult.getFieldString(tupleIndex: x, fieldIndex: 2)!
                    
                    arr.append(message.asDictionary())
                }
            }
            
            //쌓여있던 데이터를 지움
            do{
                let p = PGConnection()
                let status = p.connectdb("host=localhost dbname=demo_db")
                defer{
                    p.close()
                }
                let queryResult = p.exec(statement: "DELETE FROM User_\(user.id);")
            }
            
            //쿼리문을 받아서 메시지 객체에 넣음
            //메시지 객체를 String으로 변환
            let result : [String: Any] = ["result": "login succeed", "arr" : arr]
            
            print("--------------")
            print(try result.jsonEncodedString())
            return try result.jsonEncodedString()
        }
    }
    
}

import Foundation

class UserAPI {
    static func usersToDictionary(_ users: [User]) -> [[String: Any]] {
        var usersJson: [[String: Any]] = []
        for row in users {
            usersJson.append(row.asDictionary())
        }
        return usersJson
    }
    
    //회원 가입용
    static func newUser(withId id: String, pw: String, languages: [String]) throws -> [String: Any] {
        let user = User()
        user.id = id
        user.pw = pw
        user.languages = languages
        print("saving")
        print(user.id)
        print(user.pw)
        print(user.languages)
        do{
            try user.create()
        }
        catch{
            var noUser = User()
            noUser.id = "no"
            noUser.pw = "no"
            return noUser.asDictionary()
        }
        
        return user.asDictionary()
    }
    
    static func newUser(withJSONRequest json: String?) throws -> String {
        guard let json = json,
        let dict = try json.jsonDecode() as? [String : Any],
            let id = dict["id"] as? String,
            let pw = dict["pw"] as? String,
            let languages = dict["languages"] as? [String] else {
                return "Invalid Parameters"
        }
        return try newUser(withId: id, pw: pw, languages: languages).jsonEncodedString()
    }
    
    
    static func loginUser(withJSONRequest json: String?) throws -> String{
        //decoding
        var userRequested = User()
        guard let json = json,
        let dict = try json.jsonDecode() as? [String: Any],
            let id = dict["id"] as? String,
            let pw = dict["pw"] as? String,
            let languages = dict["languages"] as? [String] else {
                return "Invalid Parameters"
        }
        print("---")
        print(id)
        print(pw)
        print("---")
        //select user from db
        var user = try User.getUser(id: id)
        print(user.id)
        print(user.pw)
        print("---")

        
        //no user - return no user
        if user.id == "" {
            print("no user")
            return "no user"
        }
        
        //pw not matched - return not matched
        if user.pw != pw {
            print("not matched password")
            return "not matched password"
        }else{
            //success - return success
            print("login succeed")
            return "login succeed"
        }
    }
    
}

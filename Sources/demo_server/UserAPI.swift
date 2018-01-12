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
        try user.create()
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
    
    
}

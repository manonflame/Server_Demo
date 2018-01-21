import StORM
import PostgresStORM

class User: PostgresStORM {
    var id: String = ""
    var pw: String = ""
    var languages: [String] = [String]()
    
    override open func table() -> String { return "Users" }
    
    //DB to Obj
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? String ?? ""
        pw = this.data["pw"] as? String ?? ""
        languages = this.data["languages"] as? [String] ?? [String]()
    }
    
    func rows() -> [User]{
        var rows = [User]()
        for i in 0..<self.results.rows.count {
            let row = User()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "pw": self.pw,
            "languages": self.languages
        ]
    }
    
    static func getUser(id: String) throws -> User {
        let getObj = User()
        var findObj = [String: Any]()
        findObj["id"] = id
        try getObj.find(findObj)
        print("getUsers: \(getObj.id)")
        print("getUsers id: \(id)")
        print("getUsers: \(getObj.pw)")
        return getObj
    }
    
}

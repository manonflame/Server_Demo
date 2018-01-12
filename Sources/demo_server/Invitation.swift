import StORM
import PostgresStORM

class Invitation: PostgresStORM {
    var id: Int = 0
    var pw: String = ""
    var userid: String = ""
    var city: String = ""
    var languages: [String] = [String]()
    
    override open func table() -> String { return "Invitations" }
    
    //DB to Obj
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        pw = this.data["pw"] as? String ?? ""
        userid = this.data["userid"] as? String ?? ""
        city = this.data["city"] as? String ?? ""
        var languageslist = this.data["languages"] as? String ?? ""
        languages = languageslist.components(separatedBy: ",")
    }
    
    func rows() -> [Invitation]{
        var rows = [Invitation]()
        for i in 0..<self.results.rows.count {
            let row = Invitation()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "pw": self.pw,
            "userid": self.userid,
            "city": self.city,
            "languages": self.languages
        ]
    }
    
    static func getInvitation(matchingCity city: String) throws -> [Invitation] {
        let getObj = Invitation()
        var findObj = [String: Any]()
        findObj["city"] = city
        try getObj.find(findObj)
        return getObj.rows()
    }
    
    
}

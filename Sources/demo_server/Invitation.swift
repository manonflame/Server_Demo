import StORM
import PostgresStORM
import PerfectPostgreSQL

class Invitation: PostgresStORM {
    var userid: String = ""
    var city: String = ""
    var languages: [String] = [String]()
    
    override open func table() -> String { return "Invitations" }
    
    //DB to Obj
    override func to(_ this: StORMRow) {
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
            "userid": self.userid,
            "city": self.city,
            "languages": self.languages
        ]
    }
    
    static func getInvitations(matchingCity city: String) throws -> [Invitation] {
        let getObj = Invitation()
        var findObj = [String: Any]()
        findObj["city"] = "\(city)"
        try getObj.find(findObj)
        return getObj.rows()
    }
    
    
    static func getInvitation(matchingCity city: String, user: String) throws -> Invitation {
        let getObj = Invitation()
        do {
            let p = PGConnection()
            let status = p.connectdb("host=localhost dbname=demo_db")
            defer{
                p.close()
            }
            let result = p.exec(statement: "SELECT * FROM Invitations WHERE userid = '\(user)' AND city = '\(city)'")
            
            let num = result.numTuples()

            if num == 0 {
                
            }
            else{
                var languagesStr = result.getFieldString(tupleIndex: 0, fieldIndex: 2)
                getObj.userid = result.getFieldString(tupleIndex: 0, fieldIndex: 0)!
                getObj.city = result.getFieldString(tupleIndex: 0, fieldIndex: 1)!
                
                languagesStr = languagesStr?.replacingOccurrences(of: "{", with: "")
                languagesStr = languagesStr?.replacingOccurrences(of: "}", with: "")
                getObj.languages = (languagesStr?.components(separatedBy: ","))!
                print(getObj.languages)
                result.clear()
                p.close()
            }
        } catch {
            print("INVITATION LOAD ERROR IN GET INVITATION::1")
        }
        return getObj
    }
    
    func saveInvitation()->String {
        do{
            let p = PGConnection()
            let status = p.connectdb("host=localhost dbname=demo_db")
            defer{
                p.close()
            }
            
            var statement = "INSERT INTO Invitations VALUES ('\(userid)', '\(city)',"
            if languages.count == 0 {
                statement.append("'{}')")
            }
            else{
                statement.append(" '{")
                for x in languages {
                    statement.append(" \"\(x)\" ")
                    if x != languages.last {
                        statement.append(",")
                    }
                }
                statement.append("}')")
            }
            let result = p.exec(statement: statement)
            return String(describing: result.status())
        } catch {
            return "fatalError"
        }
    }
}

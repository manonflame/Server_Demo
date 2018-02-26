import Foundation
import PostgresStORM
import PerfectPostgreSQL

class InvitationAPI {
    
    static func invitationsToDictionary(_ invitations:[Invitation]) -> [[String: Any]]{
        var invitationsJson: [[String: Any]] = []
        for row in invitations {
            invitationsJson.append(row.asDictionary())
        }
        return invitationsJson
    }
    
    static func invitationToDictionary(_ invitation: Invitation) throws -> [String: Any]{
        return invitation.asDictionary()
    }
    
    
    static func getInvitationWithUser(matchingCity city: String, user: String) throws -> String{
        let invitation = try Invitation.getInvitation(matchingCity: city, user: user)
        if invitation.city == ""{
            var nothingJSON : [[String: Any]] = []
            return try nothingJSON.jsonEncodedString()
        }
        var  dictionary = try invitationToDictionary(invitation)
        
        do{
            let p = PGConnection()
            let status = p.connectdb("host=localhost dbname=demo_db")
            defer{
                p.close()
            }
            let result = p.exec(statement: "SELECT ENCODE(profileImage,'base64') FROM Users WHERE id = '\(user)';")
            
            dictionary["profileImage"] = result.getFieldString(tupleIndex: 0, fieldIndex: 0)
        }
        
        
        return try dictionary.jsonEncodedString()
    }
    
    
    static func getInvitations(matchingCity city: String) throws -> String{
        let invitations = try Invitation.getInvitations(matchingCity: city)
        
        return try invitationsToDictionary(invitations).jsonEncodedString()
    }
    
    static func newInvitation(withUserid userid: String, city: String, languages: [String]) throws -> String {
        let invitation = Invitation()
        invitation.userid = userid
        invitation.city = city
        invitation.languages = languages
        return invitation.saveInvitation()
    }

    
    static func newInvitation(withJSONRequest json: String?) throws -> String {
        guard let json = json,
        let dict = try json.jsonDecode() as? [String: Any],
        let userid = dict["userid"] as? String,
            let city = dict["city"] as? String,
            let languages = dict["languages"] as? [String] else {
                    return "Invalid parameters"
        }

        return try newInvitation(withUserid: userid, city: city, languages: languages).jsonEncodedString()
    }
    
    
}

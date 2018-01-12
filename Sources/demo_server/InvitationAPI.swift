import Foundation

class InvitationAPI {
    
    static func invitationsToDictionary(_ invitations:[Invitation]) -> [[String: Any]]{
        var invitationsJson: [[String: Any]] = []
        for row in invitations {
            invitationsJson.append(row.asDictionary())
        }
        return invitationsJson
    }
    
    static func matchingCity(_ matchingCity: String) throws -> String {
        let invitations = try Invitation.getInvitation(matchingCity: matchingCity)
        return try invitationsToDictionary(invitations).jsonEncodedString()
    }
    
    static func matchingCity(withJSONRequest json: String?) throws -> String {
        guard let json = json,
        let dict = try json.jsonDecode() as? [String: Any],
            let city = dict["city"] as? String else {
                return "Invalid parameter"
        }
        return try matchingCity(city)
    }
    
    static func newInvitation(withpw pw: String, userid: String, city: String, languages: [String]) throws -> [String: Any] {
        let invitation = Invitation()
        invitation.pw = pw
        invitation.userid = userid
        invitation.city = city
        invitation.languages = languages
        try invitation.save {
            id in invitation.id = id as! Int
        }
        return invitation.asDictionary()
    }
    

    
    static func newInvitation(withJSONRequest json: String?) throws -> String {
        guard let json = json,
        let dict = try json.jsonDecode() as? [String: Any],
            let pw = dict["pw"] as? String,
            let userid = dict["userid"] as? String,
            let city = dict["city"] as? String,
            let languages = dict["languages"] as? [String] else {
                    return "Invalid parameters"
        }
        
        return try newInvitation(withpw: pw, userid: userid, city: city, languages: languages).jsonEncodedString()
    }
    
}

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer


final class BasicController {
    var routes: [Route] {
        return [
            Route(method: .post, uri: "/newInvitation", handler: newInvitation),
            Route(method: .post, uri: "/signin", handler: signin),
            Route(method: .post, uri: "/sendingMessage", handler: messageArrived),
            Route(method: .post, uri: "/login", handler: login),
            Route(method: .get, uri: "/getInvitaion/{city}/{user}", handler: getInvitation),
            Route(method: .get, uri: "/searchInvitations/{city}", handler: searchInvitations)
        ]
    }
    
    //초대 목록을 """도시로만"""" 검색함
    func searchInvitations(request: HTTPRequest, response: HTTPResponse) {
        guard let city = request.urlVariables["city"] else {
            response.completed(status: .badRequest)
            return
        }
        do{
            let json = try InvitationAPI.getInvitations(matchingCity: city)
            response.setBody(string: json).setHeader(.contentType, value: "application/json").completed()
        }  catch {
            response.setBody(string: "Error handling request: \(error)").completed(status: .internalServerError)
        }
    }
    
    func messageArrived(request: HTTPRequest, response: HTTPResponse){
        print(request.postBodyString!)
        var dic = [String: String]()
        //유저 테이블에 데이터들을 넣음
        if let data = request.postBodyString!.data(using: .utf8) {
            do {
                dic = (try JSONSerialization.jsonObject(with: data, options: []) as? [String : String])!
            } catch {
                print(error.localizedDescription)
            }
        }
        
        print("testtest : \((dic["message"])!)")
        Messenger.insertIntoUserTable(to: dic["to"]!, from: dic["from"]!, timeStamp: dic["timeStamp"]!, message: dic["message"]!)
        
        
        //디바이스 토큰이 empty가 아니면 푸시 노티피케이션을 보냄
        do{
            let json = "received"
            response.setBody(string: json).setHeader(.contentType, value: "application/json").completed()
        } catch {
            response.setBody(string: "Error Handling Requset: \(error)").completed(status: .internalServerError)
        }
    }
    
    func getInvitation(request: HTTPRequest, response: HTTPResponse) {
        guard let city = request.urlVariables["city"] else {
            response.completed(status: .badRequest)
            return
        }
        guard let user = request.urlVariables["user"] else {
            response.completed(status: .badRequest)
            return
        }
        do{
            let json = try InvitationAPI.getInvitationWithUser(matchingCity: city, user: user)
            response.setBody(string: json).setHeader(.contentType, value: "application/json").completed()
        } catch {
            response.setBody(string: "Error handling request: \(error)").completed(status: .internalServerError)
        }
    }
    

    
    func newInvitation(request: HTTPRequest, response: HTTPResponse) {
        do{
            print("newInvitation()")
            let json = try InvitationAPI.newInvitation(withJSONRequest: request.postBodyString)
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        }catch{
            response.setBody(string: "Error handling request: \(error)").completed(status: .internalServerError)
        }
    }
    
    func signin(request: HTTPRequest, response: HTTPResponse) {
        do {
            
            let json = try UserAPI.newUser(withJSONRequest: request.postBodyString)
            print("sign in() :: \(json)")
            response.setBody(string: json).setHeader(.contentType, value: "application/json").completed()
            
        } catch {
            response.setBody(string: "Error handling request: \(error)").completed(status: .internalServerError)
        }
    }
    
    func login(request: HTTPRequest, response: HTTPResponse) {
        do {
            print("log in()")
            let json = try UserAPI.loginUser(withJSONRequest: request.postBodyString)
            
            response.setBody(string: json).setHeader(.contentType, value: "application/json").completed()
            
        } catch {
            response.setBody(string: "Error handling request: \(error)").completed(status: .internalServerError)
        }
    }
}

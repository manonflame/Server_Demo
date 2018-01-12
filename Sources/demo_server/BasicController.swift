import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

final class BasicController {
    var routes: [Route] {
        return [
            Route(method: .get, uri:"/test", handler: test),
            Route(method: .post, uri: "/search", handler: search),
            Route(method: .post, uri: "/new", handler: new),
            Route(method: .post, uri: "/signin", handler: signin)
        ]
    }
    
    func test(request: HTTPRequest, response: HTTPResponse) {
        do{
            let res = "hihihi"
            response.setBody(string: res)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func search(request: HTTPRequest, response: HTTPResponse) {
        do{
           let json = try InvitationAPI.matchingCity(withJSONRequest: request.postBodyString)
            response.setBody(string: json).setHeader(.contentType, value: "application/json").completed()
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func new(request: HTTPRequest, response: HTTPResponse) {
        do{
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
            response.setBody(string: json).setHeader(.contentType, value: "application/json").completed()
            
        } catch {
            response.setBody(string: "Error handling request: \(error)").completed(status: .internalServerError)
        }
    }
}

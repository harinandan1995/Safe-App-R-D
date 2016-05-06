//
//  GlobalFN.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 09/02/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSpinner
import JLToast


public class GlobalFN {
    let basePath = NSBundle.mainBundle().pathForResource("assets", ofType: nil)!
    
    var address: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("serveraddress") as? String {
                return returnValue
            } else {
                return "http://bodhitree3.cse.iitb.ac.in:8080/api" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "serveraddress")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var userid: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("userid") as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "userid")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var passsword: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey("passsword") as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "passsword")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func convertToHtml( question1:String) -> String{
        let question = question1.stringByReplacingOccurrencesOfString("\\n", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var htmlString : String
        let cssPath = self.basePath + "/css/jqmath-0.4.3.css"
        let jsPath1 = self.basePath + "/js/jquery-1.4.3.min.js"
        let jsPath2 = self.basePath + "/js/jqmath-etc-0.4.3.min.js"
        htmlString = "<html><head>"
            + "<link rel='stylesheet' href='"
            + cssPath
            + "'>"
            + "<script src='"
            + jsPath1
            + "'></script>"
            + "<script src='"
            + jsPath2
            + "'></script>"
            + "</head><body>"
            + question
            + "</body></html>"
        return htmlString
    }
    
    func getSummary(responseDic : [String: AnyObject]) -> String {
        var output = ""
        let showMarksTag = responseDic["show_marks"] as! Int
        let showAnswersTag = responseDic["show_answers"] as! Int
        var responses = responseDic["responses"] as! [[String : AnyObject]]
        for i in 0..<responses.count {
            output = output + String(i+1) + ": " + String(responses[i]["question"]!) + "<br>"
            output = output + "Given answer: " + String(responses[i]["given_answer"]!) + "<br>"
            if(showAnswersTag == 1) {
                output = output + "Correct answer: " + String(responses[i]["correct_answer"]!) + "<br>"
            }
            if(showMarksTag == 1) {
                output = output + "Marks obtained: " + String(responses[i]["marks_obtained"]!) + "<br>"
            }
            output = output + "Result: " + String(responses[i]["result"]!) + "<br>"
            let options = responses[i]["options"] as! [[String : AnyObject]]
            if (options.count > 0) {
                output = output + "Options: <br>"
            }
            for j in 0..<options.count {
                output = output + String(j+1) + ": " + String(options[j]["text"]!) + "<br>"
            }
            output = output + "<br>"
        }
        //debugPrint(output)
        output = convertToHtml(output)
        //debugPrint(output)
        return output
    }
    
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let interface = ptr.memory
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface.ifa_addr.memory.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    if let name = String.fromCString(interface.ifa_name) where name == "en0" {
                        
                        // Convert interface address to a human readable string:
                        var addr = interface.ifa_addr.memory
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        getnameinfo(&addr, socklen_t(interface.ifa_addr.memory.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String.fromCString(hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }

    
    func addLog(log : String,quizID : String, uniqID: String,log_level:Int){
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        var message = [String : AnyObject]()
        message["msg"] = log
        message["log_level"] = log_level
        message["time"] = formatter.stringFromDate(now)
        
        var unicodeString :String!
        unicodeString = ""
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(message, options: NSJSONWritingOptions.PrettyPrinted)
            unicodeString = String(data: jsonData, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print(error)
        }
        
        let headers = [
            "Content-Type": "text/html"
        ]
        let parameters : [String : AnyObject] = [
            "uniq_id" : uniqID,
            "quiz_id" : quizID,
            "key" : 123,
            "message" : unicodeString
        ]
        Alamofire.request(.POST, GlobalFN().address+"/add-log", headers: headers, parameters: parameters, encoding: .JSON).response { request, response, data, error in
            //debugPrint(response)
            //debugPrint(error)
            //debugPrint(request)
        
            if(error == nil){
                
            }
            else {
                JLToast.makeText("Please check your internet connection", duration: JLToastDelay.ShortDelay).show()
            }
        }
    }
    
    func uploadImage(quizID:String, uniqID:String, quesID:Int, img :UIImage){
        /*debugPrint("uploading Image")
        debugPrint(quizID)
        debugPrint(uniqID)
        debugPrint(quesID)*/
        let imageData = UIImageJPEGRepresentation(img,0.2)
        
        //let base64String = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters : [String : AnyObject] = [
            "image" : "something.png",
            "uniq_id" : uniqID,
            "quiz_id" : quizID,
            "key" : "123",
            "question_id" : String(quesID)
        ]
        
        Alamofire.upload(.POST, GlobalFN().address+"/quiz/upload-image", headers: headers,multipartFormData: {
            multipartFormData in
            
            multipartFormData.appendBodyPart(data: imageData!, name: "image", fileName: uniqID, mimeType: "image/png")
            //multipartFormData.appendBodyPart(data: data, name: "image", fileName: "file.png", mimeType: "image/png")
            
            for (key, value) in parameters {
                debugPrint(key)
                debugPrint(value)
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            
            },encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response.result.value)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
}
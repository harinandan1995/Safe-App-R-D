//
//  GlobalFN.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 09/02/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import Foundation
import Alamofire

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
    
    func addLog(log : String){
        
    }
    
}
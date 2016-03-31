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
    
    func getSummary(quizID: String, submissionID:String, uniqueID:String) -> String {
        /*debugPrint(quizID)
        debugPrint(submissionID)
        debugPrint(uniqueID)*/
        var output:String?
        output = "Error"
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters : [String : AnyObject] = [
            "quiz_id" : quizID,
            "uniq_id" : uniqueID,
            "key" : 123,
            "submission_id" : submissionID
        ]
        Alamofire.request(.POST, GlobalFN().address+"/quiz/summary", headers: headers, parameters: parameters, encoding: .JSON).responseJSON { response in
            if(response.result.error == nil){
                if let responseDic = response.result.value as? [String: AnyObject]{
                    debugPrint(responseDic)
                    if(String(responseDic["error"]!) == "1") {
                        output = String(responseDic["message"])
                    }
                    else{
                        output = String(responseDic)
                    }
                }
            }
            else {
                //debugPrint(response.result.error)
                output = "ERROR"
            }
            
        }

        
        return output!
    }
    
}
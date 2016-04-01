//
//  SummaryViewController.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 09/02/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import JLToast

class SummaryViewController: UIViewController {
    var uniq_id : String!
    var quiz_id : String!
    var submission_id : String!
    @IBOutlet var summaryWebView : UIWebView!
    let baseUrl = NSURL(string: NSBundle.mainBundle().pathForResource("assets", ofType: nil)!)

    @IBAction func exitTapped(sender :AnyObject) {
        exit(0)
    }
    
    func getSummary(){
        SwiftSpinner.show("Getting Summary")
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters : [String : AnyObject] = [
            "uniq_id" : self.uniq_id,
            "quiz_id" : self.quiz_id,
            "key" : 123
        ]
        Alamofire.request(.POST, GlobalFN().address+"/quiz/summary", headers: headers, parameters: parameters, encoding: .JSON).responseJSON { response in
            if(response.result.error == nil){
                if let responseDic = response.result.value as? [String: AnyObject]{
                    if(String(responseDic["error"]!) != "1") {
                        self.summaryWebView.loadHTMLString(GlobalFN().getSummary(responseDic), baseURL: self.baseUrl)
                    }
                    JLToast.makeText(String(responseDic["message"]!), duration: JLToastDelay.ShortDelay).show()
                    SwiftSpinner.hide()
                }
            }
            else {
                //debugPrint(response.result.error)
                JLToast.makeText("Please check your internet connection", duration: JLToastDelay.ShortDelay).show()
                SwiftSpinner.hide()
                
            }
            
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSummary()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

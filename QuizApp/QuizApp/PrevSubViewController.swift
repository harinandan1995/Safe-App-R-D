//
//  PrevSubViewController.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 13/03/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import JLToast

class PrevSubViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var prevTableView:UITableView!
    var prevSubmissions = [QuizDetails]()
    var ldap_id : String?
    
    
    
    @IBAction func backTapped(sender :AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func getDetails(){
        SwiftSpinner.show("Fetching submissions")
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters : [String : AnyObject] = [
            "ldap_id" : self.ldap_id!,
            "key" : 123,
        ]
        Alamofire.request(.POST, GlobalFN().address+"/quiz/get-submissions", headers: headers, parameters: parameters, encoding: .JSON).responseJSON { response in
            if(response.result.error == nil){
                if let responseDic = response.result.value as? [String: AnyObject]{
                    debugPrint(responseDic)
                    if(String(responseDic["error"]!) == "1") {
                        JLToast.makeText(String(responseDic["message"]!), duration: JLToastDelay.ShortDelay).show()
                        SwiftSpinner.hide()
                    }
                    else{
                        if let allquizDic = responseDic["all_submissions"] as? [AnyObject]{
                            for i in 0 ..< allquizDic.count {
                                var quizDic = allquizDic[i] as? [String : AnyObject]
                                let quizDetails = QuizDetails()
                                quizDetails.quiz_description = quizDic!["quiz_description"] as? String
                                quizDetails.quiz_id = quizDic!["quiz_id"] as? String
                                quizDetails.uniq_id = quizDic!["uniq_id"] as? String
                                
                                var submissionsDic = quizDic!["submissions"] as? [[String : AnyObject]]
                                for j in 0 ..< submissionsDic!.count {
                                    let quizSubmission = QuizSubmission()
                                    quizSubmission.sub_id = submissionsDic![j]["id"] as? String
                                    quizSubmission.marks = submissionsDic![j]["marks"] as? String
                                    quizSubmission.time_stamp = submissionsDic![j]["updated_at"] as? String
                                    quizSubmission.downloaded = 0
                                    quizSubmission.summary = "Downloading"
                                    quizDetails.submissions.append(quizSubmission)
                                }
                                //debugPrint(submissionDic!["quiz_description"])
                                //debugPrint(quizDetails.quiz_description)
                                self.prevSubmissions.append(quizDetails)
                                self.prevTableView.reloadData()
                            }
                        }
                        SwiftSpinner.hide()
                    }
                    
                }
            }
            else {
                //debugPrint(response.result.error)
                JLToast.makeText("Please check your internet connection", duration: JLToastDelay.ShortDelay).show()
                SwiftSpinner.hide()
            }
            
        }

    }
    
    func tableView(tableview : UITableView, numberOfRowsInSection section: Int) -> Int {
        return prevSubmissions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = "prevsubcell"
        var cell:PrevSubmTableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? PrevSubmTableViewCell
        
        if cell == nil {
            prevTableView.registerNib(UINib(nibName: "PrevSubmTableViewCell", bundle:nil), forCellReuseIdentifier: identifier)
            cell = (tableView.dequeueReusableCellWithIdentifier(identifier) as? PrevSubmTableViewCell)!
        }
        
        let quizDetails = prevSubmissions[indexPath.row]
        cell.quizID.text = quizDetails.quiz_id
        cell.quizDescription.text = quizDetails.quiz_description
        cell.noSubmissions.text = String(quizDetails.submissions.count) + " Submissions"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("SubmissionViewController") as! SubmissionViewController
        vc.quizID = prevSubmissions[indexPath.row].quiz_id
        vc.quizSubmission += prevSubmissions[indexPath.row].submissions
        vc.uniqueID = prevSubmissions[indexPath.row].uniq_id
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 96
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.prevTableView.registerClass(PrevSubmTableViewCell.self, forCellReuseIdentifier: "prevsubcell")
        getDetails()
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

//
//  SubmissionViewController.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 13/03/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit
import Alamofire

class SubmissionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var quizSubmission = [QuizSubmission]()
    var quizID:String?
    var tap:Int?
    var uniqueID:String?
    @IBOutlet var subTableView:UITableView!
    @IBOutlet var quizIDLabel:UILabel!
    let baseUrl = NSURL(string: NSBundle.mainBundle().pathForResource("assets", ofType: nil)!)
    
    @IBAction func backTapped(sender :AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    func tableView(tableview : UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizSubmission.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = "subCell"
        var cell:SubmissionTableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? SubmissionTableViewCell
        
        if cell == nil {
            subTableView.registerNib(UINib(nibName: "SubmissionTableViewCell", bundle:nil), forCellReuseIdentifier: identifier)
            cell = (tableView.dequeueReusableCellWithIdentifier(identifier) as? SubmissionTableViewCell)!
        }
        
        let submissionDetails = quizSubmission[indexPath.row]
        cell.number.text = String(indexPath.row+1)
        cell.marks.text = "Marks " + submissionDetails.marks!
        cell.timestamp.text = submissionDetails.time_stamp
        if(tap == indexPath.row) {
            cell.details.hidden = false
            cell.details.loadHTMLString(submissionDetails.summary!, baseURL: self.baseUrl)
        }
        else {
            cell.details.hidden = true
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tap == indexPath.row) {
            tap = -1;
            subTableView.reloadData()
        }
        else{
            tap = indexPath.row
            let submissionDetails = quizSubmission[indexPath.row]
            if(submissionDetails.downloaded == 0){
                let headers = [
                    "Content-Type": "application/x-www-form-urlencoded"
                ]
                let parameters : [String : AnyObject] = [
                    "quiz_id" : self.quizID!,
                    "uniq_id" : self.uniqueID!,
                    "key" : 123,
                    "submission_id" : submissionDetails.sub_id!
                ]
                Alamofire.request(.POST, GlobalFN().address+"/quiz/summary", headers: headers, parameters: parameters, encoding: .JSON).responseJSON { response in
                    if(response.result.error == nil){
                        if let responseDic = response.result.value as? [String: AnyObject]{
                            debugPrint(responseDic)
                            if(String(responseDic["error"]!) == "1") {
                                submissionDetails.summary = GlobalFN().convertToHtml(String(responseDic["message"]))
                            }
                            else{
                                submissionDetails.downloaded = 1
                                submissionDetails.summary = GlobalFN().getSummary(responseDic)
                            }
                        }
                    }
                    else {
                        //debugPrint(response.result.error)
                        submissionDetails.summary = "Please check your internet connection"
                    }
                    self.subTableView.reloadData()
                    
                }

            }
            //subTableView.reloadData()
        }
        //debugPrint(tap)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(tap == indexPath.row) {return 310}
        return 50
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //debugPrint(quizID)
        //debugPrint(quizSubmission.count)
        quizIDLabel.text = quizID
        tap = -1;
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

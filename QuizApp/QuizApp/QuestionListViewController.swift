//
//  QuestionListViewController.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 28/03/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit

class QuestionListViewController: UIViewController {
    @IBOutlet var quesTableView:UITableView!
    var questionsList:QuestionList?
    var attemptedList=[Question]()
    var unattemptedList=[Question]()
    var tag : Int?
    
    @IBAction func backTapped(sender :AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    func tableView(tableview : UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tag==0) {
            return attemptedList.count
        }
        else{
            return unattemptedList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        var ques = Question()
        if(tag==0) {
            ques = self.attemptedList[indexPath.row]
        }
        else{
            ques = self.unattemptedList[indexPath.row]
        }
        cell.textLabel?.text =  ques.questionNo! + ":  " + ques.question!
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var userInfo = [String:AnyObject]()
        if(self.tag == 0) {
            userInfo["questionID"] = self.attemptedList[indexPath.row].questionID
            NSNotificationCenter.defaultCenter().postNotificationName("questionListNotification", object: nil, userInfo: userInfo)
        }
        else{
            userInfo["questionID"] = self.unattemptedList[indexPath.row].questionID
            NSNotificationCenter.defaultCenter().postNotificationName("questionListNotification", object: nil, userInfo: userInfo)

        }
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            self.tag = 0
            quesTableView.reloadData()
        case 1:
            self.tag = 1
            quesTableView.reloadData()
        default:
            break;
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tag = 1
        for var j=0; j<questionsList?.questions.count; j += 1 {
            let cur = questionsList?.questions[j]
            if(cur?.questionType != 1 && cur?.questionType != 2) {
                if(cur?.answer[0] != "") {
                    self.attemptedList.append(cur!)
                }
                else{
                    self.unattemptedList.append(cur!)
                }
            }
            else{
                if(cur?.answer.count != 0) {
                    self.attemptedList.append(cur!)
                }
                else{
                    self.unattemptedList.append(cur!)
                }
            }
        }
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

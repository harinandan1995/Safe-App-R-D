//
//  QuestionViewController.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 09/02/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit
import SwiftSpinner
import JLToast
import Alamofire

class QuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {
    var uniq_id : String!
    var quiz_id : String!
    var duration : Int!
    var timer = NSTimer()
    let questionsList = QuestionList()
    let baseUrl = NSURL(string: NSBundle.mainBundle().pathForResource("assets", ofType: nil)!)
    var currentQuestion = Question()
    
    @IBOutlet var questionWebView : UIWebView! //Question text view
    @IBOutlet var optionsTableView : UITableView! //Question text view
    @IBOutlet var submitButton : UIButton! //Submit button
    @IBOutlet var clearButton : UIButton! //Button to clear the options
    @IBOutlet var timerLabel : UILabel! //Textview to show timer
    @IBOutlet var questionIDTextView : UILabel! //Textview to show question id
    @IBOutlet var nextButton : UIButton! //Next button
    @IBOutlet var prevButton : UIButton! //Previous button
    @IBOutlet var nextButtonImage : UIImageView! //Next button image
    @IBOutlet var prevButtonImage : UIImageView! //Previous button image
    @IBOutlet var answerTextfield : UITextField! //Textfield for integer float type answers
    @IBOutlet var questionImage : UIImageView!
    @IBOutlet var questionImageButton : UIButton!
    
    
    func convertTime(seconds:Int) -> String{
        let output : String!
        var sec :Int
        sec = seconds%60
        var min :Int
        min = (seconds-sec)/60
        let temp = min
        min = min%60
        var hour : Int
        hour = (temp-min)/60
        
        output = String(format: "%02d", hour) + ":" + String(format: "%02d", min) + ":" + String(format: "%02d", sec)
        return output
    }
    
    func updateTime(){
        if(duration<=30) {
            timerLabel.textColor = UIColor.redColor()
        }
        if(duration <= 0) {
            return
        }
        timerLabel.text = convertTime(duration)
        duration = duration-1
    }
    
    
    
    func getImage(quesNo : String, questionIndex : Int) {
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters : [String : AnyObject] = [
            "uniq_id" : self.uniq_id,
            "quiz_id" : self.quiz_id,
            "key" : 123,
            "question_no" : quesNo
        ]
        Alamofire.request(.POST, GlobalFN().address+"/quiz/get-image", headers: headers, parameters: parameters, encoding: .JSON).responseData { response in
            if(response.result.error == nil){
                if let imageData = response.data{
                    self.questionsList.questions[questionIndex].imageData = imageData
                }
            }
            else {
                //debugPrint(response.result.error)
                JLToast.makeText("Please check your internet connection", duration: JLToastDelay.ShortDelay).show()
                
            }
            
        }
    }
    
    func getQuestions(){
        SwiftSpinner.show("Downloading quiz")
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters : [String : AnyObject] = [
            "uniq_id" : self.uniq_id,
            "quiz_id" : self.quiz_id,
            "key" : 123
        ]
        Alamofire.request(.POST, GlobalFN().address+"/quiz/get", headers: headers, parameters: parameters, encoding: .JSON).responseJSON { response in
            //debugPrint(response)
            if(response.result.error == nil){
                if let responseDic = response.result.value as? [String: AnyObject]{
                    debugPrint(responseDic)
                    if(String(responseDic["error"]!) == "1") {
                        JLToast.makeText(String(responseDic["message"]!), duration: JLToastDelay.ShortDelay).show()
                        self.dismissViewControllerAnimated(true, completion: {});
                        SwiftSpinner.hide()
                    }
                    else{
                        self.questionsList.quizDescription = responseDic["quiz_description"] as? String
                        self.questionsList.duration = responseDic["quiz_duration"] as? Int
                        self.questionsList.shuffleOptions = responseDic["randomize_options"] as? Int
                        self.questionsList.shuffleQues = responseDic["randomize_questions"] as? Int

                        JLToast.makeText(String(responseDic["quiz_description"]!), duration: JLToastDelay.ShortDelay).show()
                        
                        var questionsDic = responseDic["questions"] as? [[String : AnyObject]]
                        for j in 0 ..< questionsDic!.count {
                            let question = Question()
                            var tempDic = questionsDic![j]
                            question.hasImage = (tempDic["has_image"] as! NSString).integerValue
                            question.questionID = tempDic["id"] as? Int
                            question.marks = tempDic["marks"] as? String
                            question.question = tempDic["question"] as? String
                            question.questionNo = tempDic["question_no"] as? String
                            question.questionType = tempDic["type"] as? Int
                            
                           
                            
                            if(question.questionType == 1 || question.questionType == 2){
                                var optionsDic = tempDic["options"] as? [[String : AnyObject]]
                                for k in 0 ..< optionsDic!.count {
                                    let tempOption = Option()
                                    tempOption.optionID = optionsDic![k]["id"] as? String
                                    tempOption.optionText = optionsDic![k]["text"] as? String
                                    question.options.append(tempOption)
                                }
                            }
                            else{
                                question.answer.append("")
                            }
                            self.questionsList.questions.append(question)
                        }
                        self.questionsList.shuffleUp()
                        for k in 0..<self.questionsList.questions.count {
                            let question = self.questionsList.questions[k]
                            if(question.hasImage == 1) {
                                self.getImage(question.questionNo!, questionIndex: k)
                            }
                        }
                        self.duration = self.questionsList.duration
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(QuestionViewController.updateTime), userInfo: nil, repeats: true)
                        
                        if(self.questionsList.questions.count <= 1) {
                            self.nextButton.enabled = false
                            self.prevButton.enabled = false
                            self.nextButtonImage.hidden = true
                            self.prevButtonImage.hidden = true
                        }
                        else{
                            self.prevButton.enabled = false
                            self.prevButtonImage.hidden = true
                        }
                        self.currentQuestion = self.questionsList.nextQuestion()!
                        self.questionIDTextView.text = "Question " + self.currentQuestion.qNo!
                        self.questionWebView.loadHTMLString(GlobalFN().convertToHtml(self.currentQuestion.question!), baseURL: self.baseUrl)
                        if(self.currentQuestion.questionType != 1 && self.currentQuestion.questionType != 2) {
                            self.answerTextfield.hidden = false
                            self.optionsTableView.hidden = true
                        }
                        else{
                            self.answerTextfield.hidden = true
                            self.optionsTableView.hidden = false
                        }
                        if(self.currentQuestion.hasImage == 1){
                            self.questionImage.hidden = false
                            self.questionImageButton.enabled = true
                        }
                        else {
                            self.questionImage.hidden = true
                            self.questionImageButton.enabled = false
                        }

                        self.optionsTableView.reloadData()
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
    
    @IBAction func prevButtonTapped(sender : AnyObject) {
        self.currentQuestion = self.questionsList.prevQuestion()!
        self.questionIDTextView.text = "Question " + self.currentQuestion.qNo!
        self.questionWebView.loadHTMLString(GlobalFN().convertToHtml(self.currentQuestion.question!), baseURL: self.baseUrl)
        if(self.currentQuestion.questionType != 1 && self.currentQuestion.questionType != 2) {
            self.answerTextfield.hidden = false
            self.optionsTableView.hidden = true
            self.answerTextfield.text = currentQuestion.answer[0]
        }
        else{
            self.answerTextfield.hidden = true
            self.optionsTableView.hidden = false
        }
        if(self.currentQuestion.hasImage == 1){
            self.questionImage.hidden = false
            self.questionImageButton.enabled = true
        }
        else {
            self.questionImage.hidden = true
            self.questionImageButton.enabled = false
        }

        self.optionsTableView.reloadData()
        self.nextButton.enabled = true
        self.nextButtonImage.hidden = false
        if(questionsList.currentQuestion == 0){
            self.prevButton.enabled = false
            self.prevButtonImage.hidden = true
        }
        //debugPrint(questionsList.currentQuestion)
    }
    
    @IBAction func nextButtonTapped(sender : AnyObject) {
        
        self.currentQuestion = self.questionsList.nextQuestion()!
        self.questionIDTextView.text = "Question " + self.currentQuestion.qNo!
        self.questionWebView.loadHTMLString(GlobalFN().convertToHtml(self.currentQuestion.question!), baseURL: self.baseUrl)
        if(self.currentQuestion.questionType != 1 && self.currentQuestion.questionType != 2) {
            self.answerTextfield.hidden = false
            self.optionsTableView.hidden = true
            self.answerTextfield.text = currentQuestion.answer[0]
        }
        else{
            self.answerTextfield.hidden = true
            self.optionsTableView.hidden = false
        }
        if(self.currentQuestion.hasImage == 1){
            self.questionImage.hidden = false
            self.questionImageButton.enabled = true
        }
        else {
            self.questionImage.hidden = true
            self.questionImageButton.enabled = false
        }

        self.optionsTableView.reloadData()
        self.prevButton.enabled = true
        self.prevButtonImage.hidden = false
        if(questionsList.currentQuestion == questionsList.questions.count-1){
            self.nextButton.enabled = false
            self.nextButtonImage.hidden = true
        }
        //debugPrint(questionsList.currentQuestion)
    }
    
    @IBAction func answerEdited(sender : UITextField) {
        currentQuestion.answer.removeAll()
        currentQuestion.answer.append(sender.text!)
    }
    
    @IBAction func imageTapped(sender: UITapGestureRecognizer) {
        if(currentQuestion.hasImage == 1){
            let newImageView = UIImageView()
            newImageView.image = UIImage(data: currentQuestion.imageData!)
            newImageView.frame = self.view.frame
            newImageView.backgroundColor = .blackColor()
            newImageView.contentMode = .ScaleAspectFit
            newImageView.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(QuestionViewController.dismissFullscreenImage(_:)))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
        }
        else{
            JLToast.makeText("No image present for this question", duration: JLToastDelay.ShortDelay).show()
        }
        
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    @IBAction func clearButtonTapped(sender : AnyObject) {
        currentQuestion.answer.removeAll()
        if(self.currentQuestion.questionType != 1 && self.currentQuestion.questionType != 2) {
            answerTextfield.text = ""
            currentQuestion.answer.append("")
        }
        else{
            optionsTableView.reloadData()
        }
    }
    
    @IBAction func listButtonTapped(sender : AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionListViewController") as! QuestionListViewController
        vc.questionsList = self.questionsList
        self.presentViewController(vc, animated: false, completion: nil)

    }
    
    
    func tableView(tableview : UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQuestion.options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier:String = "optCell"
        var cell:OptionTableViewCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? OptionTableViewCell
        
        if cell == nil {
            optionsTableView.registerNib(UINib(nibName: "OptionTableViewCell", bundle:nil), forCellReuseIdentifier: identifier)
            cell = (tableView.dequeueReusableCellWithIdentifier(identifier) as? OptionTableViewCell)!
        }
        
        let option = currentQuestion.options[indexPath.row]
        
        cell.contentView.addSubview(cell.optionWebView)
        cell.optionWebView.tag = indexPath.row
        cell.optionWebView.delegate = self
        cell.optionWebView.loadHTMLString(GlobalFN().convertToHtml(option.optionText!), baseURL: self.baseUrl)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if currentQuestion.answer.contains(currentQuestion.options[indexPath.row].optionID!){
            if(currentQuestion.questionType == 1){
                cell.buttonImage.image = UIImage(named:"newMoonBlack.png")
            }
            else{
                cell.buttonImage.image = UIImage(named:"Checked Checkbox 2-96.png")
            }
        }
        else{
            if(currentQuestion.questionType == 1){
                cell.buttonImage.image = UIImage(named:"fullMoonBlack.png")
            }
            else{
                cell.buttonImage.image = UIImage(named:"Unchecked Checkbox-96.png")
            }
        }
        
        //let htmlHeight = option.height
        //cell.optionWebView.frame = CGRectMake(0, 0, cell.optionWebView.frame.width, 100)
        
        /*debugPrint("HTML height")
        debugPrint(htmlHeight)
        debugPrint(cell.optionWebView.frame.height)
        debugPrint(indexPath.row)*/
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        debugPrint(indexPath.row)
        if currentQuestion.answer.contains(currentQuestion.options[indexPath.row].optionID!){
            if(currentQuestion.questionType == 2){
                currentQuestion.answer.removeAtIndex((currentQuestion.answer.indexOf(currentQuestion.options[indexPath.row].optionID!))!)
            }
        }
        else{
            if(currentQuestion.questionType == 1){
                currentQuestion.answer.removeAll()
            }
            currentQuestion.answer.append(currentQuestion.options[indexPath.row].optionID!)
        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(currentQuestion.options[indexPath.row].height)
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
        var frame = webView.frame
        let fittingSize = webView.sizeThatFits(CGSizeZero)
        frame.size = fittingSize
        
        webView.frame = CGRectMake(52, 5, frame.size.width, frame.size.height)
        if (currentQuestion.options[webView.tag].height != 0.0){
            return
        }
        
        currentQuestion.options[webView.tag].height = Float(webView.scrollView.contentSize.height)
        optionsTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: webView.tag, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    @objc func questionListTapped(notification: NSNotification){
        let userInfo : [String:AnyObject!] = notification.userInfo as! [String:AnyObject!]
        let id = userInfo["questionID"] as! Int
        for j in 0 ..< self.questionsList.questions.count {
            if(self.questionsList.questions[j].questionID == id){
                currentQuestion = self.questionsList.questions[j]
                self.questionsList.currentQuestion = j
                self.questionIDTextView.text = "Question " + self.currentQuestion.qNo!
                self.questionWebView.loadHTMLString(GlobalFN().convertToHtml(self.currentQuestion.question!), baseURL: self.baseUrl)
                if(self.currentQuestion.questionType != 1 && self.currentQuestion.questionType != 2) {
                    self.answerTextfield.hidden = false
                    self.optionsTableView.hidden = true
                    self.answerTextfield.text = currentQuestion.answer[0]
                }
                else{
                    self.answerTextfield.hidden = true
                    self.optionsTableView.hidden = false
                }
                if(self.currentQuestion.hasImage == 1){
                    self.questionImage.hidden = false
                    self.questionImageButton.enabled = true
                }
                else {
                    self.questionImage.hidden = true
                    self.questionImageButton.enabled = false
                }

                self.optionsTableView.reloadData()
                if(questionsList.currentQuestion == questionsList.questions.count-1){
                    self.nextButton.enabled = false
                    self.nextButtonImage.hidden = true
                }
                else{
                    self.nextButton.enabled = true
                    self.nextButtonImage.hidden = false
                }
                if(questionsList.currentQuestion == 0){
                    self.prevButton.enabled = false
                    self.prevButtonImage.hidden = true
                }
                else{
                    self.prevButton.enabled = true
                    self.prevButtonImage.hidden = false
                }
                return
            }
        }
        
    }
    
    @IBAction func submitButtonTapped(sender : AnyObject) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to submit?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.view.tintColor = UIColor.blackColor()
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { action in
            SwiftSpinner.show("Submitting quiz")
            var submission = [[String:AnyObject]]()
            for i in 0 ..< self.questionsList.questions.count  {
                let temp_question = self.questionsList.questions[i]
                var temp = [String : AnyObject]()
                temp["question_id"] = temp_question.questionID
                temp["response"] = temp_question.answer
                submission.append(temp)
            }
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            let parameters : [String : AnyObject] = [
                "uniq_id" : self.uniq_id,
                "quiz_id" : self.quiz_id,
                "key" : 123,
                "submit_time" : "100",
                "submission" : submission

            ]
            Alamofire.request(.POST, GlobalFN().address+"/quiz/submit", headers: headers, parameters: parameters, encoding: .JSON).responseJSON { response in
                if(response.result.error == nil){
                    if let responseDic = response.result.value as? [String: AnyObject]{
                        debugPrint(responseDic)
                        debugPrint(String(responseDic["error"]))
                        if(String(responseDic["error"]!) != "1") {
                            debugPrint(String(responseDic["show_result"]))
                            if(String(responseDic["show_result"]!) == "1"){
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewControllerWithIdentifier("SummaryViewController") as! SummaryViewController
                                vc.quiz_id = self.quiz_id
                                vc.uniq_id = self.uniq_id
                                self.presentViewController(vc, animated: false, completion: nil)
                            }
                            else{
                                let submitalert = UIAlertController(title: "Hurray!", message: "Quiz has been succesfully submitted", preferredStyle: UIAlertControllerStyle.Alert)
                                submitalert.view.tintColor = UIColor.blackColor()
                                submitalert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.Destructive, handler: { action in
                                    exit(0)
                                }
                                ))
                                self.presentViewController(submitalert, animated: true, completion: nil)
                            }
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

        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Destructive, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getQuestions()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(QuestionViewController.questionListTapped(_:)),
            name: "questionListNotification",
            object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let imageData = data as NSData? {
                    self.image = UIImage(data: imageData)
                }
            }
        }
    }
}

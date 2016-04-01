//
//  QuizIDViewController.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 09/02/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit
import JLToast
import Alamofire
import SwiftSpinner

class QuizIDViewController: UIViewController {

    @IBOutlet var quizIDTextField : UITextField! //QuizID textfield
    @IBOutlet var continueButton : UIButton! //Continue button
    @IBOutlet var nameTextView : UITextView! //Name Text button
    var user_id : String!
    var username : String!
    var unicodes : [String]!
    
    @IBAction func backTapped(sender :AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    @IBAction func prevSubmissionsTapped(sender : AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("PrevSubViewController") as! PrevSubViewController
        vc.ldap_id = self.user_id
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    @IBAction func continueTapped(sender : AnyObject) { //Action when continue button is tapped
        if(self.quizIDTextField.text=="" ){
            JLToast.makeText("Please enter the quiz ID", duration: JLToastDelay.ShortDelay).show()
        }
        else{
            SwiftSpinner.show("Fetching details for quiz with quizid "+self.quizIDTextField.text!)
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            let parameters : [String : AnyObject] = [
                "student_id" : self.user_id,
                "quiz_id" : self.quizIDTextField.text!,
                "student_name" : self.username,
                "key" : 123
            ]
            Alamofire.request(.POST, GlobalFN().address+"/quiz", headers: headers, parameters: parameters, encoding: .JSON).responseJSON { response in
                if(response.result.error == nil){
                    if let responseDic = response.result.value as? [String: AnyObject]{
                        debugPrint(responseDic)
                        if(String(responseDic["error"]!) == "1") {
                            JLToast.makeText(String(responseDic["message"]!), duration: JLToastDelay.ShortDelay).show()
                            SwiftSpinner.hide()
                        }
                        else{
                            let skip_symbol_auth = responseDic["skip_symbol_auth"] as? String
                            //debugPrint(skip_symbol_auth)
                            if(skip_symbol_auth == "0"){
                                let unicode_dic = responseDic["unicodes"] as! [String]
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewControllerWithIdentifier("PasscodeViewController") as! PasscodeViewController
                                vc.uniq_id = responseDic["uniq_id"] as? String
                                vc.unicodes = unicode_dic
                                vc.user_id = self.user_id
                                vc.quiz_id = self.quizIDTextField.text
                                self.presentViewController(vc, animated: false, completion: nil)
                            }
                            else{
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionViewController") as! QuestionViewController
                                vc.uniq_id = responseDic["uniq_id"] as? String
                                vc.quiz_id = self.quizIDTextField.text
                                self.presentViewController(vc, animated: false, completion: nil)
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

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.layer.cornerRadius = 5
        
        //Tap gesture to dismiss keayboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(QuizIDViewController.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        print(user_id)
        if(user_id != ""){
            nameTextView.text = username
        }
        // Do any additional setup after loading the view.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }

    func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        quizIDTextField.resignFirstResponder(); //Dismiss keyboard
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

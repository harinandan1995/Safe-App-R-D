//
//  LoginViewController.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 01/02/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit
import Alamofire
import JLToast
import SwiftSpinner

class LoginViewController: UIViewController {

    @IBOutlet var ldapTextField : UITextField! //ID textfield
    @IBOutlet var passwordTextField : UITextField! //Password textfield
    @IBOutlet var loginButton : UIButton! //Login button
    @IBOutlet var settingsButton : UIButton! //Settings button
    @IBOutlet var savepasswordImage : UIImageView! //Savepassword checkbox image
    var savepasswordtag : Int!

    
    @IBAction func loginTapped(sender : AnyObject) { //Action when login button is tapped
        if(self.ldapTextField.text=="" || self.passwordTextField.text == ""){
            JLToast.makeText("Please enter your credentials", duration: JLToastDelay.ShortDelay).show()
        }
        else{
            GlobalFN().userid = self.ldapTextField.text!;
            SwiftSpinner.show("Logging in using "+self.ldapTextField.text!)
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            let parameters : [String : AnyObject] = [
                "ldap_id" : self.ldapTextField.text!,
                "ldap_password" : self.passwordTextField.text!,
                "key" : 123,
                "version" : "1.5"
            ]
            Alamofire.request(.POST, GlobalFN().address+"/ldap-auth", headers: headers, parameters: parameters, encoding: .JSON).responseJSON { response in
                if(response.result.error == nil){
                    if let responseDic = response.result.value as? [String: AnyObject]{
                        //debugPrint(responseDic["message"])
                        //debugPrint(responseDic["student_id"])
                        //debugPrint(responseDic["student_name"])
                        if(String(responseDic["error"]!) == "1") {
                            JLToast.makeText(String(responseDic["message"]!), duration: JLToastDelay.ShortDelay).show()
                            SwiftSpinner.hide()
                        }
                        else{
                            if(self.savepasswordtag == 1) {
                                GlobalFN().passsword = self.passwordTextField.text!
                            }
                            else {
                                GlobalFN().passsword = ""
                            }
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("QuizIDViewController") as! QuizIDViewController
                            vc.user_id = responseDic["student_id"] as? String
                            vc.username = responseDic["student_name"] as? String
                            self.presentViewController(vc, animated: false, completion: nil)
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
    
    @IBAction func savePasswordTapped(sender : AnyObject) {
        if(savepasswordtag == 1) {
            savepasswordtag = 0
            savepasswordImage.image = UIImage(named: "Unchecked Checkbox-96")
        }
        else {
            savepasswordtag = 1
            savepasswordImage.image = UIImage(named: "Checked Checkbox 2-96")
        }
    }
    
    @IBAction func settingsTapped(sender : AnyObject) { //Action when settings button is tapped
        
        let alertController = UIAlertController(title: "Address", message: "Please change only if you are instructed to do so.", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Save", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                GlobalFN().address = field.text!;
                self.view.resignFirstResponder()
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            self.view.resignFirstResponder()
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Server address"
            textField.text = GlobalFN().address
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        
        //Tap gesture to dismiss keayboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        if(GlobalFN().userid != "") {
            ldapTextField.text = GlobalFN().userid
        }
        
        if(GlobalFN().passsword != "") {
            passwordTextField.text = GlobalFN().passsword
        }
        
        savepasswordtag = 1;
        // Do any additional setup after loading the view.
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        ldapTextField.resignFirstResponder(); //Dismiss keyboard
        passwordTextField.resignFirstResponder(); //Dismiss keyboard
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

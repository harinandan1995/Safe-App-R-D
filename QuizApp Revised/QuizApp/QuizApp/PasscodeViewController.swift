//
//  PasscodeViewController.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 09/02/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import UIKit
import SwiftSpinner
import JLToast
import Alamofire

class PasscodeViewController: UIViewController {
    var unicodes : [String]!
    var uniq_id : String!
    var user_id : String!
    var quiz_id : String!
    var finalCode = [String]()
    
    @IBOutlet var button1 : UIButton!
    @IBOutlet var button2 : UIButton!
    @IBOutlet var button3 : UIButton!
    @IBOutlet var button4 : UIButton!
    @IBOutlet var button5 : UIButton!
    @IBOutlet var button6 : UIButton!
    @IBOutlet var button7 : UIButton!
    @IBOutlet var button8 : UIButton!
    @IBOutlet var button9 : UIButton!
    @IBOutlet var button10 : UIButton!
    @IBOutlet var button11 : UIButton!
    @IBOutlet var button12 : UIButton!
    @IBOutlet var button13 : UIButton!
    @IBOutlet var button14 : UIButton!
    @IBOutlet var button15 : UIButton!
    @IBOutlet var button16 : UIButton!
    
    @IBOutlet var passcodeLabel : UILabel!
    
    
    @IBAction func backTapped(sender :AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    @IBAction func clearTapped(sender :AnyObject) {
        finalCode.removeAll()
        passcodeLabel.text = ""
    }
    
    @IBAction func deleteTapped(sender :AnyObject) {
        finalCode.popLast()
        passcodeLabel.text = ""
        for i in 0 ..< finalCode.count {
            let num = UInt16(finalCode[i], radix: 16)
            let code = String(UnicodeScalar(num!))
            passcodeLabel.text = passcodeLabel.text! + code
        }
    }
    
    @IBAction func passcodeButtonPressed(sender :UIButton) {
        print(sender.tag)
        let num = UInt16(unicodes[sender.tag-1], radix: 16)
        let code = String(UnicodeScalar(num!))
        passcodeLabel.text = passcodeLabel.text! + code
        finalCode.append(unicodes[sender.tag-1])
    }

    @IBAction func continueTapped(sender : AnyObject) { //Action when continue button is tapped
        if(finalCode.count == 0){
            JLToast.makeText("Please enter the passcode", duration: JLToastDelay.ShortDelay).show()
        }
        else{
            SwiftSpinner.show("Verifying passcode")
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            var unicodeString :String!
            unicodeString = ""
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(finalCode, options: NSJSONWritingOptions.PrettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                unicodeString = String(data: jsonData, encoding: NSUTF8StringEncoding)
            } catch let error as NSError {
                print(error)
            }
            print(unicodeString)
            let parameters : [String : AnyObject] = [
                "uniq_id" : self.uniq_id,
                "quiz_id" : self.quiz_id,
                "passcode" : unicodeString,
                "key" : 123
            ]
            Alamofire.request(.POST, GlobalFN().address+"/quiz/Auth", headers: headers, parameters: parameters, encoding: .JSON).responseJSON { response in
                //debugPrint(response)
                if(response.result.error == nil){
                    if let responseDic = response.result.value as? [String: AnyObject]{
                        debugPrint(responseDic)
                        if(String(responseDic["error"]!) == "1") {
                            JLToast.makeText(String(responseDic["message"]!), duration: JLToastDelay.ShortDelay).show()
                            SwiftSpinner.hide()
                        }
                        else{
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionViewController") as! QuestionViewController
                            vc.uniq_id = self.uniq_id
                            vc.quiz_id = self.quiz_id
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

    
    
    /* E0AD,
    E0A5,
    E05A,
    E154,
    003A,
    0044,
    0067,
    E027,
    E01C,
    005A,
    E142,
    E127,
    E140,
    0066,
    E029,
    E014*/
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let num1 = UInt16(unicodes[0], radix: 16)
        let code1 = String(UnicodeScalar(num1!))
        button1.setTitle(code1, forState: UIControlState.Normal)
        
        let num2 = UInt16(unicodes[1], radix: 16)
        let code2 = String(UnicodeScalar(num2!))
        button2.setTitle(code2, forState: UIControlState.Normal)
        
        let num3 = UInt16(unicodes[2], radix: 16)
        let code3 = String(UnicodeScalar(num3!))
        button3.setTitle(code3, forState: UIControlState.Normal)
        
        let num4 = UInt16(unicodes[3], radix: 16)
        let code4 = String(UnicodeScalar(num4!))
        button4.setTitle(code4, forState: UIControlState.Normal)
        
        let num5 = UInt16(unicodes[4], radix: 16)
        let code5 = String(UnicodeScalar(num5!))
        button5.setTitle(code5, forState: UIControlState.Normal)
        
        let num6 = UInt16(unicodes[5], radix: 16)
        let code6 = String(UnicodeScalar(num6!))
        button6.setTitle(code6, forState: UIControlState.Normal)
        
        let num7 = UInt16(unicodes[6], radix: 16)
        let code7 = String(UnicodeScalar(num7!))
        button7.setTitle(code7, forState: UIControlState.Normal)
        
        let num8 = UInt16(unicodes[7], radix: 16)
        let code8 = String(UnicodeScalar(num8!))
        button8.setTitle(code8, forState: UIControlState.Normal)
        
        let num9 = UInt16(unicodes[8], radix: 16)
        let code9 = String(UnicodeScalar(num9!))
        button9.setTitle(code9, forState: UIControlState.Normal)
        
        let num10 = UInt16(unicodes[9], radix: 16)
        let code10 = String(UnicodeScalar(num10!))
        button10.setTitle(code10, forState: UIControlState.Normal)
        
        let num11 = UInt16(unicodes[10], radix: 16)
        let code11 = String(UnicodeScalar(num11!))
        button11.setTitle(code11, forState: UIControlState.Normal)
        
        let num12 = UInt16(unicodes[11], radix: 16)
        let code12 = String(UnicodeScalar(num12!))
        button12.setTitle(code12, forState: UIControlState.Normal)
        
        let num13 = UInt16(unicodes[12], radix: 16)
        let code13 = String(UnicodeScalar(num13!))
        button13.setTitle(code13, forState: UIControlState.Normal)
        
        let num14 = UInt16(unicodes[13], radix: 16)
        let code14 = String(UnicodeScalar(num14!))
        button14.setTitle(code14, forState: UIControlState.Normal)
        
        let num15 = UInt16(unicodes[14], radix: 16)
        let code15 = String(UnicodeScalar(num15!))
        button15.setTitle(code15, forState: UIControlState.Normal)
        
        let num16 = UInt16(unicodes[15], radix: 16)
        let code16 = String(UnicodeScalar(num16!))
        button16.setTitle(code16, forState: UIControlState.Normal)

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

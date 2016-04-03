//
//  Question.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 09/02/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import Foundation

public class Question {
    var questionID : Int?
    var questionNo : String?
    var qNo : String?
    var questionType : Int?
    var answer = [String]()
    var question : String?
    var options = [Option]()
    var marks : String?
    var hasImage : Int?
    var imageData : NSData?
    init (questionID1:Int, questionNo1:String, questionType1:Int, question1:String, marks1:String, hasImage1:Int,options1:[Option]){
        questionID = questionID1
        questionNo = questionNo1
        questionType = questionType1
        question = question1
        marks = marks1
        hasImage = hasImage1
        options = options1
    }
    
    init() {
    }
}

//
//  QuestionList.swift
//  QuizApp
//
//  Created by Bhaskaran Raman on 09/02/16.
//  Copyright © 2016 Bhaskaran Raman. All rights reserved.
//

import Foundation

public class QuestionList{
    var quizDescription : String?
    var questions = [Question]()
    var shuffleOptions : Int?
    var shuffleQues : Int?
    var duration : Int?
    var currentQuestion = -1
    var questionOrder : [Int]?
    init (questionList1:[Question], shuffleAns1:Int, shuffleQues1:Int, duration1:Int){
        questions = questionList1
        shuffleOptions = shuffleAns1
        shuffleQues = shuffleQues1
        duration = duration1
        let count = questions.count
        //var randomArray = (1...count).map{_ in arc4random()}*/
        for i in 0...count{
            questionOrder?.append(i)
        }
        //currentQuestion = -1;
    }
    
    init() {}
    
    func shuffleArray<T>(var array: Array<T>) -> Array<T>
    {
        for var index = array.count - 1; index > 0; index -= 1
        {
            // Random int from 0 to index-1
            let j = Int(arc4random_uniform(UInt32(index-1)))
            
            // Swap two array elements
            // Notice '&' required as swap uses 'inout' parameters
            swap(&array[index], &array[j])
        }
        return array
    }
    
    func shuffleUp(){
        if(shuffleQues == 1) {
            debugPrint("Shuffling questions")
            questions = shuffleArray(questions)
        }
        for i in 0..<questions.count {
            if(shuffleQues == 1) {
                questions[i].qNo = String(i+1)
            }
            else {
                questions[i].qNo = questions[i].questionNo
            }
        }
        if(shuffleOptions == 1){
            debugPrint("Shuffling options")
            for i in 0..<questions.count {
                let temp = shuffleArray(questions[i].options)
                questions[i].options.removeAll()
                questions[i].options = temp
            }
        }
    }
    
    func nextQuestion() -> Question? {
        currentQuestion += 1
        if currentQuestion >= questions.count {
            return nil
        }
        return questions[currentQuestion]
    }
    
    func prevQuestion() -> Question? {
        currentQuestion -= 1
        if currentQuestion < 0 {
            return nil
        }
        return questions[currentQuestion]
    }    
    
}

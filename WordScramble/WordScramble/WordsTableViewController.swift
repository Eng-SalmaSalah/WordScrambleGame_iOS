//
//  ViewController.swift
//  WordScramble
//
//  Created by Salma Salah on 2/12/20.
//  Copyright © 2020 Salma Salah. All rights reserved.
//

import UIKit

class WordsTableViewController: UITableViewController,UITextFieldDelegate {

    //here we defined 2 arrays one for all words , the other for the user's answers
    var allWords = [String]()
    var enteredWords = [String]()
    
    //for errorMessages
    var errorTitle : String?
    var errorMessage : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        initGame()
        startGame()
    }
    
    func initGame(){
        readWordsFromFile()
    }
    
    func readWordsFromFile(){
        //first if let : because file may not be found
        //second if let : because it may cannot get string from the file
        //try? means "call this code, and if it throws an error just send me back nil instead." This means the code you call will always work, but you need to unwrap the result carefully.
        
        if let wordsFileURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let allWordsString = try? String(contentsOf: wordsFileURL){
                allWords = allWordsString.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty{
            allWords = ["silkworm"]
        }
    }
    
    @objc func startGame(){
        title = allWords.randomElement()
        enteredWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    //tableView Methods :
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enteredWords.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wordCell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath)
        wordCell.textLabel?.text = enteredWords[indexPath.row]
        return wordCell
    }
    
    @objc func promptForAnswer(){
        let alertController = UIAlertController(title: "Enter Word", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter here:"
        }
        
        let submitAction = UIAlertAction(title: "Enter Answer", style: .default) { [weak self, weak alertController] _ in
            guard let answer = alertController?.textFields?[0].text else {return}
            self?.submitAction(answer: answer)
        }
        submitAction.isEnabled = false
        //the next line to disable button of answer tf is empty 
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:alertController.textFields?[0],queue: OperationQueue.main) { (notification) -> Void in
            let answerTF = alertController.textFields?[0]
            submitAction.isEnabled = !(answerTF?.text?.isEmpty ?? false)
        }
        
        alertController.addAction(submitAction)
        present(alertController,animated: true)
    }
  
    func submitAction(answer:String) {
        let lowerCasedAnswer = answer.lowercased()
        if validateAnswer(answer: lowerCasedAnswer){
            enteredWords.insert(lowerCasedAnswer, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath]
                , with: .automatic) //kda a7sn bdl ma n3ml reload data kol shwya 3lshan da by7tag processing
        }else{
            showErrorMessage()
        }
        
    }
    
    func validateAnswer(answer:String) -> Bool{
        if isNotTheSameWord(answer: answer){
            if isPossible(answer: answer){
                if isNotRepeated(answer: answer){
                    if isRealEnglishWord(answer: answer){
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isPossible(answer:String) -> Bool{
        //to check if the answer can be estracted from the title
        guard var tempWord = title?.lowercased() else {return false}
        for letter in answer{
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position)
            }else{
                guard let title = title?.lowercased() else { return false }
                errorTitle = "Word not possible"
                errorMessage = "You can't spell that word from \(title)"
                return false
            }
        }
        return true
    }
    
 
    func isNotRepeated(answer:String) -> Bool{
        if enteredWords.contains(answer){
            errorTitle = "Word used already"
            errorMessage = "Be more original!"
            return false
        }else{
            return true
        }
    }
    
    func isRealEnglishWord(answer:String) -> Bool{
        //we define text checker that check the spelling of a word
        if answer.utf16.count < 3{
            errorTitle = "Word is too short!"
            errorMessage = "Please Enter a valid word!"
            return false
        }
        let textChecker = UITextChecker()
        
        //here we define the range in the word we need to check spelling in , first param is start,second on is the lenght
        //we used answer.count.utf16 because here we read text of the alert TF (uikit) and uikit is written in obj c,counting sys in obj c is different from swift in special chars or latin letters which may cause problem specially in emojis
        let range = NSRange(location: 0, length: answer.utf16.count)
        
        //rangeOfMisspelledWord : returns the range at which spelling is incorrect,in obj c there is no optional , so if spelling is right it cannot return nil , it returns range with location NSNotFound
        let rangeOfMisspelledWord = textChecker.rangeOfMisspelledWord(in: answer, range: range, startingAt: 0, wrap: false, language: "en")
        if rangeOfMisspelledWord.location == NSNotFound{
            return true
        }else{
            errorTitle = "Word not recognised"
            errorMessage = "You can't just make them up, you know!"
            return false
        }
    }
    
    func isNotTheSameWord(answer:String) -> Bool{
        if answer.lowercased() == title?.lowercased(){
            errorTitle = "Same word entered!"
            errorMessage = "You can't just enter the same word, you know!"
            return false
        }
        return true
    }
    
    func showErrorMessage(){
        let errorAC = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        let errorAlertAction = UIAlertAction(title: "Ok", style: .cancel)
        errorAC.addAction(errorAlertAction)
        present(errorAC,animated: true)
    }
    

}


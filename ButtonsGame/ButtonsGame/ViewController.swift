//
//  ViewController.swift
//  ButtonsGame
//
//  Created by Michael Cai on 2/18/17.
//  Copyright © 2017 theCaiGuy. All rights reserved.
//

import UIKit
import Darwin
import Social

class ViewController: UIViewController {
    @IBOutlet weak var scoreBoard: UILabel!
    @IBOutlet weak var topLeft: UIButton!
    @IBOutlet weak var topRight: UIButton!
    @IBOutlet weak var bottomLeft: UIButton!
    @IBOutlet weak var bottomRight: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var index = 0
    var seq = [Int]()
    var turnNum = 1
    var score = 0
    var lastScore = 0
    
    var scoreToBeat = 0
    let userDefaults = UserDefaults.standard
    let highlightColor = UIColor.yellow
    let alternateHighlightColor = UIColor.red
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topLeft.tag = 0
        topRight.tag = 1
        bottomLeft.tag = 2
        bottomRight.tag = 3
        startButton.showsTouchWhenHighlighted = true
        topLeft.showsTouchWhenHighlighted = true
        topRight.showsTouchWhenHighlighted = true
        bottomLeft.showsTouchWhenHighlighted = true
        bottomRight.showsTouchWhenHighlighted = true
        facebookButton.showsTouchWhenHighlighted = true
        twitterButton.showsTouchWhenHighlighted = true
        toggleButtons(activated: false)
        toggleSocialButtons(hidden: true)
        if let highscore = userDefaults.value(forKey: "highscore") {
            scoreToBeat = highscore as! Int
        } else {
            scoreToBeat = 0
        }
    }
    
    // Highlights the corresponding button yellow for 1 second
    func highlightButton(seqNum: Int, button: UIButton, greenButton: UIColor, purpleButton: UIColor) {
        if (seqNum % 2 == 1) {
            button.backgroundColor = alternateHighlightColor
        } else {
            button.backgroundColor = highlightColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if (button.tag == 0 || button.tag == 3) {
                button.backgroundColor = greenButton
            } else {
                button.backgroundColor = purpleButton
            }
        })
    }
    
    // Another attemp to make a random sequence of ints between 0 and 3
    func makeSequence(seqNum: Int, greenButton: UIColor, purpleButton: UIColor) {
        toggleButtons(activated: false)
        if (seqNum == turnNum) {
            toggleButtons(activated: true)
            return
        }
        let nextButtonNum = Int(arc4random_uniform(4))
        seq.append(nextButtonNum)
        if (nextButtonNum == 0) {
            highlightButton(seqNum: seqNum, button: topLeft, greenButton: greenButton, purpleButton: purpleButton)
        } else if (nextButtonNum == 1) {
            highlightButton(seqNum: seqNum, button: topRight, greenButton: greenButton, purpleButton: purpleButton)
        } else if (nextButtonNum == 2) {
            highlightButton(seqNum: seqNum, button: bottomLeft, greenButton: greenButton, purpleButton: purpleButton)
        } else if (nextButtonNum == 3){
            highlightButton(seqNum: seqNum, button: bottomRight, greenButton: greenButton, purpleButton: purpleButton)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.makeSequence(seqNum: seqNum + 1, greenButton: greenButton, purpleButton: purpleButton)
        })
        return
    }
    
    // Check if the button clicked is the correct one in the sequence
    @IBAction func buttonPressed(_ sender: UIButton) {
        let greenButton = topLeft.backgroundColor!
        let purpleButton = topRight.backgroundColor!
        // Case: Clicked the wrong button
        if (sender.tag != seq[index]) {
            index = 0
            lastScore = score
            score = 0
            scoreBoard.text = "You Lost! (highscore was \(scoreToBeat))"
            scoreBoard.textColor = UIColor.black
            startButton.isEnabled = true
            startButton.isHidden = false
            toggleButtons(activated: false)
            toggleSocialButtons(hidden: false)
            scoreLabel.text = "Share:"
            return
        }
        index+=1
        // Case: button pressed is the last one in the array
        if (index == seq.count) {
            index = 0
            score += 1
            updateScoreboard()
            if (score > scoreToBeat) {
                scoreBoard.text = "\(score) (Highscore!!!)"
                scoreBoard.textColor = UIColor.red
                userDefaults.set(score, forKey: "highscore")
                userDefaults.synchronize()
                scoreToBeat = score
            }
            turnNum += 1
            seq.removeAll()
            makeSequence(seqNum: 0, greenButton: greenButton, purpleButton: purpleButton)
            return
        }
    }
    
    // Updates the scoreboard to the value of score
    func updateScoreboard() {
        scoreBoard.text = "\(score)"
    }

    // Toggles whether the buttons should be enabled or disabled
    func toggleButtons(activated: Bool) {
        topLeft.isEnabled = activated
        topRight.isEnabled = activated
        bottomLeft.isEnabled = activated
        bottomRight.isEnabled = activated
    }
    
    // Shows the FB and Twitter buttons
    func toggleSocialButtons(hidden: Bool) {
        facebookButton.isHidden = hidden
        twitterButton.isHidden = hidden
    }
    
    // Begin the game by pressing start
    @IBAction func startButtonPressed(_ sender: UIButton) {
        // Start the game: turnNum = 1
        turnNum = 1
        
        // Begin with 0 points
        score = 0
        scoreLabel.text = "Score:"
        scoreBoard.text = "0"
        
        // Constant color combos
        let greenButton = topLeft.backgroundColor!
        let purpleButton = topRight.backgroundColor!
        
        // Initial sequence of 1 tile
        seq.removeAll()
        toggleButtons(activated: false)
        toggleSocialButtons(hidden: true)
        makeSequence(seqNum: 0, greenButton: greenButton, purpleButton: purpleButton)
        index = 0
        
        // Can't click start button again
        startButton.isEnabled = false
        startButton.isHidden = true
    }
    
    
    // Allows for connectivity with Facebook and Twitter
    
    @IBAction func postToFacebookTapped(sender: UIButton) {
        if (SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)) {
            let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            socialController?.setInitialText("I scored \(lastScore) points on Buttons! Betcha can't get more than me!")
            let internetURL = URL(string: "https://github.com/theCaiGuy/ButtonsGame")
            socialController?.add(internetURL)
            
            self.present(socialController!, animated: true, completion: nil)
        }
    }
    
    @IBAction func postToTwitterTapped(sender: UIButton) {
        if (SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)) {
            let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            socialController?.setInitialText("I scored \(lastScore) points on Buttons! Betcha can't get more than me!")
            let internetURL = URL(string: "https://github.com/theCaiGuy/ButtonsGame")
            socialController?.add(internetURL)
            
            self.present(socialController!, animated: true, completion: nil)
        }
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


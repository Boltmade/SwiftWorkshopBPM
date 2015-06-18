//
//  ViewController.swift
//  TapBPM
//
//  Created by Sean Amadio on 2015-06-11.
//  Copyright (c) 2015 Boltmade. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation

class ViewController: UIViewController {
    
    //Keep a reference to our labelw
    @IBOutlet weak var bpmLabel:UILabel!;
    
    //Create a place to store each of our bpms so we can get an average later
    private var samples:[Double] = [];
    
    //We declare a private var that stores a previous date
    private var previousDate:NSDate?;
    
    //Sound effect file url and audio player
    //Sound pulled from http://www.freesfx.co.uk/sfx/dripping
    let soundUrl = NSBundle.mainBundle().URLForResource("WaterDrop", withExtension: "mp3")
    var audioPlayer : AVAudioPlayer?
    
    @IBAction func didTap(recognizer:UIGestureRecognizer) {
        trackBPM()
        showTouch(recognizer.locationInView(self.view))
        makeSound()
    }
    
    @IBAction func reset(sender:UIButton) {
        previousDate = nil;
        samples = [];
        bpmLabel.text = "Tap to Start";
    }
    
    func trackBPM() {
        let now = NSDate();
        //Check to see if we have a previous date stored
        if let date = previousDate {
            
            let bpm = 60/now.timeIntervalSinceDate(date);
            samples += [bpm];
            
            //Grab the average and update the label
            let averageBPM = Int(average(samples));
            bpmLabel.text = String(averageBPM);
            
        } else {
            
            bpmLabel.text = "First Beat";
        }
        previousDate = now;
    }
    
    func showTouch(touchLocation : CGPoint) {
        let circle = UIView(frame: CGRectMake(0, 0, 50, 50))
        circle.center = touchLocation
        circle.layer.cornerRadius = circle.frame.size.width/2
        circle.backgroundColor = UIColor.randomColor(0.3)
        circle.userInteractionEnabled = false
        view.insertSubview(circle, belowSubview: bpmLabel)
        
        UIView.animateWithDuration(
            2.0,
            delay: 0.0,
            options: UIViewAnimationOptions.AllowAnimatedContent | UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                circle.transform = CGAffineTransformMakeScale(10, 10)
                circle.alpha = 0
            }) { (completed) -> Void in
                circle.removeFromSuperview()
        }
    }
    
    func makeSound() {
        self.audioPlayer = AVAudioPlayer(contentsOfURL: self.soundUrl, error: nil)
        self.audioPlayer?.prepareToPlay()
        self.audioPlayer?.play()
    }
}

//Loop through and average all of the values in an aray
func average(array:[Double]) -> Double
{
    var total = 0.0;
    for value in array {
        total += value;
    }
    return total/Double(array.count);
}
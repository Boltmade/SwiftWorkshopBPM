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

enum ColorOption : String {
    case Red = "Red", Blue = "Blue", Random = "Random"
    static let allValues = [Red, Blue, Random]
    static func color(option : ColorOption) -> UIColor {
        switch(option) {
        case Red:
            return UIColor.redColor()
        case Blue:
            return UIColor.blueColor()
        case Random:
            return UIColor.randomColor(0.3)
        }
    }
}

class ViewController: UIViewController {
    
    //Keep a reference to our labelw
    @IBOutlet weak var bpmLabel:UILabel!;
    
    //Create a place to store each of our bpms so we can get an average later
    private var samples:[Double] = [];
    
    //We declare a private var that stores a previous date
    private var previousDate:NSDate?;
    
    //Sound effect file url and audio player
    //Sound pulled from http://www.freesfx.co.uk/sfx/dripping
    let tapSoundUrl = NSBundle.mainBundle().URLForResource("WaterDrop", withExtension: "mp3")
    var tapSoundPlayer : AVAudioPlayer?
    
    //Metronome effect file and audio player
    //Sound pulled from http://www.freesfx.co.uk/sfx/click?p=5
    let metronomeSoundURL = NSBundle.mainBundle().URLForResource("Pop", withExtension: "mp3")
    var metronomePlayer : AVAudioPlayer?
    var metronomeRepeatTimer : NSTimer?
    
    //Mute
    var isTapSoundOn = true
    var isMetronomeOn = true
    
    //Current color for touch events
    var currentColor = ColorOption.allValues.first!
    
    @IBOutlet weak var colorChooser: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var i = 0
        for colorOption in ColorOption.allValues {
                self.colorChooser.setTitle(colorOption.rawValue, forSegmentAtIndex: i++)
        }
    }
    
    @IBAction func didTap(recognizer:UIGestureRecognizer) {
        trackBPM()
        showTouch(recognizer.locationInView(self.view))
        makeTapSound()
        updateMetronome()
    }
    
    @IBAction func reset(sender:UIButton) {
        previousDate = nil;
        samples = [];
        self.metronomeRepeatTimer?.invalidate()
        self.metronomeRepeatTimer = nil
        updateLabel()
    }
    
    @IBAction func toggleTapSound(sender: UISwitch) {
        self.isTapSoundOn = sender.on
    }
    
    @IBAction func toggleMetronome(sender: UISwitch) {
        self.isMetronomeOn = sender.on
    }
    
    @IBAction func changeColor(sender: UISegmentedControl) {
        self.currentColor = ColorOption.allValues[sender.selectedSegmentIndex]
    }
    
    func trackBPM() {
        let now = NSDate();
        //Check to see if we have a previous date stored
        if let date = previousDate {
            
            let bpm = 60/now.timeIntervalSinceDate(date);
            samples += [bpm];
            
        }
        previousDate = now;

        updateLabel()
    }
    
    func showTouch(touchLocation : CGPoint) {
        let circle = UIView(frame: CGRectMake(0, 0, 50, 50))
        circle.center = touchLocation
        circle.layer.cornerRadius = circle.frame.size.width/2
        circle.backgroundColor = ColorOption.color(self.currentColor)
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
    
    func makeTapSound() {
        if (self.isTapSoundOn) {
            self.tapSoundPlayer = AVAudioPlayer(contentsOfURL: self.tapSoundUrl, error: nil)
            self.tapSoundPlayer?.prepareToPlay()
            self.tapSoundPlayer?.play()
        }
    }
    
    func updateMetronome() {
        if let averageBPM = self.bpmLabel.text?.toInt() {
            self.metronomeRepeatTimer?.invalidate()
            self.metronomeRepeatTimer = nil
            
            self.metronomePlayer = AVAudioPlayer(contentsOfURL: self.metronomeSoundURL, error: nil)
            self.metronomePlayer?.prepareToPlay()
            let metronomeInterval = NSTimeInterval(60.0/Double(averageBPM))
            self.metronomeRepeatTimer = NSTimer.scheduledTimerWithTimeInterval(metronomeInterval, target: self, selector: "metronomeTick", userInfo: nil, repeats: true)
        }
    }
    
    @objc private func metronomeTick() {
        if (self.isMetronomeOn) {
            self.metronomePlayer?.play()
        }
    }
    
    func labelMetadata() -> (text: String, color: UIColor) {
        let currentBPM = bpm(self.samples)
        switch ((currentBPM, self.previousDate)) {
        case (.None, .None):
            return ("Tap to Start", UIColor.blackColor())
        case (.None, let previous):
            return ("First Beat", UIColor.blackColor())
        case (.Some(0...60), let previous):
            return (String(currentBPM!), UIColor.greenColor())
        case (.Some(61...120), let previous):
            return (String(currentBPM!), UIColor.orangeColor())
        default:
            return (String(currentBPM!), UIColor.purpleColor())
        }
    }
    
    func updateLabel() {
        let labelMetadata = self.labelMetadata()
        bpmLabel.text = labelMetadata.text
        bpmLabel.textColor = labelMetadata.color
    }
}

//Loop through and average all of the values in an aray
func bpm(array:[Double]) -> Int?
{
    if array.count == 0 {
        return nil
    }
    
    let total = array.reduce(0) { (combined, number) in
        combined + number
        }
    return Int(total/Double(array.count))
}
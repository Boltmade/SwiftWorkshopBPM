//
//  ViewController.swift
//  TapBPM
//
//  Created by Michelle Ellis on 2015-06-24.
//  Copyright (c) 2015 Boltmade. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation

enum Color {
    case Red, Blue, Random(Double)
    func color() -> UIColor {
        switch (self) {
        case .Red:
            return UIColor.redColor()
        case .Blue:
            return UIColor.blueColor()
        case .Random(let alpha):
            return UIColor.randomColor(CGFloat(alpha))
        }
    }
    
    static func color(index : Int) -> Color {
        switch (index) {
        case 0:
            return .Red
        case 1:
            return .Blue
        case 2:
            return .Random(1.0)
        default:
            return .Random(0.2)
        }
    }
}


class ViewController: UIViewController {
    
    @IBOutlet weak var averageLabel: UILabel!
    
    private var samplesAccumulator = 0
    private var samplesCount = -1
    private var lastTapTime: NSDate?
    private var selectedColor = Color.color(0)
    
    // Sound originally from http://www.freesfx.co.uk/sfx/dripping
    let metronomeSoundUrl = NSBundle.mainBundle().URLForResource("WaterDrop", withExtension: "mp3")
    var metronomePlayer : AVAudioPlayer?
    var metronomeRepeatTimer : NSTimer?
}

//MARK: UIViewController
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateAverage()
    }
}

//MARK: Button Actions
extension ViewController {
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        collectBPMSample()
        updateAverage()
        showTouch(sender.locationInView(self.view))
        updateMetronome()
    }

    @IBAction func reset(sender: UIButton) {
        self.samplesAccumulator = 0
        self.samplesCount = -1
        self.lastTapTime = nil
        updateAverage()
        self.metronomeRepeatTimer?.invalidate()
        self.metronomeRepeatTimer = nil
    }
    
    @IBAction func colorPicked(sender: UISegmentedControl) {
        self.selectedColor = Color.color(sender.selectedSegmentIndex)
    }
}

//MARK: Audio
extension ViewController {
    private func updateMetronome() {
        self.metronomeRepeatTimer?.invalidate()
        self.metronomeRepeatTimer = nil
        metronomeTick()
        
        if self.samplesCount > 0 {
            let averageBPM = samplesAccumulator / samplesCount
            let metronomeTimerInterval = NSTimeInterval(60.0/Double(averageBPM))
            self.metronomeRepeatTimer = NSTimer.scheduledTimerWithTimeInterval(metronomeTimerInterval, target: self, selector: "metronomeTick", userInfo: nil, repeats: true)
        }
    }
    
    @objc private func metronomeTick() {
        self.metronomePlayer = AVAudioPlayer(contentsOfURL: self.metronomeSoundUrl, error: nil)
        self.metronomePlayer?.play()
    }
}

//MARK: Touch Visuals
extension ViewController {
    private func showTouch(touchLocation : CGPoint) {
        let circle = UIView(frame: CGRectMake(0,0,50,50))
        circle.center = touchLocation
        circle.layer.cornerRadius = circle.frame.size.width/2
        circle.backgroundColor = self.selectedColor.color()
        self.view.insertSubview(circle, belowSubview: averageLabel)

        UIView.animateWithDuration(
            2.0,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.AllowUserInteraction,
            animations: { () -> Void in
                circle.transform = CGAffineTransformMakeScale(10, 10)
                circle.alpha = 0
        }) { (completed) -> Void in
            circle.removeFromSuperview()
        }
    }
}

//MARK: Averaging
extension ViewController {
    private func collectBPMSample() {
        let now = NSDate()
        if let lastSample = self.lastTapTime {
            let bpm = Int(60/now.timeIntervalSinceDate(lastSample))
            self.samplesAccumulator += bpm
            self.samplesCount++
        } else {
            // First beat
            self.samplesCount = 0
        }
        self.lastTapTime = now
    }
    
    private func updateAverage() {
        let labelMetadata = self.labelMetadata()
        averageLabel.text = labelMetadata.text
        averageLabel.textColor = labelMetadata.textColor
        averageLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: CGFloat(labelMetadata.fontSize))
    }
    
    private func labelMetadata() -> (text: String, textColor: UIColor, fontSize: Int) {
        switch self.samplesCount {
        case -1:
            return ("Tap to Start", UIColor.blackColor(), 50)
        case 0:
            return ("First Beat", UIColor.blackColor(), 50)
        default:
            let currentBPM = self.samplesAccumulator / self.samplesCount
            switch currentBPM {
            case 0...60:
                return (String(currentBPM), UIColor.greenColor(), 70)
            case 61...120:
                return (String(currentBPM), UIColor.orangeColor(), 90)
            default:
                return (String(currentBPM), UIColor.purpleColor(), 110)
            }
        }
    }
}


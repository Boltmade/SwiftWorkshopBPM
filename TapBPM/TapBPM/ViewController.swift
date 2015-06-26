//
//  ViewController.swift
//  TapBPM
//
//  Created by Michelle Ellis on 2015-06-24.
//  Copyright (c) 2015 Boltmade. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    
    @IBOutlet weak var averageLabel: UILabel!
    
    private var samples:[Int] = []
    private var lastTapTime:NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func didTap(sender: UITapGestureRecognizer) {
        collectBPMSample(NSDate(), optionalLastSample: self.lastTapTime)
        updateAverage()
        showTouch(sender.locationInView(self.view))
    }

    @IBAction func reset(sender: UIButton) {
        self.samples = []
        self.lastTapTime = nil
        self.averageLabel.text = "Tap to Start"
    }
    
    private func showTouch(touchLocation : CGPoint) {
        let circle = UIView(frame: CGRectMake(0,0,50,50))
        circle.center = touchLocation
        circle.layer.cornerRadius = circle.frame.size.width/2
        circle.backgroundColor = UIColor.redColor()
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
    
    private func collectBPMSample(now : NSDate, optionalLastSample : NSDate?) {
        if let lastSample = optionalLastSample {
            let bpm = Int(60/now.timeIntervalSinceDate(lastSample))
            self.samples += [bpm]
        }
        self.lastTapTime = now
    }
    
    private func updateAverage() {
        let optionalAverage = averageBPM(self.samples)
        if let average = optionalAverage {
            self.averageLabel.text = String(average)
        } else {
            self.averageLabel.text = "First Beat"
        }
    }
    
    private func averageBPM(samples: [Int]) -> Int? {
        if (samples.count == 0) {
            return nil
        }
        
        ///////////////////////////////////
        // This is an intuitive jump from the for-in version, and is perfectly reasonable
        // This is probably the preferred solution, in terms of readability. In real life, this is what we'd do.
        ///////////////////////////////////

        let sum = samples.reduce(0) { $0 + $1 }
        return sum/samples.count

        ///////////////////////////////////
        // But filter is more powerful than that. Math!
        // (Literally math, that's a lot of multiplication and division: this is slower to execute)
        ///////////////////////////////////
        
        //        let avg = samples.reduce((0.0, 0.0), combine: { (accAndCount: (acc: Double, count: Double), next) -> (Double, Double) in
        //            let newCount = accAndCount.count + 1.0
        //            let newAcc = accAndCount.acc * (newCount - 1.0)/newCount + Double(next)*1.0/newCount
        //            return (newAcc, newCount)
        //        })
        //        return Int(avg.0)
        
        ///////////////////////////////////
        // This is identical to the code above, but less verbose.
        ///////////////////////////////////
        
        //        let avg = samples.reduce((0.0, 0.0)) { ($0.0 * $0.1/($0.1 + 1.0) + Double($1)*1.0/($0.1 + 1.0), ($0.1 + 1.0))}.0
        //        return Int(avg)
    }
}


//
//  ViewController.swift
//  TapBPM
//
//  Created by Michelle Ellis on 2015-06-24.
//  Copyright (c) 2015 Boltmade. All rights reserved.
//

import UIKit
import QuartzCore

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
    
    private var samples:[Int] = []
    private var lastTapTime:NSDate?
    private var selectedColor = Color.color(0)
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
        collectBPMSample(NSDate(), optionalLastSample: self.lastTapTime)
        updateAverage()
        showTouch(sender.locationInView(self.view))
    }

    @IBAction func reset(sender: UIButton) {
        self.samples = []
        self.lastTapTime = nil
        updateAverage()
    }
    
    @IBAction func colorPicked(sender: UISegmentedControl) {
        self.selectedColor = Color.color(sender.selectedSegmentIndex)
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
    private func collectBPMSample(now : NSDate, optionalLastSample : NSDate?) {
        if let lastSample = optionalLastSample {
            let bpm = Int(60/now.timeIntervalSinceDate(lastSample))
            self.samples += [bpm]
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
        let currentBPM = averageBPM(self.samples)
        switch ((currentBPM, self.lastTapTime)) {
        case (.None, .None):
            return ("Tap to Start", UIColor.blackColor(), 50)
        case (.None, let previous):
            return ("First Beat", UIColor.blackColor(), 50)
        case (.Some(0...60), let previous):
            return (String(currentBPM!), UIColor.greenColor(), 70)
        case (.Some(61...120), let previous):
            return (String(currentBPM!), UIColor.orangeColor(), 90)
        default:
            return (String(currentBPM!), UIColor.purpleColor(), 110)
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


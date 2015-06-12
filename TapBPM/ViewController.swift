//
//  ViewController.swift
//  TapBPM
//
//  Created by Sean Amadio on 2015-06-11.
//  Copyright (c) 2015 Boltmade. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //Keep a reference to our labelw
    @IBOutlet weak var bpmLabel:UILabel!;
    
    //Create a place to store each of our bpms so we can get an average later
    private var samples:[Double] = [];
    
    //We declare a private var that stores a previous date
    private var previousDate:NSDate?;

    @IBAction func didTap(recognizer:UIGestureRecognizer) {
        
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
    
    @IBAction func reset(sender:UIButton) {
        previousDate = nil;
        samples = [];
        bpmLabel.text = "Tap to Start";
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


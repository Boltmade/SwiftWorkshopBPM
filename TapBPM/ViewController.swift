//
//  ViewController.swift
//  TapBPM
//
//  Created by Sean Amadio on 2015-06-11.
//  Copyright (c) 2015 Boltmade. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //Create a place to store each of our bpms so we can get an average later
    private var samples:[Double] = [];
    
    //We declare a private var that stores a previous date
    private var previousDate:NSDate?;

    @IBAction func didTap(recognizer:UIGestureRecognizer) {
        
        let now = NSDate();
        //Check to see if we have a previous date stored
        if let date = previousDate
        {
            let bpm = 60/now.timeIntervalSinceDate(date);
            samples += [bpm];
            println(bpm);
        }
        else
        {
            
        }
        previousDate = now;
    }
}


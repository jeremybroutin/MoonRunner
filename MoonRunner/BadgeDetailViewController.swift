//
//  BadgeDetailViewController.swift
//  MoonRunner
//
//  Created by Jeremy Broutin on 4/23/17.
//  Copyright © 2017 Zedenem. All rights reserved.
//

import UIKit
import HealthKit

class BadgeDetailsViewController: UIViewController {
    
    var badgeEarnStatus: BadgeEarnStatus!
    
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var silverImageView: UIImageView!
    @IBOutlet weak var goldImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var earnedLabel: UILabel!
    @IBOutlet weak var silverLabel: UILabel!
    @IBOutlet weak var goldLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let transform = CGAffineTransform(rotationAngle: CGFloat(.pi/8.0))
        
        nameLabel.text = badgeEarnStatus.badge.name
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: badgeEarnStatus.badge.distance!)
        distanceLabel.text = distanceQuantity.description
        badgeImageView.image = UIImage(named: badgeEarnStatus.badge.imageName!)
        
        if let run = badgeEarnStatus.earnRun {
            earnedLabel.text = "Reached on " + formatter.string(from: run.timestamp)
        }
        
        // Silver
        if let silverRun = badgeEarnStatus.silverRun {
            silverImageView.transform = transform
            silverImageView.isHidden = false
            silverLabel.text = "Earned on " + formatter.string(from: silverRun.timestamp)
        }
        else {
            silverImageView.isHidden = true
            let paceUnit = HKUnit.second().unitDivided(by: HKUnit.meter())
            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: badgeEarnStatus.earnRun!.duration / badgeEarnStatus.earnRun!.distance)
            silverLabel.text = "Pace < \(paceQuantity.description) for silver!"
        }
        
        // Gold
        if let goldRun = badgeEarnStatus.goldRun {
            goldImageView.transform = transform
            goldImageView.isHidden = false
            goldLabel.text = "Earned on " + formatter.string(from: goldRun.timestamp)
        }
        else {
            goldImageView.isHidden = true
            let paceUnit = HKUnit.second().unitDivided(by: HKUnit.meter())
            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: badgeEarnStatus.earnRun!.duration / badgeEarnStatus.earnRun!.distance)
            goldLabel.text = "Pace < \(paceQuantity.description) for gold!"
        }
        
        // Best
        if let bestRun = badgeEarnStatus.bestRun {
            let paceUnit = HKUnit.second().unitDivided(by: HKUnit.meter())
            let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: bestRun.duration / bestRun.distance)
            bestLabel.text = "Best: \(paceQuantity.description), \(formatter.string(from: bestRun.timestamp))"
        }
    }
}

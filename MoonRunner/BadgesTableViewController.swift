//
//  BadgesTableViewController.swift
//  MoonRunner
//
//  Created by Jeremy Broutin on 4/23/17.
//  Copyright © 2017 Zedenem. All rights reserved.
//

import UIKit
import HealthKit

class BadgesTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var badgeEarnStatusesArray: [BadgeEarnStatus]!
    let redColor = UIColor(red: 1, green: 20/255, blue: 44/255, alpha: 1)
    let greenColor = UIColor(red: 0, green: 146/255, blue: 78/255, alpha: 1)
    let dateFormatter: DateFormatter = {
        let _dateFormatter = DateFormatter()
        _dateFormatter.dateStyle = .medium
        return _dateFormatter
    }()
    let transform = CGAffineTransform(rotationAngle: CGFloat(.pi/8.0))
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: BadgeDetailsViewController.self) {
            let badgeDetailsViewController = segue.destination as! BadgeDetailsViewController
            let badgeEarnStatus = badgeEarnStatusesArray[(tableView.indexPathForSelectedRow?.row)!]
            badgeDetailsViewController.badgeEarnStatus = badgeEarnStatus
        }
    }
    
}

// MARK: - UITableViewDataSource

extension BadgesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return badgeEarnStatusesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BadgeCell") as! BadgeCell
        
        let badgeEarnStatus = badgeEarnStatusesArray[indexPath.row]
        
        cell.silverImageView.isHidden = (badgeEarnStatus.silverRun != nil)
        cell.goldImageView.isHidden = (badgeEarnStatus.goldRun != nil)
        
        if let earnRun = badgeEarnStatus.earnRun {
            cell.nameLabel.textColor = greenColor
            cell.nameLabel.text = badgeEarnStatus.badge.name!
            cell.descLabel.textColor = greenColor
            cell.descLabel.text = "Earned: " + dateFormatter.string(from: earnRun.timestamp)
            cell.badgeImageView.image = UIImage(named: badgeEarnStatus.badge.imageName!)
            cell.silverImageView.transform = transform
            cell.goldImageView.transform = transform
            cell.isUserInteractionEnabled = true
        }
        else {
            cell.nameLabel.textColor = redColor
            cell.nameLabel.text = "Badge locked"
            cell.descLabel.textColor = redColor
            let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: badgeEarnStatus.badge.distance!)
            cell.descLabel.text = "Run \(distanceQuantity.description) to earn"
            cell.badgeImageView.image = UIImage(named: badgeEarnStatus.badge.imageName!)
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
}

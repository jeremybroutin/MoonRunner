//
//  Badge.swift
//  MoonRunner
//
//  Created by Jeremy Broutin on 4/23/17.
//  Copyright © 2017 Zedenem. All rights reserved.
//

import Foundation

let silverMultiplier = 1.05 // 5% speed increase
let goldMultiplier = 1.10 // 10% speed increase

class Badge {
    let name: String?
    let imageName: String?
    let information: String?
    let distance: Double?
    
    init(json: [String: String]) {
        name = json["name"]
        information = json["information"]
        imageName = json["imageName"]
        distance = Double(json["distance"]!)
    }
}

class BadgeController {
    static let sharedController = BadgeController()
    
    lazy var badges : [Badge] = {
        var _badges = [Badge]()
        
        let filePath = Bundle.main.path(forResource: "badges", ofType: "json")
        do {
            let url = URL(fileURLWithPath: filePath!)
            let jsonData = try Data(contentsOf: url, options: .alwaysMapped)
            let jsonBadges = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [Dictionary<String, String>]
            if let jsonBadges = jsonBadges {
                for jsonBadge in jsonBadges {
                    _badges.append(Badge(json:jsonBadge))
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }

        return _badges
    }()
    
    func badgeEarnStatusesForRuns(runs: [Run]) -> [BadgeEarnStatus] {
        var badgeEarnStatuses = [BadgeEarnStatus]()
        
        for badge in badges {
            let badgeEarnStatus = BadgeEarnStatus(badge: badge)
            
            for run in runs {
                if run.distance > badge.distance! {
                    
                    // First time badge is earned
                    if badgeEarnStatus.earnRun == nil {
                        badgeEarnStatus.earnRun = run
                    }
                    
                    let earnRunSpeed = badgeEarnStatus.earnRun!.distance / badgeEarnStatus.earnRun!.duration
                    let runSpeed = run.distance / run.duration
                    
                    // Check for silver performance
                    if badgeEarnStatus.silverRun == nil && runSpeed > earnRunSpeed * silverMultiplier {
                        badgeEarnStatus.silverRun = run
                    }
                    
                    // Check for gold performance
                    if badgeEarnStatus.goldRun == nil && runSpeed > earnRunSpeed * goldMultiplier {
                        badgeEarnStatus.goldRun = run
                    }
                    
                    // Check for best run
                    if let bestRun = badgeEarnStatus.bestRun {
                        let bestRunSpeed = bestRun.distance / bestRun.duration
                        if runSpeed > bestRunSpeed {
                            badgeEarnStatus.bestRun = run
                        }
                    }
                    else {
                        badgeEarnStatus.bestRun = run
                    }
                }
            }
            
            badgeEarnStatuses.append(badgeEarnStatus)
        }
        
        return badgeEarnStatuses
    }
    
    func bestBadgeForDistance(distance: Double) -> Badge {
        var bestBadge = badges.first as Badge!
        for badge in badges {
            if distance < badge.distance! {
                break
            }
            bestBadge = badge
        }
        return bestBadge!
    }
    
    func nextBadgeForDistance(distance: Double) -> Badge {
        var nextBadge = badges.first as Badge!
        for badge in badges {
            nextBadge = badge
            if distance < badge.distance! {
                break
            }
        }
        return nextBadge!
    }
}

class BadgeEarnStatus {
    let badge: Badge
    var earnRun: Run?
    var silverRun: Run?
    var goldRun: Run?
    var bestRun: Run?
    
    init(badge: Badge) {
        self.badge = badge
    }
}

/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

class HomeViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: NewRunViewController.self) {
            if let newRunViewController = segue.destination as? NewRunViewController {
                newRunViewController.managedObjectContext = managedObjectContext
            }
        } else if segue.destination.isKind(of: BadgesTableViewController.self) {
            let fetchRequest = NSFetchRequest<Run>(entityName: "Run")
            
            let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let runs = try managedObjectContext!.fetch(fetchRequest)
                let badgesTableViewController = segue.destination as! BadgesTableViewController
                badgesTableViewController.badgeEarnStatusesArray = BadgeController.sharedController.badgeEarnStatusesForRuns(runs: runs)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func showPastRuns(_ sender: UIButton) {
        let alert = UIAlertController(title: "Coming soon!", message: "We are working on showing your saved runs, please come back later!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

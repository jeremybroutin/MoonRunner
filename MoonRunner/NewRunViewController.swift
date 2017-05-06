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
import CoreLocation
import HealthKit
import MapKit
import AudioToolbox

let DetailSegueName = "RunDetails"

class NewRunViewController: UIViewController {
    
    // MARK: - Properties
    
    var managedObjectContext: NSManagedObjectContext?
    
    var run: Run!
    var seconds = 0.0
    var distance = 0.0
    var upcomingBadge: Badge?
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .fitness
        
        // Movement threshold from new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var nextBadgeLabel: UILabel!
    @IBOutlet weak var nextBadgeImageView: UIImageView!
    
    // MARK: - View life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.requestAlwaysAuthorization()
        
        startButton.isHidden = false
        promptLabel.isHidden = false
        
        mapView.isHidden = true
        timeLabel.isHidden = true
        distanceLabel.isHidden = true
        paceLabel.isHidden = true
        stopButton.isHidden = true
        nextBadgeLabel.isHidden = true
        nextBadgeImageView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    // MARK: - IBActions
    
    @IBAction func startPressed(_ sender: AnyObject) {
        startButton.isHidden = true
        promptLabel.isHidden = true
        
        timeLabel.isHidden = false
        distanceLabel.isHidden = false
        paceLabel.isHidden = false
        mapView.isHidden = false
        stopButton.isHidden = false
        nextBadgeLabel.isHidden = false
        nextBadgeImageView.isHidden = false
        
        seconds = 0.0
        distance = 0.0
        locations.removeAll(keepingCapacity:  false)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eachSecond), userInfo: nil, repeats: true)
        startLocationUpdates()
    }
    
    @IBAction func stopPressed(_ sender: AnyObject) {
        let actionSheet = UIActionSheet(title: "Run Stopped", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save", "Discard")
        actionSheet.actionSheetStyle = .default
        actionSheet.show(in: view)
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? DetailViewController {
            detailViewController.run = run
        }
    }
    
    // MARK: - Helper functions
    
    func eachSecond(timer: Timer) {
        seconds += 1
        let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: seconds)
        timeLabel.text = "Time: " + secondsQuantity.description
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        distanceLabel.text = "Distance: " + distanceQuantity.description
        
        let paceUnit = HKUnit.second().unitDivided(by: HKUnit.meter())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
        paceLabel.text = "Pace :" + paceQuantity.description
        
        checkNextBadge()
        if let upcomingBadge = upcomingBadge {
            let nextBadgeDistanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: upcomingBadge.distance! - distance)
            nextBadgeLabel.text = "\(nextBadgeDistanceQuantity.description) until \(upcomingBadge.name!)"
            nextBadgeImageView.image = UIImage(named: upcomingBadge.imageName!)
        }
    }
    
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func saveRun(){
        let savedRun = NSEntityDescription.insertNewObject(forEntityName: "Run", into: managedObjectContext!) as! Run
        savedRun.distance = distance
        savedRun.duration = seconds
        savedRun.timestamp = Date()
        
        var savedLocations = [Location]()
        for location in locations {
            let savedLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext!) as! Location
            savedLocation.timestamp = location.timestamp
            savedLocation.latitude = location.coordinate.latitude
            savedLocation.longitude = location.coordinate.longitude
            savedLocations.append(savedLocation)
        }
        
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        do {
            try managedObjectContext!.save()
        } catch let error {
            print("Couldn't save the run, error: \(error)")
        }
    }
    
    func playSuccessSound() {
        let soundURL = Bundle.main.url(forResource: "success", withExtension: "wav")
        var soundID : SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundURL! as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
        
        //also vibrate
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate));
    }
    
    func checkNextBadge() {
        let nextBadge = BadgeController.sharedController.nextBadgeForDistance(distance: distance)
        if let upcomingBadge = upcomingBadge {
            if upcomingBadge.name! != nextBadge.name! {
                playSuccessSound()
            }
        }
        upcomingBadge = nextBadge
    }
}

// MARK: - UIActionSheetDelegate

extension NewRunViewController: UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        //save
        if buttonIndex == 1 {
            saveRun()
            performSegue(withIdentifier: DetailSegueName, sender: nil)
        }
            //discard
        else if buttonIndex == 2 {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}

// MARK: - CoreLocation delegate

extension NewRunViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            
            if abs(howRecent) < 10 && location.horizontalAccuracy < 20 {
                
                //update distance
                if self.locations.count > 0 {
                    distance += location.distance(from: self.locations.last!)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    
                    let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
                    mapView.setRegion(region, animated: true)
                    
                    mapView.add(MKPolyline(coordinates: &coords, count: coords.count))
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }
}



// MARK: - MKMapViewDelegate

extension NewRunViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

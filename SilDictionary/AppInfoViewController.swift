//
//  DetailViewController.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 11/13/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

import UIKit
import CoreLocation

class AppInfoViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var appVersionLabel: UILabel!
    @IBOutlet var appNameLabel: UILabel!
    @IBOutlet var buildNumberLabel: UILabel!
    @IBOutlet var lastAccessDateLabel: UILabel!
    @IBOutlet var numberOfLaunchesLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var copyrightLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    var locationManager: CLLocationManager!
    lazy var geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.setTitle(NSLocalizedString("str_done", comment: ""), for: .normal)
        appNameLabel.text = Bundle.main.displayName
        appVersionLabel.text = Bundle.main.version
        buildNumberLabel.text = Bundle.main.build
        copyrightLabel.text = Bundle.main.copyright
        numberOfLaunchesLabel.text = UserDefaults.standard.integer(forKey: dNumLaunches).description
        lastAccessDateLabel.text = UserDefaults.standard.string(forKey: dAccessDate)
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10

        locationManager.delegate = self
        onFirstView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Core Location
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: " + error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            // Geocode Location
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                // Process Response
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
        }
    }
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            locationLabel.text = ""
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                locationLabel.text = placemark.locality!+", "+placemark.country!
            } else {
                locationLabel.text = ""
            }
        }
    }
    
    // MARK: - Re-authorize Alert
    
    func onFirstView() {
        switch CLLocationManager.authorizationStatus() {
        //TODO : - at first launch when denied
        case .denied, .restricted:
            locationLabel.text = ""
        default:
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
}

//
//  ViewController_Directions.swift
//  CMProject
//
//  Created by Kan Onn Kit on 14/7/18.
//  Copyright © 2018 Kan Onn Kit. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import CoreLocation

let CIRCLE_RADII = 5
let LINE_WIDTH = 2

class ViewController_Directions: UIViewController {  // Subview of maps
    // MARK: Outlets
    @IBOutlet weak var label_directions: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentControl_modeOfTransport: UISegmentedControl!
    @IBOutlet weak var label_estTime: UILabel!  // Estimated time remaining
    
    // MARK: Vars
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    
    var segmentIndex: Int = 0
    
    var steps = [MKRouteStep]()
    let speechSynthesizer = AVSpeechSynthesizer()  // Speaker
    
    var stepCounter = 0
    var requestedLocation: MKMapItem?
    // Vars to be decided when arriving
    var locationTitle: String?
    
    // MARK: Func
    @IBAction func segmentedControl_modeOfTransport_getCurrentIndex(_ sender: AnyObject)
    {
        print("Updated index from \(segmentIndex) to \(segmentControl_modeOfTransport.selectedSegmentIndex)")
        segmentIndex = segmentControl_modeOfTransport.selectedSegmentIndex // Update index
        self.getDirections(to: requestedLocation!)
    }

    func getDirections(to destination: MKMapItem) {
        // Prep map and speech
        self.mapView.removeOverlays(self.mapView.overlays)
        self.speechSynthesizer.stopSpeaking(at: .immediate)
        
        // Get locations
        print("Getting locations")
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destination
        
        // Update the type according to the segment index
        print("Updating transport type")
        if segmentIndex == 0 {
            directionsRequest.transportType = .automobile
        } else if segmentIndex == 1 {
            directionsRequest.transportType = .walking
        } else {
            directionsRequest.transportType = .automobile
        }
        
        // Calculate directions
        print("Calculate directions")
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, _) in
            guard let response = response else
            {
                print("No response recieved")
                self.label_directions.text = "No routes found."
                let speechUtterance = AVSpeechUtterance(string: "No routes found.")  // Make the phone speak
                self.speechSynthesizer.speak(speechUtterance)
                return
                
            }
            guard let primaryRoute = response.routes.first else
            {
                print("No acceptible routes found")
                self.label_directions.text = "No acceptible routes found."
                let speechUtterance = AVSpeechUtterance(string: "No routes found.")  // Make the phone speak
                self.speechSynthesizer.speak(speechUtterance)
                return
                
            }
            print("Adding primary route")
            self.mapView.add(primaryRoute.polyline)
            
            self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
            
            print("Updating steps")
            self.steps = primaryRoute.steps
            for i in 0 ..< primaryRoute.steps.count {
                let step = primaryRoute.steps[i]
                print("\(i). In \(step.distance) meters, \(step.instructions).")
                let region = CLCircularRegion(center: step.polyline.coordinate,
                                              radius: CLLocationDistance(CIRCLE_RADII),
                                              identifier: "\(i)")
                self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.add(circle)
            }
            
            // UPDATE MESSAGES
            let initialMessage = "In \(self.steps[0].distance) meters, \(self.steps[0].instructions). Then in \(self.steps[1].distance) meters, \(self.steps[1].instructions)."
            let estTime = Double(round(100 * primaryRoute.expectedTravelTime / 60)/100)  // Round to 3dp
            
            self.label_directions.text = initialMessage  // Let the message be parsed first before setting it to be the label's text
            self.label_estTime.text = "\(estTime) Minutes Remaining"  // Display estimated time
            
            self.label_directions.layer.cornerRadius = 8.0
            self.label_estTime.layer.cornerRadius = 8.0
            
            let speechUtterance = AVSpeechUtterance(string: initialMessage)  // Make the phone speak
            self.speechSynthesizer.speak(speechUtterance)
            self.stepCounter += 1
            print("Updated message")
            
        }
    }
    
    override func viewDidLoad() {
        print()
        print("LOADING 'DIRECTIONS' SUBVIEW")
        
        // Decorations
        label_directions.layer.cornerRadius = 8.0
        label_estTime.layer.cornerRadius = 8.0
        
        self.title = "Directions"
        
        super.viewDidLoad()
        // Setup location manager
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        
        // Test for network
        if !Reachability.isConnectedToNetwork()  // If cannot connect to internet
        {
            print("Cannot reach directional servers.")
            self.label_directions.text = "Direction assistant offline. Please refresh after enabling internet access to continue."
        } else {
            let localSearchRequest = MKLocalSearchRequest()
            localSearchRequest.naturalLanguageQuery = locationTitle
            print("Search query recieved")
            
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            
            localSearchRequest.region = region
            let localSearch = MKLocalSearch(request: localSearchRequest)
            
            print("Starting search")
            localSearch.start
                { (response, _) in
                    guard let response = response else { return }
                    print("Location found")
                    guard let firstMapItem = response.mapItems.first else { return }
                    
                    self.requestedLocation = firstMapItem
                    self.getDirections(to: firstMapItem)
            }
        }
    }
    
}

extension ViewController_Directions: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapView.userTrackingMode = .followWithHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        stepCounter += 1
        print("Updating step counter")
        if stepCounter < steps.count {
            let currentStep = steps[stepCounter]
            let message = "In \(currentStep.distance) meters, \(currentStep.instructions)"
            label_directions.text = message
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance)
        } else {
            let message = "You have arrived at your destination."
            label_directions.text = message  // Update label
            let speechUtterance = AVSpeechUtterance(string: message)
            speechSynthesizer.speak(speechUtterance)
            stepCounter = 0
            locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
            
        }
    }
}

extension ViewController_Directions: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = CGFloat(LINE_WIDTH)
            return renderer
        }
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.fillColor = .red
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
}

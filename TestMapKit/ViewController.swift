//
//  ViewController.swift
//  TestMapKit
//
//  Created by cuilin on 2020-10-09.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    
    //properties
        @IBOutlet var map: MKMapView!
        @IBOutlet weak var textAddress: UITextField!
        @IBOutlet weak var labelLatitude: UILabel!
        @IBOutlet weak var labelLongitude: UILabel!
    
        let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // set MapViewDelegate to this class, so it handles events from MapView
                map.delegate = self
                
                // get the current location
                // NOTE: must delegate locationManager(_:didUpdateLocations:)
                // set usage of core location manager
                locationManager.requestWhenInUseAuthorization()
                
                // get the current location only if location service is enabled
                if CLLocationManager.locationServicesEnabled()
                {
                    locationManager.delegate = self
                    //locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation  // highest accuracy
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.startUpdatingLocation()
                }
        
    }
    
    @IBAction func doSearch(_ sender: Any) {
        
        let address = textAddress.text ?? ""
        if address.isEmpty
        {
            print("Address is empty.")
            return
        }
        
        // get location coord from place descriptor using closure
        self.forwardGeocoding(address: address, completion: { (location) in
            if let location = location
            {
                // found a location, move to new location
                //self.moveTo(location: location, title:address)
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region = MKCoordinateRegion(center:location.coordinate, span:span)
                self.map.setRegion(region, animated:true)

                // add pin annotation
                let pin = MKPointAnnotation()
                pin.coordinate = location.coordinate
                pin.title = address
                self.map.addAnnotation(pin)
                // update coordinate
                    
                self.labelLatitude.text = "Latitude: \(location.coordinate.latitude)"
                self.labelLongitude.text = "Longitude: \(location.coordinate.longitude)"
            }
        })
    }
    // delegates for CLLocationManagerDelegate
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
        {
            if let coord = locations.first?.coordinate
            {
                labelLatitude.text = "Latitude: \(coord.latitude)"
                labelLongitude.text = "Longitude: \(coord.longitude)"
                
                // update map
                let center = CLLocationCoordinate2D(latitude:coord.latitude,
                                                    longitude:coord.longitude)
                let span = MKCoordinateSpan(latitudeDelta:0.01, longitudeDelta:0.01)
                let region = MKCoordinateRegion(center:center, span:span)
                map.setRegion(region, animated:true)
                //locationManager.stopUpdatingLocation()
                //print(coord)
            }
        }
    // forward/reverse geocoding
        func forwardGeocoding(address: String, completion: @escaping((CLLocation?) -> Void))
        {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
                if let error = error
                {
                    print(error.localizedDescription)
                    completion(nil) // passing null location
                }
                else
                {
                    // pass the first location to the closure
                    let placemark = placemarks?[0]
                    completion(placemark?.location)
                }
            })
        }



        // STEP07 =================================================================
        func reverseGeocoding(location: CLLocation, completion: @escaping((CLPlacemark?) -> Void))
        {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let error = error
                {
                    print(error.localizedDescription)
                    completion(nil) // passing null placemark
                }
                else
                {
                    // pass the first placemark to closure
                    completion(placemarks?[0])
                }
            })
        }

}


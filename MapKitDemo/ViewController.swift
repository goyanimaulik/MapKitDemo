//
//  ViewController.swift
//  MapKitDemo
//
//  Created by Maulik Goyani on 20/06/18.
//  Copyright © 2018 Artoon. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController ,MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    
    var annotationViewArr = [MKAnnotationView]()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var numberOfDot = 10;
    
    @IBOutlet var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self

        // Get permission of Location access from user.
        if( CLLocationManager.authorizationStatus() != .authorizedWhenInUse &&
            CLLocationManager.authorizationStatus() !=  .authorizedAlways){
            locationManager.requestWhenInUseAuthorization()
        }
        
    }

    // Get Current location codinate
    func mapSetUp()
    {
        currentLocation = locationManager.location
        
        let initialLocation = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        let regionRadius: CLLocationDistance = 1000
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        centerMapOnLocation(location: initialLocation)
        
        mapView.delegate = self
        
        let locationsArr = getRandomLocations(location: currentLocation, itemCount: numberOfDot)
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(scaleAnimation), userInfo: nil, repeats: true);
        
        // Add pin in random location
        for loc in locationsArr
        {
            let artwork = Artwork(title: "",
                                  locationName: "",
                                  discipline: "",
                                  coordinate: CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
            mapView.addAnnotation(artwork)
        }
    }
    

    // create random locations (lat and long coordinates) around user's location
    func getRandomLocations(location: CLLocation, itemCount: Int) -> [CLLocation] {

        let baseLatitude = getBase(number: location.coordinate.latitude - 0.007)
        let baseLongitude = getBase(number: location.coordinate.longitude - 0.008)
        
        var items = [CLLocation]()
        for _ in 0..<itemCount {
            let randomLat = baseLatitude + randomCoordinate()
            let randomLong = baseLongitude + randomCoordinate()
            let location = CLLocation(latitude: randomLat, longitude: randomLong)
            items.append(location)
        }
        
        return items
    }
    
    func getBase(number: Double) -> Double {
        return round(number * 1000)/1000
    }
    func randomCoordinate() -> Double {
        return Double(arc4random_uniform(140)) * 0.0001
    }
    
    // Add image in random location
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = UIImage(named: "user.png")
        annotationView!.image = pinImage
        
        
        annotationViewArr.append(annotationView!)
        
        return annotationView
    }
    
    
    // Animation
    @objc func scaleAnimation()
    {
        if(annotationViewArr.count == 0)
        {
            return;
        }
        let randomInt = Int(arc4random_uniform(UInt32(annotationViewArr.count)))
        let view = annotationViewArr[randomInt]
        
        view.layer.removeAllAnimations()
        if(view.accessibilityLabel == "scaleIn" || view.accessibilityLabel == nil)
        {
            UIView.animate(withDuration: 0.6,
                           animations: {
                            view.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
                            view.accessibilityLabel = "scaleOut"
            },
                           completion: { _ in

            })
        }
        else
        {
            UIView.animate(withDuration: 0.6,
                           animations: {
                            view.transform = CGAffineTransform(scaleX: 1, y: 1)
                            view.accessibilityLabel = "scaleIn"
            },
                           completion: { _ in

            })
        }
        
    }
    
    // Get Location permission status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            manager.startUpdatingLocation()
            mapSetUp()
            break
        case .authorizedAlways:
            // If always authorized
            manager.startUpdatingLocation()
            mapSetUp()
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }
    
    
}


//
//  ViewController.swift
//  PerfectMaps
//
//  Created by Felix Lapalme on 2016-04-01.
//  Copyright © 2016 Felix Lapalme. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import Contacts

class ViewController: UIViewController, GMSAutocompleteViewControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let acController = GMSAutocompleteViewController()
    var currentPlace : GMSPlace? {
        didSet{
            directionsButton.enabled = currentPlace != nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        acController.delegate = self
        locationManager.delegate = self
        self.currentPlace = nil;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
        
        //focus on the current location
        if (self.currentPlace == nil) {
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }

    @IBAction func searchButtonTap(sender: AnyObject) {
        self.presentViewController(acController, animated: true, completion: nil)
    }
    
    @IBAction func directionsButtonTap(sender: AnyObject) {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        if (currentPlace != nil) {
            
            var addressDictionary : [String : AnyObject] = [:]
            
            if let formattedAddress = currentPlace?.formattedAddress {
                addressDictionary[String(CNPostalAddressStreetKey) as String] = formattedAddress
            }
            
            let placemark : MKPlacemark = MKPlacemark(coordinate: currentPlace!.coordinate, addressDictionary: addressDictionary)
            
            MKMapItem.openMapsWithItems([MKMapItem(placemark: placemark)], launchOptions: launchOptions)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
//MARK: - GMSAutoCompleteViewControllerDelegate methods
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        self.dismissViewControllerAnimated(true, completion: nil)
        mapView.removeAnnotations(mapView.annotations)
        let annotation : MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        annotation.title = place.name
        annotation.subtitle = place.formattedAddress
        self.currentPlace = place
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: \(error.description)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
//MARK: - CLLocationManagerDelegate methods
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        acController.autocompleteBounds = GMSCoordinateBounds(coordinate: newLocation.coordinate, coordinate: newLocation.coordinate)
    }
}


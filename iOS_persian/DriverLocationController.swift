//
//  DriverLocationController.swift
//  CeriosDrivr
//
//  Created by Rey Cerio on 2017-03-03.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class DriverLocationController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    let uid = FIRAuth.auth()?.currentUser?.uid
    var driverLat = Double()
    var driverLong = Double()
    var dLocation = DriverLocation()
    var driverLocation = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    var driverId = String()
    var driver: User? {
        didSet{
            navigationItem.title = driver?.name
        }
    }
    
    let mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Chat", style: .plain, target: self, action: #selector(pushChatController))
        fetchCoordinates()
        setupView()
        setupLocationManager()
    }
    
    func createAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }

//    func pushChatController() {
//        let layout = UICollectionViewFlowLayout()
//        let chatViewController = ChatViewController(collectionViewLayout: layout)
//        let navController = UINavigationController(rootViewController: chatViewController)
//        self.present(navController, animated: true, completion: nil)
//        
//    }

    func handleBack() {
        locationManager.stopUpdatingLocation()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupView() {
        view.addSubview(mapView)
        
        view.addConstraintsWithVisualFormat(format: "H:|[v0]|", views: mapView)
        view.addConstraintsWithVisualFormat(format: "V:|[v0]|", views: mapView)
    }
    
    func fetchCoordinates() {
        let databaseRef = FIRDatabase.database().reference().child("CER_user_location").child(uid!).child(driverId)
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            
            let dictionary = snapshot.value as? [String: AnyObject]
            if dictionary != nil {
                self.dLocation.date = dictionary?["date"] as? String
                self.dLocation.latitude = dictionary?["latitude"] as? String
                self.dLocation.longitude = dictionary?["longitude"] as? String
                self.dLocation.uid = dictionary?["uid"] as? String
                self.driverLat = Double(self.dLocation.latitude!)!
                self.driverLong = Double(self.dLocation.longitude!)!
            }else{
                self.dismiss(animated: true, completion: nil)
                return
            }
        }, withCancel: nil)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location?.coordinate {
            
            fetchCoordinates()
            let driverLoc = CLLocationCoordinate2D(latitude: driverLat , longitude: driverLong)
            let userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegion(center: driverLoc, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapView.setRegion(region, animated: true)
            self.mapView.removeAnnotations(self.mapView.annotations)
            let annotation1 = MKPointAnnotation()
            let annotation2 = MKPointAnnotation()
            annotation1.coordinate = driverLoc
            annotation2.coordinate = userLocation
            annotation1.title = "Driver Location"
            annotation2.title = "User Location"
            
            self.mapView.addAnnotation(annotation1)
            self.mapView.addAnnotation(annotation2)
            
        }
    }

}

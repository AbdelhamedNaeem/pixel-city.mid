//
//  ViewController.swift
//  pixel-city
//
//  Created by Abdelhamid Naeem on 10/30/18.
//  Copyright © 2018 Abdelhamid Naeem. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapVC: UIViewController {


    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let authorizationStats = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self as! UIGestureRecognizerDelegate
        mapView.addGestureRecognizer(doubleTap)
    }
    
    
    

    @IBAction func centerMapBtnPressed(_ sender: Any) {
        if authorizationStats == .authorizedAlways || authorizationStats == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else{return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate,latitudinalMeters: regionRadius * 2.0 , longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MapVC: CLLocationManagerDelegate{
    func configureLocationServices(){
        if authorizationStats == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    @objc func dropPin(){
        //drop tee pin in the map
        print("pin was dropped")
    }
}



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
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender: )))
        doubleTap.numberOfTapsRequired = 2
//        doubleTap.delegate = self
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        
        var pinAnootaion = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnootaion.pinTintColor = #colorLiteral(red: 1, green: 0.7575573896, blue: 0.1878320102, alpha: 1)
        pinAnootaion.animatesDrop = true
        
        return pinAnootaion
    }
    
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
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        //drop tee pin in the map
        removePin()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinates, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinatesRegion = MKCoordinateRegion(center: touchCoordinates, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
    
        mapView.setRegion(coordinatesRegion, animated: true)
    }
    
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
}



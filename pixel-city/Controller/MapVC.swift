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
import Alamofire
import AlamofireImage


class MapVC: UIViewController {


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpHeightViewConstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    let authorizationStats = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var screenSize = UIScreen.main.bounds
    
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender: )))
        doubleTap.numberOfTapsRequired = 2
//        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp(){
        pullUpHeightViewConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        pullUpHeightViewConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        cancelAllSessions()
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    
    func  addProgressLabel() {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 100, y: 175, width: 200, height:  40)
        progressLabel!.font = UIFont(name: "Avenir Next", size: 14)
        progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLabel?.textAlignment = .center
        
        collectionView?.addSubview(progressLabel!)
    }
    
    func removrProgressLabel(){
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
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
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate,regionRadius * 2.0 , regionRadius * 2.0)
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
        removeSpinner()
        removrProgressLabel()
        cancelAllSessions()
        
        imageUrlArray = []
        imageArray = []
        
        collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLabel()
       
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinates, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        print(flickerUrl(forApiKey: apikey, withAnnotation: annotation, numberOfPhotos: 10))

        
        let coordinatesRegion = MKCoordinateRegionMakeWithDistance(touchCoordinates, regionRadius * 2.0, regionRadius * 2.0)
    
        mapView.setRegion(coordinatesRegion, animated: true)
        
        retrieveURLs(forAnnotation: annotation) { (finished) in
            if finished{
                self.retrieveImages(handler: { (finished) in
                    if finished{
                        self.removeSpinner()
                        self.removrProgressLabel()
                        self.collectionView?.reloadData()
                    }
                })
            }

        }
    }
    
    func removePin(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    
    func retrieveURLs(forAnnotation annotation: DroppablePin, handler: @escaping (_ stats: Bool) -> ()) {
        
        Alamofire.request(flickerUrl(forApiKey: apikey, withAnnotation: annotation, numberOfPhotos: 10)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else{ return }
            let photoDic = json["photos"] as? Dictionary<String, AnyObject>
            let photosDicArray = photoDic!["photo"] as! [Dictionary<String, AnyObject>]
            
            print(response)
            
            for photo in photosDicArray{
                let postURL = "http://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postURL)
            }
            handler(true)
        }
    }
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        
        for url in imageUrlArray{
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLabel?.text = "\(self.imageArray.count)/10 IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count{
                    handler(true)
                }
            }
        }
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
}



extension MapVC: UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of item in array
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else{ return UICollectionViewCell() }
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
        
    }
    
}



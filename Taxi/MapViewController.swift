//
//  MapViewController.swift
//  Taxi
//
//  Created by Tran Ngoc Nam on 6/25/18.
//  Copyright © 2018 Tran Ngoc Nam. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    
    var locationManager: CLLocationManager = {
        var locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50.0
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        return locationManager
    }()
    
    // Slide menu constraint
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    var isSlideMenuHidden = true
    
    // MARK: Outlet
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    
    var checkIdentifier: Bool = true
    var source: GMSPlace?
    var destination: GMSPlace?
    var myLocation: CLLocationCoordinate2D?
    
    var marker: GMSMarker!
    var markerSecond: GMSMarker!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var currentLocaton: CLLocation!
//    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()

        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        
        sideMenuConstraint.constant = -200

        listLikelyPlaces()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedPlace != nil {
            print(selectedPlace!.name)
        }
        listLikelyPlaces()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func listLikelyPlaces() {
        likelyPlaces.removeAll()
        
        placesClient.currentPlace { (placeLikelihoods, error) -> Void in
            if let error = error {
                print("Current Place error: \(error.localizedDescription)")
                return
            }
            // xử lý khi có dữ liệu
            if let likelihoodList = placeLikelihoods {
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    self.likelyPlaces.append(place)
                }
            }
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let nextViewController = segue.destination as? PlacesViewController
            print("NamTN \(likelyPlaces.count)")
            nextViewController?.likelyPlaces = likelyPlaces
        } else {
            let detailController = segue.destination as? AutocompleteController
            detailController?.delegate = self
            if segue.identifier == "end" {
                checkIdentifier = false
            }
        }
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        mapView.clear()
        
        // Them marker
        if selectedPlace != nil {
            markerSecond = GMSMarker(position: (self.selectedPlace?.coordinate)!)
            markerSecond.title = selectedPlace?.name
            markerSecond.snippet = selectedPlace?.formattedAddress
            markerSecond.map = mapView
        }
        
        listLikelyPlaces()
    }
    
    // MARK: Search places
    @IBAction func searchPlaces(_ sender: UIBarButtonItem) {
        source = nil
        destination = nil
        startTextField.text = "Bạn đang ở đâu?"
        endTextField.text = "Bạn muốn đi đâu?"
        checkIdentifier = true
        if isSlideMenuHidden {
            sideMenuConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            sideMenuConstraint.constant = -200
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }

        isSlideMenuHidden = !isSlideMenuHidden
    }
    
    @IBAction func setMyLocation(_ sender: UIButton) {
        print("NamTN: \(String(describing: mapView.myLocation?.coordinate))")
        startTextField.text = "Vị trí của tôi"
        
    }
    
}


extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location :\(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        marker = nil
//        marker = GMSMarker()
//        marker.position = location.coordinate
//        marker.title = "I'm here"
//        marker.snippet = "Find me"
//        marker.map = mapView
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        listLikelyPlaces()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension MapViewController: AutocompleteControllerDelegate {

    func passingData(place: GMSPlace?) {
        guard let dataPlace = place else { return }
        if checkIdentifier == true {
            source = dataPlace
            print("NamTN: \(String(describing: dataPlace.coordinate))🤥")
            startTextField.text = "\(dataPlace.name), \(dataPlace.formattedAddress ?? "")"
        } else {
            destination = dataPlace
            print("NamTN: \(String(describing: dataPlace.coordinate))")
            endTextField.text = "\(dataPlace.name), \(dataPlace.formattedAddress ?? "")"
        }
        
        if source != nil && destination != nil {
            sideMenuConstraint.constant = -200
            mapView.clear()
            
            guard let sourceCoordinate = source?.coordinate else { return }
            guard let destinationCoordinate = destination?.coordinate else { return }
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: sourceCoordinate.latitude, longitude: sourceCoordinate.longitude)
            marker.title = source?.name
            marker.snippet = source?.formattedAddress ?? ""
            marker.map = mapView
            
            let marker2 = GMSMarker()
            marker2.icon = GMSMarker.markerImage(with: .blue)
            marker2.position = CLLocationCoordinate2D(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
            marker2.title = destination?.name
            marker2.snippet = destination?.formattedAddress ?? ""
            marker2.map = mapView
            
            getPolylineRoute(from: sourceCoordinate, to: destinationCoordinate)
        }

        
    }
}

extension MapViewController {
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving"
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            do {
                guard let dataPlaces = data else { return }
                if let json = try JSONSerialization.jsonObject(with: dataPlaces, options: .mutableContainers) as? DIC {
                    guard let routes = json["routes"] as? [DIC] else { return }
                    if routes.count > 0 {
                        let overview_polyline: DIC = routes[0]
                        guard let dictPolyline = overview_polyline["overview_polyline"] as? DIC else { return }
                        guard let points = dictPolyline["points"] as? String else { return }
                        guard let path = GMSPath.init(fromEncodedPath: points) else { return }
                        
                        DispatchQueue.main.async {
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeColor = .init(red: 30/255, green: 144/255, blue: 255/255, alpha: 1.0)
                            polyline.strokeWidth = 5.0
                            polyline.map = self.mapView
                            
                            let bounds = GMSCoordinateBounds(path: path)
                            let cameraUpdate = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 40, left: 15, bottom: 10, right: 15))
                            self.mapView.animate(with: cameraUpdate)
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }

}


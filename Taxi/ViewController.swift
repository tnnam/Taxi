//
//  ViewController.swift
//  Taxi
//
//  Created by Tran Ngoc Nam on 6/25/18.
//  Copyright © 2018 Tran Ngoc Nam. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

typealias DIC = Dictionary<AnyHashable, Any>

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let source = CLLocationCoordinate2D.init(latitude: 2.915142, longitude: 101.657498)
        let destination = CLLocationCoordinate2D(latitude: 2.909960, longitude: 101.654674)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: source.latitude, longitude: source.longitude)
        marker.title = "origin"
        marker.snippet = "start"
        marker.map = mapView

        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
        marker2.title = "destination"
        marker2.snippet = "end"
        marker2.map = mapView

        getPolylineRoute(from: source, to: destination)
    }
    
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
                            polyline.geodesic = true
                    
                            polyline.map = self.mapView
                            
                            let circleCenter = CLLocationCoordinate2D(latitude: 37.35, longitude: -122.0)
                            let circ = GMSCircle(position: circleCenter, radius: 1000)
                            
                            circ.fillColor = UIColor(red: 0.35, green: 0, blue: 0, alpha: 0.05)
                            circ.strokeColor = .red
                            circ.strokeWidth = 5
                            circ.map = self.mapView
                            
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


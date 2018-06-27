//
//  PlacesViewController.swift
//  Taxi
//
//  Created by Tran Ngoc Nam on 6/25/18.
//  Copyright © 2018 Tran Ngoc Nam. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class PlacesViewController: UITableViewController {

    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likelyPlaces.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let collectionItem = likelyPlaces[indexPath.row]
        cell.textLabel?.text = collectionItem.name
        return cell
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            selectedPlace = likelyPlaces[indexPath.row]
            let nextViewController = segue.destination as? MapViewController
            nextViewController?.selectedPlace = selectedPlace
        }
        
    }
    
}

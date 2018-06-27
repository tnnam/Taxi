//
//  MapObjectViewController.swift
//  HelloTaxi
//
//  Created by Tran Ngoc Nam on 6/22/18.
//  Copyright © 2018 Tran Ngoc Nam. All rights reserved.
//

import UIKit
import GooglePlaces

protocol AutocompleteControllerDelegate: class {
    func passingData(place: GMSPlace?)
}

class AutocompleteController: UIViewController{

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextField?
   
    // pass data by delegate
    weak var delegate: AutocompleteControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        searchController?.searchBar.frame = CGRect(x: 0, y: 0, width: 300, height: 44.0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: (searchController?.searchBar)!)

        
        definesPresentationContext = true
        
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.modalPresentationStyle = .popover
    }

}

extension AutocompleteController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress ?? "")")
        print("Place attributions: \(place.attributions?.string ?? "")")
        delegate?.passingData(place: place)
//        print(place.coordinate)
        navigationController?.popViewController(animated: true)
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

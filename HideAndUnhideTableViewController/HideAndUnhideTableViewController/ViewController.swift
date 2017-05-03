//
//  ViewController.swift
//  HideAndUnhideTableViewController
//
//  Created by ShrawanKumar Sharma on 03/05/17.
//  Copyright © 2017 TableViewCustom. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,GMSMapViewDelegate {

    @IBOutlet var googleMapView: GMSMapView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var placesClient:GMSPlacesClient!

    
    var placeModelArray = [PlaceModel]()

    
    let identifier = "CurrentLocationSearchCell"
    
    
    var customView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableViewcell()
        
        searchBar.delegate = self
      
         placesClient = GMSPlacesClient.shared()
        googleMapView.delegate = self
        
        
            setUpTableView()
    }

    
    func registerTableViewcell() {
        tableView.register(UINib.init(nibName: "CustomHeaderCellTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CustomHeaderCellTableViewCell" )
        tableView.register(UINib.init(nibName: "DefaultLocationTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
    }
    func setUpTableView(){
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath ) as! DefaultLocationTableViewCell
        if(indexPath.section == 0){
                if(indexPath.row == 0){
                    cell.bottomSepatorLine.isHidden = true
                   
                    if( placeModelArray.count != 0){
                        let place = placeModelArray[indexPath.row]
                        cell.titleLabelOfCell.text =  place.placeDescription
                        cell.placeID =  place.placeId
                    }
                }else{
                    cell.bottomSepatorLine.isHidden = false
                    cell.titleLabelOfCell.text = "Set Location On Map"
                }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }else{
            return 5
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     
        if(section == 0){
            return nil
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomHeaderCellTableViewCell") as! CustomHeaderCellTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        
        let cell  = tableView.cellForRow(at: indexPath) as! DefaultLocationTableViewCell
        print(cell.placeID)
        
        
        placesClient.lookUpPlaceID(cell.placeID, callback: { (place, error) -> Void in
        
            
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            guard let place = place else {
                print("No place details for \(cell.placeID)")
                return
            }
        
            
            print("Place name \(place.name)")
            print("Place address \(place.formattedAddress)")
            print("Place placeID \(place.placeID)")
//            print("Place attributions \(place.attributions)")
            print("Place attributions \(place.coordinate.latitude)")
            print("Place attributions \(place.coordinate.longitude)")
//            print("Place attributions \(place.attributions)")
        

            
            
            
            
            DispatchQueue.main.async {
                

//                self.googleMapView.selectedMarker = nil

//                self.googleMapView.selectedMarker?.map = nil
              //  self.googleMapView.selectedMarker = nil
                //self.googleMapView.clear()
                
                
                let camera = GMSCameraPosition.camera(withLatitude:place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16)
                let mapView = GMSMapView.map(withFrame:.zero, camera: camera)
                self.googleMapView  = mapView
            }
            

            let position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)

            let marker = GMSMarker(position: position)
            marker.title = place.formattedAddress
            marker.map = self.googleMapView
            self.googleMapView.selectedMarker = marker
            
            
            
        })
        
        
        
        
        if(indexPath.section == 0 ){
            if(indexPath.row == 0){
                
            }else{
                
            }
        }else{
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 10
        }
        else{
            return 26
  
        }
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        
//        UIView.animate(withDuration: 0.5, animations: {
//            self.suggestionTable.alpha = 1.0
//            
//        })
        
        
        // tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        shouldShowSearchResults = false
        searchBar.resignFirstResponder()
        
        //searchBar.text = "";
       // checkIfSearchIsActive()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      
//        if !shouldShowSearchResults {
//            shouldShowSearchResults = true
//        }
//        
       // searchBar.resignFirstResponder()
        
    }
    

    
    func searchPlaceInGoogleMap(name:String){
        placeAutocomplete(searchString: name)
    }
    

    
    
    
    func placeAutocomplete(searchString:String) {
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        placesClient.autocompleteQuery(searchString, bounds: nil, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                
                var placesArray = [String]()
                var weakPlaceModel = [PlaceModel]()

                for result in results {
                    
                    let placeModel = PlaceModel()
                    
                    placeModel.placeDescription=result.attributedFullText.string
                    placeModel.placeId = result.placeID!
                    weakPlaceModel.append(placeModel)
                    placesArray.append(result.attributedFullText.string)
                    print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                }
                self.placeModelArray.removeAll()
                self.placeModelArray = weakPlaceModel
                self.tableView.reloadData()
            }
        })
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){ // called when text changes (including clear)
       
        
        let searchString = searchText
//        UIView.animate(withDuration: 0.5, animations: {
//            self.suggestionTable.alpha = 1.0
//            
//        })
        
        if(searchBar.text != ""){
            // Filter the data array and get only those countries that match the search text.
            searchPlaceInGoogleMap(name: searchString)
            
          //  shouldShowSearchResults = true;
        }else{
           // shouldShowSearchResults = false;
            
        }
        tableView.reloadData()
    }
    
    
    

    
    
}

extension UIView {
    
    public class func fromNib() -> Self {
        return fromNib(nibName: nil)
    }
    
    public class func fromNib(nibName: String?) -> Self {
        func fromNibHelper<T>(nibName: String?) -> T where T : UIView {
            let bundle = Bundle(for: T.self)
            let name = nibName ?? String(describing: T.self)
            return bundle.loadNibNamed(name, owner: nil, options: nil)?.first as? T ?? T()
        }
        return fromNibHelper(nibName: nibName)
    }
}



class PlaceModel{
    var placeId = String()
    var placeDescription = String()
}

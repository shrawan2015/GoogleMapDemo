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
import MapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,CLLocationManagerDelegate,GMSMapViewDelegate {

    @IBOutlet var doneGoogleMap: UIButton!
    @IBOutlet weak var imageAboveIcon: UIView!
    @IBOutlet weak var iconAboveMapView: NSLayoutConstraint!
    @IBOutlet var googleMapView: GMSMapView!
    var locationMarker:GMSMarker!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var placesClient:GMSPlacesClient!
    var placeModelArray = [PlaceModel]()
    let identifier = "CurrentLocationSearchCell"
    let locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D!
    var shouldShowSearchResults:Bool = false
    var finalPositionAfterDragging:CLLocationCoordinate2D!
    
    @IBAction func setGoogleMapLocation(_ sender: UIButton) {
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.isHidden   = true
        
        //thanks
        tableView.backgroundColor = .clear
        
//        searchBar.placeholder = "Set Event Location"
//        searchBar.setTextColor(color: .black)
//        searchBar.setTextFieldColor(color: UIColor(red: 214.0/255.0, green: 212.0/255.0, blue: 208.0/255.0, alpha: 1.0))
//        searchBar.setPlaceholderTextColor(color: UIColor(red: 142.0/255.0, green: 142.0/255.0, blue: 147.0/255.0, alpha: 1.0))
//        searchBar.setSearchImageColor(color: .white)
//        searchBar.setTextFieldClearButtonColor(color: .black)
        
        
        changeSearchBarIcon()
        
        
        
        for subView in searchBar.subviews {
            for subViewOne in subView.subviews {
                if let textField = subViewOne as? UITextField {
                    subViewOne.backgroundColor = UIColor(red: 214, green: 212, blue: 208, alpha: 1)
                    //use the code below if you want to change the color of placeholder
                    let textFieldInsideUISearchBarLabel = textField.value(forKey: "placeholderLabel") as? UILabel
                    textFieldInsideUISearchBarLabel?.textColor = UIColor(red: 142,green:142,blue: 147, alpha: 1)
                }
            }
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: 36.8520709804133, longitude:10.2075162157416, zoom: 17.0)
        self.googleMapView?.animate(to: camera)
        
        searchBar.showsCancelButton  = true

        imageAboveIcon.layer.zPosition = 1
        isAuthorizedtoGetUserLocation()
       
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        registerTableViewcell()
        searchBar.delegate = self
        placesClient = GMSPlacesClient.shared()
        googleMapView.delegate = self
        setUpTableView()
        
        
        let coordinations = CLLocationCoordinate2D(latitude: -33,longitude:151)
        locationMarker = GMSMarker(position: coordinations)
        locationMarker.isDraggable = true
        
        
        
    }
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
        }
    }
    
    //this method is called by the framework on  locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did location updates is called")
        
        let userLocation:CLLocation = locations[0] as CLLocation // note that locations is same as the one in the function declaration
         self.currentLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
        manager.stopUpdatingLocation()

  
    }

      func locationIsAuthorized() -> Bool {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        let locationServicesEnabled = CLLocationManager.locationServicesEnabled()
        
        if authorizationStatus == .denied || authorizationStatus == .restricted || locationServicesEnabled == false {
            return false
        }
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
        /*
         NSLog(@"didFailWithError: %@", error);
         UIAlertView *errorAlert = [[UIAlertView alloc]
         initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [errorAlert show];
 */
    }
    
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
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
        
        
         if shouldShowSearchResults{
            
                if( placeModelArray.count != 0){
                    let place = placeModelArray[indexPath.row]
                    cell.titleLabelOfCell.text =  place.placeDescription
                    cell.placeID =  place.placeId
                    if(indexPath.row < 4){
                        cell.bottomSepatorLine.isHidden = true
                    }
            else{
                cell.bottomSepatorLine.isHidden = false
//                cell.titleLabelOfCell.text = "Set Location On Map"
              }
                }else{
                    ///no data server problem
            }
         }else{
            
            if(indexPath.row == 0){
                cell.titleLabelOfCell.text = "My Current Location"
            }else{
                cell.titleLabelOfCell.text = "Set Location On Map"
            }

            
            //current and set location cell
            
        }
        
        return cell
  
//        if(indexPath.section == 0){
//                if(indexPath.row == 0){
//                    cell.bottomSepatorLine.isHidden = true
//                   
//                    if( placeModelArray.count != 0){
//                        let place = placeModelArray[indexPath.row]
//                        cell.titleLabelOfCell.text =  place.placeDescription
//                        cell.placeID =  place.placeId
//                    }
//                }else{
//                    cell.bottomSepatorLine.isHidden = false
//                    cell.titleLabelOfCell.text = "Set Location On Map"
//                }
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
//        if shouldShowSearchResults {
//
//        }else{
//            
//        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        
        if shouldShowSearchResults
        {
            return 5
        }
        else
        {
          return 2
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
    
    func showTestInSearchBar(locationName:String){
        for subview in searchBar.subviews {
            for view in subview.subviews {
                if let searchField = view as? UITextField {
                    // do something with the search field
                    searchField.text = locationName
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        
        
        
        
        if ( locationIsAuthorized() ){
            
        }else{
            //show pop up to change the location
        }
        
        
        
        
        
        
        if shouldShowSearchResults{
            //map data
            
            
            
            
            
            
            
        }else{
            
            if(indexPath.row == 0){
//                cell.titleLabelOfCell.text = "My Current Location"
                
                if ( locationIsAuthorized() ){
                    let geocoder = GMSGeocoder()
                    geocoder.reverseGeocodeCoordinate(finalPositionAfterDragging) { response , error in
                        
                        let address:GMSAddress = (response?.firstResult())!
                        
                        if error != nil {
                            print("GMSReverseGeocode Error: \(String(describing: error?.localizedDescription))")
                        }
                        else {
                            //print("ADDRESS?? \(address)")
                            self.searchBar.text = address.locality
                        }
                    }
                    
                    
                }else{
                    //show pop up to change the location
                }
        
                
                searchBar.text = "search bar"
            }else{
//                cell.titleLabelOfCell.text = "Set Location On Map"
                locationMarker.isDraggable = true
            }
            //current and set location cell
        }
        
        
        let cell  = tableView.cellForRow(at: indexPath) as! DefaultLocationTableViewCell
        showTestInSearchBar(locationName: cell.titleLabelOfCell.text!)
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

            
            let position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.setupLocationMarker(coordinate: position)
            let sydney = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,
                                                  longitude: place.coordinate.longitude,
                                                  zoom: 6)
            self.googleMapView.camera = sydney
            tableView.isHidden = true
            self.searchBar.resignFirstResponder()

//            let marker = GMSMarker(position: position)
//            marker.title = place.formattedAddress
//            marker.map = self.googleMapView
//            self.googleMapView.selectedMarker = marker
//            
//            
            
        })
        
        
        
        
        if(indexPath.section == 0 ){
            if(indexPath.row == 0){
                
            }else{
                
            }
        }else{
            
        }
        
    }
    
    
    func setupLocationMarker(coordinate: CLLocationCoordinate2D) {
        if locationMarker != nil {
            locationMarker.map = nil
        }
        locationMarker = GMSMarker(position: coordinate)
        locationMarker.map = googleMapView
//        locationMarker.title = mapTasks.fetchedFormattedAddress
        locationMarker.appearAnimation =  .pop
        locationMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
        locationMarker.opacity = 0.75
        locationMarker.isDraggable = true
        locationMarker.isFlat = true
        locationMarker.snippet = "The best place on earth."
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 10
        }
        else{
            return 26
  
        }
    }
    
    
    
    let width = 20
    let height = 20
    
    func changeSearchBarIcon() {
        let topView: UIView = searchBar.subviews[0] as UIView
        var searchField:UITextField!
        for subView in topView.subviews {
            if subView is UITextField {
                searchField = subView as! UITextField
                break
            }
        }

        if ((searchField) != nil) {
            let leftview = searchField.leftView as! UIImageView
            let magnifyimage = leftview.image
            let imageView  = UIImageView(frame: CGRect(x: Int(searchBar.frame.origin.x) + 15  , y:  Int(searchBar.frame.origin.y), width: width, height: height ) )
            imageView.image = magnifyimage
            
            searchField.leftView = UIView(frame: CGRect(x: 0 , y: 0, width: width, height: height) )
            searchField.leftViewMode = .always
            searchField.superview?.addSubview(imageView)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarfdButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        tableView.isHidden = false
        
        
        // To still display the search results when the search button is tapped, not the whole list
        if searchBar.text != "" {
            shouldShowSearchResults = true
        }
        else{
            shouldShowSearchResults = false
        }
        
        
       
        
// UIView.animate(withDuration: 0.5, animations: {
//            self.suggestionTable.alpha = 1.0
//            
//        })
        // tableView.reloadData()
    }
    
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
////        shouldShowSearchResults = false
//    can
//       // checkIfSearchIsActive()
//    }
//    

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
    
        print("Cancel called")
        
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
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
            shouldShowSearchResults = true;
        }else{
            shouldShowSearchResults = false;
            
            
        }
    }
    
    
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // mapSearchBar.resignFirstResponder()
    }
    
    
    /**
     * Called when dragging has been initiated on a marker.
     */
    public func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker){
        print("didBeginDragging")
    }
    
    
    /**
     * Called after dragging of a marker ended.
     */
    
    public func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker){
        print("didEndDragging")
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(finalPositionAfterDragging) { response , error in
            
            let address:GMSAddress = (response?.firstResult())!
            
            if error != nil {
                print("GMSReverseGeocode Error: \(String(describing: error?.localizedDescription))")
            }
                
            else {
                //print("ADDRESS?? \(address)")
                self.searchBar.text = address.locality
            }
        }
        
    
    }
    
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitute = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        
        
        finalPositionAfterDragging = CLLocationCoordinate2DMake(latitute, longitude)
        
        
        print("******")
        print(finalPositionAfterDragging.latitude)
        print(finalPositionAfterDragging.longitude)
        print("*****")

    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        //        for (markerDict, spotDict) in markerToSpotDictionary where markerDict == marker {
        //            spotDict.coordinate = marker.position
        //            CommonMethods.sharedInstance.updateSpot(spotDict, map: map!)
        //        }
        
    }
    
//    
//    - (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
//    {
//    double latitude = mapView.camera.target.latitude;
//    double longitude = mapView.camera.target.longitude;
//    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
///    marker.position = center;
//    
//    }
    
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print(#function)
        let coordinate = CLLocationCoordinate2DMake(mapView.centerCoordinate.longitude, mapView.centerCoordinate.latitude)
            print("******")
        print(coordinate.latitude)
        print(coordinate.longitude)
        print("*****")
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


extension UISearchBar {
    
    private func getViewElement<T>(type: T.Type) -> T? {
        
        let svs = subviews.flatMap { $0.subviews }
        guard let element = (svs.filter { $0 is T }).first as? T else { return nil }
        return element
    }
    
    func getSearchBarTextField() -> UITextField? {
        
        return getViewElement(type: UITextField.self)
    }
    
    func setTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.textColor = color
        }
    }
    
    
    
    
    
    func setTextFieldColor(color: UIColor) {
        
        if let textField = getViewElement(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 20
                
            case .prominent, .default:
                textField.backgroundColor = color
            }
        }
    }
    
    func setPlaceholderTextColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSForegroundColorAttributeName: color])
        }
    }
    
    func setTextFieldClearButtonColor(color: UIColor) {
        
        if let textField = getSearchBarTextField() {
            
            let button = textField.value(forKey: "clearButton") as! UIButton
            if let image = button.imageView?.image {
                button.setImage(image.transform(withNewColor: color), for: .normal)
            }
        }
    }
    
    func setSearchImageColor(color: UIColor) {
        
        if let imageView = getSearchBarTextField()?.leftView as? UIImageView {
            imageView.image = imageView.image?.transform(withNewColor: color)
        }
    }
}

class PlaceModel{
    var placeId = String()
    var placeDescription = String()
}

extension UIImage {
    
    func transform(withNewColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage!)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}


extension UIColor{
    class func color(red:CGFloat,_ green:CGFloat,_ blue:CGFloat) -> UIColor{
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
}

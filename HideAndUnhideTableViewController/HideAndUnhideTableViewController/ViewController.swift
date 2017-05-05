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
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var placesClient:GMSPlacesClient!
    var placeModelArray = [PlaceModel]()
    let identifier = "CurrentLocationSearchCell"
    var currentLocation:CLLocationCoordinate2D!
    var shouldShowSearchResults:Bool = false
    var finalPositionAfterDragging:CLLocationCoordinate2D!
    var locationMarker:GMSMarker!
    var locationDragged:Bool!
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        _locationManager.activityType = .automotiveNavigation
        _locationManager.distanceFilter = 10.0  
        return _locationManager
    }()
    
    
    @IBAction func setGoogleMapLocation(_ sender: UIButton) {
        
        if(searchBar.text?.characters.count != 0){
            //popviewcontroller
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        imageAboveIcon.isHidden  = true
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.returnKeyType = .done
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        locationDragged = true
        shouldShowSearchResults = false

        changeSearchBarIcon()
        registerTableViewcell()

        
        let camera = GMSCameraPosition.camera(withLatitude: 36.8520709804133, longitude:10.2075162157416, zoom: 30.0)
        self.googleMapView?.animate(to: camera)
        
        searchBar.showsCancelButton  = true

        imageAboveIcon.layer.zPosition = 1
        doneGoogleMap.layer.zPosition = 1
        isAuthorizedtoGetUserLocation()
       
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        searchBar.delegate = self
        placesClient = GMSPlacesClient.shared()
        googleMapView.delegate = self
        setUpTableView()
        
        
        let coordinations = CLLocationCoordinate2D(latitude: -33,longitude:151)
        locationMarker = GMSMarker(position: coordinations)
//        locationMarker.isDraggable = true
    
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
       
        
        if shouldShowSearchResults{
            if self.placeModelArray.count > 4 {
                return 5
            }else{
                return self.placeModelArray.count
            }
        }
        else
        {
          return 2
        }
    }
    
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0  , y:  0, width: size.width, height: size.height )
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 5.0)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        path.fill()
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
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
        
        
        if shouldShowSearchResults{
            //map data
            
            let cell  = tableView.cellForRow(at: indexPath) as! DefaultLocationTableViewCell
            showTestInSearchBar(locationName: cell.titleLabelOfCell.text!)

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
                //print("Place attributions \(place.attributions)")
                print("Place attributions \(place.coordinate.latitude)")
                print("Place attributions \(place.coordinate.longitude)")
                //print("Place attributions \(place.attributions)")
                
                
                let position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                self.setupLocationMarker(coordinate: position)
                let sydney = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,
                                                      longitude: place.coordinate.longitude,
                                                      zoom: 35)
                self.googleMapView.camera = sydney
                
               
            })
        }else{
            if(indexPath.row == 0){
//              cell.titleLabelOfCell.text = "My Current Location"
                if ( locationIsAuthorized() ){
                    let geocoder = GMSGeocoder()
                    
                    setupLocationMarker(coordinate: self.currentLocation)
                    let position = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                    self.setupLocationMarker(coordinate: position)
                    let sydney = GMSCameraPosition.camera(withLatitude: currentLocation.latitude,
                                                          longitude: currentLocation.longitude,
                                                          zoom: 35)
                    self.googleMapView.camera = sydney
                    
                    
                    
                    geocoder.reverseGeocodeCoordinate(self.currentLocation) { response , error in
                        let address:GMSAddress = (response?.firstResult())!
                        if error != nil {
                            print("GMSReverseGeocode Error: \(String(describing: error?.localizedDescription))")
                        }
                        else {
                            //print("ADDRESS?? \(address)")
                            
                            let result = response?.results()?.first
                            let address = result?.lines?.reduce("") { $0 == "" ? $1 : $0 + ", " + $1 }
                            self.searchBar.text = address

                        }
                    }
                }else{
                    //show pop up to change the location
                }
        
                
//                searchBar.text = "search bar"
            }else{
                
                if locationMarker != nil {
                    locationMarker.map = nil
                }
                
                
                let geocoder = GMSGeocoder()
                geocoder.reverseGeocodeCoordinate(finalPositionAfterDragging) { response , error in
                    
                    let address:GMSAddress = (response?.firstResult())!
                    
                    if error != nil {
                        print("GMSReverseGeocode Error: \(String(describing: error?.localizedDescription))")
                    }
                        
                    else {
                        //print("ADDRESS?? \(address)")
                        //                let lines:[String] = address.lines!
                        
                        let result = response?.results()?.first
                        let address = result?.lines?.reduce("") { $0 == "" ? $1 : $0 + ", " + $1 }
                        self.searchBar.text = address
                    }
                }
            
                imageAboveIcon.isHidden = false
//                cell.titleLabelOfCell.text = "Set Location On Map"
//                locationMarker.isDraggable = true
                
                
                
            }
        }
        
        doneGoogleMap.isHidden = false
        
        
//                
//        
//        
//        
//        if(indexPath.section == 0 ){
//            if(indexPath.row == 0){
//                
//            }else{
//                
//            }
//        }else{
//            
//        }
//        

        tableView.isHidden = true
        self.searchBar.resignFirstResponder()
        
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
        
        for subView in searchBar.subviews {
            for subViewOne in subView.subviews {
                if let textField = subViewOne as? UITextField {
                    subViewOne.backgroundColor = UIColor(red: 214, green: 212, blue: 208, alpha: 1)
                    //use the code below if you want to change the color of placeholder
                    var bounds: CGRect
                    bounds = textField.frame
                    bounds.size.height = 80 //(set height whatever you want)
                    textField.bounds = bounds
                    
                    let textFieldInsideUISearchBarLabel = textField.value(forKey: "placeholderLabel") as? UILabel
                    textFieldInsideUISearchBarLabel?.textColor = UIColor(red: 142,green:142,blue: 147, alpha: 1)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        searchBar.resignFirstResponder()

        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if !shouldShowSearchResults {
//            shouldShowSearchResults = true
//        }
        searchBar.resignFirstResponder()

    }
    
    func searchBarfdButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        imageAboveIcon.isHidden = true
        doneGoogleMap.isHidden = true
        tableView.isHidden = false

//        if searchBar.text != "" {
//            shouldShowSearchResults = true
//        }
//        else{
//            shouldShowSearchResults = false
//        }
        
        
       
        
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

        doneGoogleMap.isHidden = true

        
        print("Cancel called")
        searchBar.resignFirstResponder()
        searchBar.text = ""
        shouldShowSearchResults = false
        
        tableView.reloadData()
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
                self.shouldShowSearchResults = false
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
               // self.placeModelArray = weakPlaceModel
                 self.placeModelArray = NSArray(array: weakPlaceModel) as! [PlaceModel]
                self.shouldShowSearchResults = true
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
        }else{
            
            
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
        locationDragged = true
    }
    
    
    /**
     * Called after dragging of a marker ended.
     */
    
    public func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker){
        print("didEndDragging")
        
        locationDragged = false
        
        if(!imageAboveIcon.isHidden){
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(finalPositionAfterDragging) { response , error in
                let address:GMSAddress = (response?.firstResult())!
                if error != nil {
                    print("GMSReverseGeocode Error: \(String(describing: error?.localizedDescription))")
                }
                else {
                    self.searchBar.text = address.locality
                }
            }
        }
    }
   
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        print("idleAt")

        
        if(!imageAboveIcon.isHidden) {
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(finalPositionAfterDragging) { response , error in
            
                let address:GMSAddress = (response?.firstResult())!
                
                if error != nil {
                    print("GMSReverseGeocode Error: \(String(describing: error?.localizedDescription))")
                }
                    
                else {
                    //print("ADDRESS?? \(address)")
    //                let lines:[String] = address.lines!

                    let result = response?.results()?.first
                    let address = result?.lines?.reduce("") { $0 == "" ? $1 : $0 + ", " + $1 }
                    self.searchBar.text = address
                }
            }
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        print("didChange")

        
        
        let latitute = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        finalPositionAfterDragging = CLLocationCoordinate2DMake(latitute, longitude)
        
        
//        print("******")
//        print(finalPositionAfterDragging.latitude)
//        print(finalPositionAfterDragging.longitude)
//        print("*****")

    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("will move")

    }
    

    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("will didDrag")

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
        print("regionWillChangeAnimated")

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

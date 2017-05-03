//
//  Place.swift
//  Fynd
//
//  Created by SKS on 01/05/17.
//  Copyright © 2017 Fynd. All rights reserved.
//

import UIKit

class Place: NSObject
{
    var placeId = String()
    var placeDescription = String()
    var returnDelegate : AnyObject?
    var returnSelector : Selector?
    
    
    func searchPlace(searchString : String, delegate: AnyObject, selector : Selector)
    {
        returnDelegate = delegate
        returnSelector = selector
        let requestUrl = Constants.kBasrUrl + String("input=\(searchString)&key=\(Constants.kGooglePlacesAPIKey)")
        ServerRequest.sharedInstance.connectToServerWithRequest(url: requestUrl, returnSelector : #selector(Place.fillPlaces(_:)), returnDelegate : self)
    }
    
    func fillPlaces(_ responseDict : [String : Any])
    {
        var arrObjPlaces = [Place]()
        if responseDict["status"] as! String == "OK"
        {
            let arrayPlaces : [[String : Any]] = responseDict["predictions"] as! [[String : Any]]
            
            for dict in arrayPlaces
            {
                let objPlace = Place()
                objPlace.placeId = dict["place_id"] as! String
                objPlace.placeDescription = dict["description"] as! String
                arrObjPlaces.append(objPlace)
            }
        }
        returnDelegate?.performSelector(onMainThread: returnSelector!, with: arrObjPlaces, waitUntilDone: true)
    }
}

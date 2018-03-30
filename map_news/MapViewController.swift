//
//  ViewController.swift
//  map_news
//
//  Created by Carolyn Hampe on 3/26/18.
//  Copyright © 2018 Carolyn Hampe. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, MapMarkerDelegate {
    
    
/////////////// IBOutlets

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
 
/////////////// vars
 
    let locationManager = CLLocationManager()
    
//    var newsStoriesArr: [[String:Any]] = []
    let url = URL(string: "https://api.nytimes.com/svc/topstories/v2/world.json?&api-key=19e3d7ec6332478dad58f82df449bc47")
    
    var markerWindowXibView: UIView!
    
    private var infoWindow = MapMarkerWindow()
    fileprivate var locationMarker : GMSMarker? = GMSMarker()

    
    
/////// string func
    
    func formatGeo(string: String) -> String {
        var funcString = string
        for index in funcString.indices {
            if funcString[index] == " " {
                funcString.remove(at: index)
                funcString.insert("+", at: index)
            }
        }
        return funcString
    }
    
    
    
/////////////// basic funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// making api call
        NewsStoriesModel.getTopStories(url: url!, completionHandler: {
            data, response, error in
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    if let results = jsonResult["results"] as? [[String:Any]] {
                        for i in 0..<4 {

                            var markerInfo: [String:Any] = [:]
                            
                            // adding news
                            if let nytTitle = results[i]["title"] {
                                print("//////////// title", nytTitle)
                                markerInfo["title"] = nytTitle
                            }
                            
                            if let nytAbs = results[i]["abstract"] {
                                markerInfo["abs"] = nytAbs
                            }
                            
                            if let nytLink = results[i]["url"] {
                                print("//////////// link new: ", nytLink)
                                markerInfo["url"] = nytLink
                            }

                            if let nytImgArr = results[i]["multimedia"] as? NSArray {
                                print("in nytImgArr. count: ", nytImgArr.count)
                                for i in 0..<nytImgArr.count {
                                    if let dictUW = nytImgArr[i] as? [String:Any] {
                                        print("in for loop")
                                        if let mediaStr = dictUW["format"] as? String {
                                            if mediaStr == "mediumThreeByTwo210" {
                                                print(dictUW["url"] as! String)
                                                markerInfo["imgUrl"] = (dictUW["url"] as! String)
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                            


                            // getting geo name
                            let geoArr = results[i]["geo_facet"] as! NSArray
                            if geoArr.count > 0 {
                                let geoName = geoArr[0] as! String
                                
                                print("/////////// geoname", geoName)
                                
                                markerInfo["geoName"] = geoName
                                
                                let geoNameFormat = self.formatGeo(string: geoName)
                                
                                // google geocode api to get lat/long
                                let geoUrl = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(geoNameFormat)&key=AIzaSyAPxfliffnnjgaiN5GBIYlQVn36Cl5UXa8")
                                NewsStoriesModel.getLatLng(url: geoUrl!, completionHandler: {
                                    data, response, error in
                                    do {
                                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                                            if let results = jsonResult["results"] as? [[String:Any]] {
                                                let resultGeo = results[0]["geometry"] as! [String:Any]
                                                if let resultLoc = resultGeo["location"] as? [String:Any] {
                                                    if let latUW = resultLoc["lat"] as? Double, let lngUW = resultLoc["lng"] as? Double {
                                                        let coordinates = CLLocationCoordinate2D(latitude: latUW, longitude: lngUW)
                                                        markerInfo["position"] = coordinates
                                                    }
                                                }
                                            }
                                        }
                                    } catch {
                                        print("something went wrong")
                                    }
                                    
//                                    self.newsStoriesArr.append(newDict)
                                })
                            }
                            DispatchQueue.main.async {
                                ///// create marker
                                print("in dispatch queue")
                                if let positionUW = markerInfo["position"] as? CLLocationCoordinate2D {
                                    print("in positionUW")
                                    self.showMarker(position: positionUW, markerData: markerInfo)
                                    print("/////////// marker data", markerInfo)
                                    self.mapView.reloadInputViews()
                                }
                                ///// animate in
                                
                            }
                        }

                    }
                }
            } catch {
                print("something went wrong")
            }
            
        })
    
        
        /// set up location manager / permission
        
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.mapType = .satellite
        mapView.delegate = self
        
        self.infoWindow = loadNiB()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

/////////////// more funcs
    
    func showMarker(position: CLLocationCoordinate2D, markerData: [String:Any]) {
        let marker = GMSMarker()
        marker.position = position
//        marker.position = CLLocationCoordinate2D(latitude: lat1, longitude: long1)
        marker.userData = markerData
        marker.appearAnimation = .pop
        marker.map = mapView
    }

    
    func loadNiB() -> MapMarkerWindow {
        let infoWindow = MapMarkerWindow.instanceFromNib() as! MapMarkerWindow
        return infoWindow
    }
    
    
/////////////// IBActions
    
    @IBAction func btnPressed(_ sender: UIButton) {
//        print("//////////////news array")
//        print(newsStoriesArr)
    }
    
    
}


extension MapViewController: CLLocationManagerDelegate {
    

//////popup
    
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
//////changed auth
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
          showLocationDisabledPopUp()
        }
        
        locationManager.startUpdatingLocation()
        
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
    }
    
    
//////updated location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate)
            let camera = GMSCameraPosition(target: location.coordinate, zoom: 0.5, bearing: 0, viewingAngle: 0)
            mapView.animate(to: camera)
            
            locationManager.stopUpdatingLocation()

            reverseGeocodeCoordinate(location.coordinate)
        }
    }
    
    
    
}



extension MapViewController: GMSMapViewDelegate {
 
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {

        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let location = response?.firstResult(), let country = location.country, let city = location.locality else {
                return
            }
            
//            self.city = city
//            self.country = country
        }
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var markerData : NSDictionary?
        if let dataUW = marker.userData! as? NSDictionary {
            print("made to if")
            markerData = dataUW
        }
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        // Pass the spot data to the info window, and set its delegate to self
        infoWindow.spotData = markerData
        infoWindow.delegate = self
        // Configure UI properties of info window

        infoWindow.layer.cornerRadius = 2
        if let dictUW = markerData {
            if let newsTitle = dictUW["title"] as? String {
                infoWindow.titleLabel.text = newsTitle
            }
            if let newsDesc = dictUW["abs"] as? String {
                infoWindow.descLabel.text = newsDesc
            }
            if let imgUrl = dictUW["imgUrl"] as? String {
                infoWindow.imgUrl = imgUrl
            }
            
            if let loc = dictUW["geoName"] as? String {
                infoWindow.locationLabel.text = loc
            }
            if let storyURL = dictUW["url"] as? String {
                infoWindow.storyUrl = storyURL
            }
        }


        // Offset the info window to be directly above the tapped marker
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - 82
        
        mapView.center = mapView.projection.point(for: location)
        
        self.view.addSubview(infoWindow)
        return false
    }
    
//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        reverseGeocodeCoordinate(position.target)
//    }
//

    
//    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
//        print("didTapInfoWindowOf")
//    }
//
//    /* handles Info Window long press */
//    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
//        print("didLongPressInfoWindowOf")
//    }
}


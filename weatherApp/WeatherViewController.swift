//
//  ViewController.swift
//  weatherApp
//
//  Created by Kanwar Sudeep Singh Sandhu on 22/05/18.
//  Copyright © 2018 Kanwar Sudeep Singh Sandhu. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    
    let BASE_URL: String = "http://api.openweathermap.org/data/2.5/weather"
    let API_KEY: String = "1be1c3d5076db2485d994759e16c1150"
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var imgWeatherIcon: UIImageView!
    @IBOutlet weak var lblCityName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
   
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
           // print("Location longitude:\(location.coordinate.longitude), Location Latitude:\(location.coordinate.latitude)")
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            var params = NSMutableDictionary()
           params = ["lat" : latitude, "lon" : longitude, "appid" : API_KEY ]
            debugPrint(params)
            performjson(requestAPI: "http://api.openweathermap.org/data/2.5/weather", postParams: params, postMethod: true, completion: { (json) in
                  debugPrint("Json: ",json)
            }, failure:{  error in
                
                debugPrint("error: ",error)
                })
           
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lblCityName.text = "Location Unavailable"
    }
    

    
    func performjson(requestAPI: String,postParams: NSDictionary,postMethod: Bool,completion: @escaping ( _ json: NSMutableDictionary) -> () , failure: @escaping (_ error:   NSDictionary) -> ()) {
        
        let myUrl = URL(string: requestAPI)
        var request = URLRequest(url: myUrl!)
        
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if(postMethod){
            
            request.httpMethod = "POST"
            
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: postParams, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
                
                return
            }
        }
            
        else{
            
            
            // get will be added here
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("Error : \(String(describing: error))")
                
                DispatchQueue.main.async {
                    
                    failure(["success": false, "message": (error?.localizedDescription)!])
                    
                }
                
            }
            do{
                let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSMutableDictionary
                DispatchQueue.main.async {
                    
                    completion(jsonObject)
                }
                
            }catch{
                
                DispatchQueue.main.async {
                    
                    failure(["success": false, "message": "Could not parse the data"])
                    
                }
            }
        }
        task.resume()
        
        
    }
}


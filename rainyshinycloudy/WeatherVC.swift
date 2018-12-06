//
//  WeatherVC.swift
//  rainyshinycloudy
//
//  Created by John Martin on 1/26/17.
//  Copyright © 2017 ProObject. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class WeatherVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentWeatherTypeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var currentWeather: CurrentWeather!
    var forecast: Forecast!
    var forecasts = [Forecast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup our LocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        // This triggers continuous GPS location updates.
        locationManager.startUpdatingLocation()
        
        // Set the tableView delegate to be itself.
        tableView.delegate = self
        
        // Set the tableView source to be itself.
        tableView.dataSource = self
        
        currentWeather = CurrentWeather()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            currentLocation = locationManager.location
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            currentWeather.downloadWeatherDetails {
                self.downloadForecastData {
                    self.updateMainUI()
                }
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
    //CLLocationManagerDelete method. Called when location change is detected by CLLocationManager.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
            
        print("Updated GPS Location Detected! ************")
        print("New latitude = \(coord.latitude), New longitude = \(coord.longitude)")
        
        // JM Below here is new code
        Location.sharedInstance.latitude = locationObj.coordinate.latitude
        Location.sharedInstance.longitude = locationObj.coordinate.longitude
        print("Singleton Location latitude = \(Location.sharedInstance.latitude), longitude = \(Location.sharedInstance.longitude)")
        currentWeather.downloadWeatherDetails {
            self.downloadForecastData {
                self.updateMainUI()
            }
        }
        
/* JM commented out.
         if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            currentWeather.downloadWeatherDetails {
                self.downloadForecastData {
                    self.updateMainUI()
                }
            }
        }
*/
        
    }
    
    func downloadForecastData(completed: @escaping DownloadComplete) {
                
        var forecastURL: String = "\(BASE_FORECAST_URL)"
        forecastURL = forecastURL.appending(LATITUDE + "\(Location.sharedInstance.latitude!)")
        forecastURL = forecastURL.appending(LONGITUDE+"\(Location.sharedInstance.longitude!)")
        forecastURL = forecastURL.appending("&cnt=10&mode=json")
        forecastURL = forecastURL.appending(APP_ID + API_KEY)
        
        // Dowloading forecast weather data for the TableView
        //Alamofire.request(FORECAST_URL).responseJSON { response in
        print("downloadForecastData() - Sending forecast GET request with");
        print(forecastURL)
        
        Alamofire.request(forecastURL).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
                if let list = dict["list"] as? [Dictionary<String, AnyObject>] {
                    
                    self.forecasts.removeAll() //JM
                    
                    for obj in list {
                        let forecast = Forecast(weatherDict: obj)
                        self.forecasts.append(forecast)
                        //print(obj) //JM
                    }
                    // Remove the 0th forecast, which is today's forecast. This is already
                    // displayed in the main section at the top of the user interface.
                    self.forecasts.remove(at: 0)
                    self.tableView.reloadData()
                }
            }
            completed()
        }
    }
    
    // Delegate Method for UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Delegate Method for UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    // Delegate Method for UITableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as? WeatherCell {
            let forecast = forecasts[indexPath.row]
            cell.configureCell(forecast: forecast)
            return cell
        } else {
            return WeatherCell()
        }
        
    }
    
    func updateMainUI() {
        
        // Update the date field on the UI.
        dateLabel.text = currentWeather.date
        
        // Update the temp label on the UI. Instructor forgot to append the 
        // cute little degree symbol after the temparature value.
        currentTempLabel.text = "\(currentWeather.currentTemp)" + "°"
        
        // Update the weather type label on the UI.
        currentWeatherTypeLabel.text = currentWeather.weatherType
        
        // Update our city name label on the UI
        locationLabel.text = currentWeather.cityName
        
        // Update the weather image on the UI
        currentWeatherImage.image = UIImage(named: currentWeather.weatherType)
        
    }
}


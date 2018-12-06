//
//  CurrentWeather.swift
//  rainyshinycloudy
//
//  Created by John Martin on 1/31/17.
//  Copyright © 2017 ProObject. All rights reserved.
//

import UIKit
import Alamofire

class CurrentWeather {
    var _cityName: String!
    var _date: String!
    var _weatherType: String!
    var _currentTemp: Double!
    
    var cityName: String {
        if (_cityName == nil) {
            _cityName = ""
        }
        return _cityName
    }
    
    var date: String {
        if (_date == nil) {
            _date = ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let currentDate = dateFormatter.string(from: Date())
        self._date = "Today, \(currentDate)"
        
        return _date
    }
    
    var weatherType: String {
        if (_weatherType == nil) {
            _weatherType = ""
        }
        return _weatherType
    }
    
    var currentTemp: Double {
        if (_currentTemp == nil) {
            _currentTemp = 0.0
        }
        return _currentTemp
    }
    
    func downloadWeatherDetails(completed: @escaping DownloadComplete) {
/*
        let BASE_URL = "http://api.openweathermap.org/data/2.5/weather?"
        let LATITUDE = "lat="
        let LONGITUDE = "&lon="
        let APP_ID = "&appid="
        let API_KEY = "3f2bd94d2943dbad0e107514592d3d4c"

        var weatherURL = "\(BASE_URL)"+"\(LATITUDE)"+"\(Location.sharedInstance.latitude!)"+"\(LONGITUDE)"+"\(Location.sharedInstance.longitude!)"+"\(APP_ID)"+"\(API_KEY)"
*/
        
        var weatherURL: String = "\(BASE_URL)"
        weatherURL = weatherURL.appending(LATITUDE + "\(Location.sharedInstance.latitude!)")
        weatherURL = weatherURL.appending(LONGITUDE + "\(Location.sharedInstance.longitude!)")
        weatherURL = weatherURL.appending(APP_ID + API_KEY)
                    
        // Alamofire download
        //let currentWeatherURL = URL(string: CURRENT_WEATHER_URL)
        print("downloadWeatherDetails(): Sending GET Request to server with:")
        //print(CURRENT_WEATHER_URL)
        //Alamofire.request(CURRENT_WEATHER_URL).responseJSON { response in
        Alamofire.request(weatherURL).responseJSON { response in
            let result = response.result
            
            //For debug purposes
            //print(response)
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let name = dict["name"] as? String {
                    // Bring in the City Name and make sure first letter is capitalized.
                    self._cityName = name.capitalized
                    
                    print(self._cityName)
                }
                
                if let weather = dict["weather"] as? [Dictionary<String, AnyObject>] {
                    if let main = weather[0]["main"] as? String {
                        self._weatherType = main.capitalized
                        
                        print(self._weatherType)
                    }
                }
                
                if let main = dict["main"] as? Dictionary<String, AnyObject> {
                    
                    if let currentTemperature = main["temp"] as? Double {
                        
                        let kelvinToFarenheitPreDivision = (currentTemperature*(9/5) - 459.67)
                        let kelvinToFarenheit = Double(round(10 * kelvinToFarenheitPreDivision/10))
                        
                        self._currentTemp = kelvinToFarenheit
                        
                        print("Current temp =\(currentTemperature) Kelvin")
                        print("Current temp =\(kelvinToFarenheit) F")
                        print(self._currentTemp)
                    }
                }
            }
            
           completed()
        }
    }
}

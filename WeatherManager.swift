//
//  WeatherManager.swift
//  Clima
//
//  Created by Heri Susanto on 14/03/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather:WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appId=edc10d4bc556665a2b534880db77c088&units=metric"
    
    func fetchWeather(cityName:String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    
    var delegate: WeatherManagerDelegate?
    
    func performRequest(with urlString: String){
        print(urlString)
        //1. create URL
        if let url = URL(string: urlString){
            // 2. crate URLSession
            let session = URLSession(configuration: .default)
            // 3. give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        print(weather)
                        self.delegate?.didUpdateWeather(self, weather:weather)
                    }
                }
            }
            // 4. start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp =  decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
   
    
    
    
}

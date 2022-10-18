//
//  GetWeatherResponse.swift
//  Weather
//
//  Created by Иван Осипов on 13/10/22.
//

import Foundation

struct GetWeatherResponse {
    let weather: WeatherData
    
    init(weatherData: Any) throws {
        guard let weather = weatherData as? WeatherData else { throw NetworkError.failInternetError }
    }
}

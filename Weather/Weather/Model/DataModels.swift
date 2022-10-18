//
//  WeatherData.swift
//  Weather
//
//  Created by Иван Осипов on 8/10/22.
//

import Foundation

struct Weather: Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct Main: Codable {
    var temp: Double = 0.0
    var pressure: Int = 0
    var humidity: Int = 0
}

struct WeatherData: Codable {
    var weather: [Weather]
    var main: Main
    var name: String
    var model: WeatherModel {
        return WeatherModel(cityName: name, temp: main.temp.toInt(), conditionId: weather.first?.id ?? 0, conditionDescription: weather.first?.description ?? "")
    }
}

struct WeatherModel: Codable {
    let cityName: String
    let temp: Int
    let conditionId: Int
    let conditionDescription: String
    
    var conditionImage: String {
        switch conditionId {
        case 200...299:
            return "thunderstorm"
        case 300...399:
            return "drizzle"
        case 500...599:
            return "rain"
        case 600...699:
            return "snow"
        case 700...799:
            return "atmosphere"
        case 800:
            return "clear"
        default:
            return "clouds"
        }
    }
}

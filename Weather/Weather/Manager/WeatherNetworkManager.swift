//
//  NetworkManager.swift
//  Weather
//
//  Created by Иван Осипов on 18/10/22.
//

import Foundation
import CoreLocation
import Alamofire

enum WeatherError: Error, LocalizedError {
    case custom(description: String)
    
    var errorDescription: String? {
        switch self {
        case.custom(description: let description):
            return description.description
        }
    }
}

struct WeatherNetworkManager {
    private let API_KEY = "7e0b8fbf49c9b58c407be3c71844d64d"
    private let cacheManager = CacheManager()
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let path = "https://api.openweathermap.org/data/2.5/weather?appid=%@&units=metric&lang=ru&lat=%f&lon=%f"
        let urlString = String(format: path, API_KEY, lat, lon)
        handleRequest(urlString: urlString, completion: completion)
    }
    
    func fetchWeather(city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let path = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric&lang=ru"
        let urlString = String(format: path, query, API_KEY)
        handleRequest(urlString: urlString, completion: completion)
    }
    
    private func handleRequest(urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        AF.request(urlString)
            .validate()
            .responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { (response) in
                switch response.result {
                case .success(let weatherData):
                    let model = weatherData.model
                    self.cacheManager.cacheCity(cityName: model.cityName)
                    completion(.success(model))
                case .failure(let error):
                    if let err = self.getWeatherError(error: error, data: response.data) {
                        completion(.failure(err))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    private func getWeatherError(error: AFError, data: Data?) -> Error? {
        if error.responseCode == 404,
           let data = data,
           let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: data) {
            let message = failure.message
            return WeatherError.custom(description: message)
        }
        return nil
    }
}

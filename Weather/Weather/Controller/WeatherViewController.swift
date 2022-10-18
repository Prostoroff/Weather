//
//  ViewController.swift
//  Weather
//
//  Created by Иван Осипов on 8/10/22.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    
    @IBOutlet weak var citylabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    private let defaultCity = "Moscow"
    private let cacheManager = CacheManager()
    private let weatherNetworkManager = WeatherNetworkManager()
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let city = cacheManager.getCacheCity() ?? defaultCity
        fetchWeather(byCity: city)
    }

    func startLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
        }
    }
    
    private func fetchWeather(byCity city: String) {
        weatherNetworkManager.fetchWeather(city: city) { [weak self] (result) in
            guard let this = self else { return }
            this.handleResult(result)
        }
    }
    
    private func fetchWeather(byLocation location: CLLocation) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherNetworkManager.fetchWeather(lat: lat, lon: lon) { [weak self] (result) in
            guard let this = self else { return }
            this.handleResult(result)
        }
    }
    
    private func fetchWeather() {
        
    }
    
    private func updateView(with data: WeatherModel) {
        citylabel.text = data.cityName
        conditionImageView.image = UIImage(named: data.conditionImage)
        temperatureLabel.text = data.temp.toString().appending("ºC")
        conditionLabel.text = data.conditionDescription
    }
    
    private func handleResult(_ result: Result<WeatherModel, Error>) {
        switch result {
        case .success(let model):
            updateView(with: model)
        case .failure(let error):
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        citylabel.text = ""
        conditionImageView.image = UIImage(named: "sad")
        temperatureLabel.text = "Упс!"
        conditionLabel.text = "Что-то пошло не так. Пожалуйста, попробуйте снова позже."
    }
    
    private func promptForLocationPermission() {
        let alertController = UIAlertController(title: "Требуется разрешение на определение местоположения.", message: "Хотите ли вы включить разрешение на определение местоположения в настройках?", preferredStyle: .alert)
        let enableAction = UIAlertAction(title: "Go to settings", style: .default) { _ in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(enableAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        locationManagerDidChangeAuthorization(locationManager)
    }
    @IBAction func addCityButtonTapped(_ sender: Any) {
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestLocation()
            locationManager.requestWhenInUseAuthorization()
        default:
            promptForLocationPermission()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            DispatchQueue.main.async {
                self.fetchWeather(byLocation: location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}

    

//
//  ViewController.swift
//  Weather
//
//  Created by Иван Осипов on 8/10/22.
//

import UIKit
import CoreLocation
import SkeletonView

protocol WeatherViewControllerDelegate: AnyObject {
    func didUpdateWeatherFromSearch(model: WeatherModel)
}

class WeatherViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var citylabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    // MARK: - Private Properties
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCity" {
            if let destination = segue.destination as? AddCityViewController {
                destination.delegate = self
            }
        }
    }

    // MARK: - IBAction
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        locationManagerDidChangeAuthorization(locationManager)
    }
    
    @IBAction func addCityButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showAddCity", sender: nil)
    }
    
    // MARK: - Private Methods
    
    private func startLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
        }
    }
    
    private func fetchWeather(byCity city: String) {
        showAnimation()
        weatherNetworkManager.fetchWeather(city: city) { [weak self] (result) in
            guard let this = self else { return }
            this.handleResult(result)
        }
    }
    
    private func fetchWeather(byLocation location: CLLocation) {
        showAnimation()
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        weatherNetworkManager.fetchWeather(lat: lat, lon: lon) { [weak self] (result) in
            guard let this = self else { return }
            this.handleResult(result)
        }
    }
    
    private func updateView(with data: WeatherModel) {
        self.hideAnimation()
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
        let enableAction = UIAlertAction(title: "Перейти в настройки", style: .default) { _ in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(enableAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func showAnimation() {
        citylabel.showAnimatedSkeleton()
        conditionImageView.showAnimatedSkeleton()
        temperatureLabel.showAnimatedSkeleton()
        conditionLabel.showAnimatedSkeleton()
    }
    
    private func hideAnimation() {
        citylabel.hideSkeleton()
        conditionImageView.hideSkeleton()
        temperatureLabel.hideSkeleton()
        conditionLabel.hideSkeleton()
    }
    
}

// MARK: - CLLocationManagerDelegate

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

// MARK: - WeatherViewControllerDelegate

extension WeatherViewController: WeatherViewControllerDelegate {
    func didUpdateWeatherFromSearch(model: WeatherModel) {
        presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let this = self else { return }
            this.updateView(with: model)
        })
    }
}
    

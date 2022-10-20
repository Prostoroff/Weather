//
//  AddCityViewController.swift
//  Weather
//
//  Created by Иван Осипов on 19/10/22.
//

import UIKit

class AddCityViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Public Properties
    
    weak var delegate: WeatherViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var weatherNetworkManager = WeatherNetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cityTextField.becomeFirstResponder()
    }
    
    // MARK: - IBAction
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        activityIndicatorView.startAnimating()
        guard let query = cityTextField.text, !query.isEmpty else {
            showSearchError(text: "Поле не должно быть пустым. Попробуйте снова!")
            return
        }
        handleSearch(query: query)
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = UIColor(white: 0.3, alpha: 0.4)
        statusLabel.isHidden = true
        self.cityTextField.delegate = self
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
    
    
    private func handleSearch(query: String) {
        activityIndicatorView.startAnimating()
        weatherNetworkManager.fetchWeather(city: query) { [weak self] (result) in
            guard let this = self else { return }
            this.activityIndicatorView.stopAnimating()
            switch result {
            case .success(let model):
                this.handleSearchSuccess(model: model)
            case .failure(let error):
                this.showSearchError(text: error.localizedDescription)
            }
        }
    }
    
    private func handleSearchSuccess(model: WeatherModel) {
        statusLabel.isHidden = false
        statusLabel.textColor = .systemGreen
        statusLabel.text = "Успешно"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.delegate?.didUpdateWeatherFromSearch(model: model)
        }
    }
    
    private func showSearchError(text: String) {
        statusLabel.isHidden = false
        statusLabel.textColor = .systemRed
        statusLabel.text = text
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension AddCityViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
}

// MARK: - UITextFieldDelegate

extension AddCityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

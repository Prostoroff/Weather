//
//  CacheManager.swift
//  Weather
//
//  Created by Иван Осипов on 18/10/22.
//

import Foundation

struct CacheManager {
    private let vault = UserDefaults.standard
    
    enum Key: String {
        case city
    }
    
    func cacheCity(cityName: String) {
        vault.set(cityName, forKey: Key.city.rawValue)
    }
    
    func getCacheCity() -> String? {
        return vault.value(forKey: Key.city.rawValue) as? String
    }
}

# Weather
Weather - это приложение показывающее текущую погоду по текущему местоположению либо по поиску конкретного города, разработанное на Swift 5.
## Версии
V1.0 - поддержка iOS 14+ с использованием CocoaPods, Alamofire, SkeletonView, Loaf.
## Скриншоты
<img src="screenshots/one.jpg" width="382.5" height="723"/> <img src="screenshots/two.jpg" width="382.5" height="723"/>
<img src="screenshots/three.jpg" width="382.5" height="723"/> <img src="screenshots/four.jpg" width="382.5" height="723"/>
## Стек 
- Swift
- UIKit
- MVC
- Storyboards
- CocoaPods
- Alamofire
- SkeletonView
- Loaf
- UserDefaults
- CoreLocation
## Как установить
1. Клонировать репозиторий 

`$ git clone https://github.com/Prostoroff/Weather.git`

2. Установить библиотеки

`$ cd Weather/`

`$ pod init`

Открыть Podfile в директории проекта

Записать туда:
```
# Pods for Weather
pod 'Alamofire'
pod 'SkeletonView'
pod 'Loaf'
```

Установить Podfile

`$ pod install`

3. Открыть проект в Xcode

`$ open "Weather.xcworkspace`

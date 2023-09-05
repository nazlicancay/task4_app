//
//  ViewController.swift
//  task4_app
//
//  Created by Nazlıcan Çay on 5.09.2023.
//

import UIKit
import CoreLocation
import Lottie


class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var maxMinTemperatureLabel: UILabel!

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Request user permission for location services
        locationManager.requestWhenInUseAuthorization()

        // Initialize location manager settings
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            fetchWeatherData(latitude: latitude, longitude: longitude)
        }
    }

    func fetchWeatherData(latitude: Double, longitude: Double) {
        let apiKey = "5382447ce1fbe9ad760d80e6513294d1"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"

        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let main = json["main"] as? [String: Any],
                           let weatherArray = json["weather"] as? [[String: Any]],
                           let name = json["name"] as? String {

                            let temp = main["temp"] as? Double ?? 0.0
                            let tempMin = main["temp_min"] as? Double ?? 0.0
                            let tempMax = main["temp_max"] as? Double ?? 0.0

                            let weather = weatherArray.first?["main"] as? String ?? ""

                            DispatchQueue.main.async {
                                // Update UI
                                self.cityLabel.text = name
                                self.currentTemperatureLabel.text = "\(temp)°C"
                                self.maxMinTemperatureLabel.text = "Min: \(tempMin)°C | Max: \(tempMax)°C"

                                // Choose the right Lottie animation for weather condition
                                switch weather {
                                case "Clear":
                                    self.loadLottieAnimation(name: "sunny")
                                case "Clouds":
                                    self.loadLottieAnimation(name: "Cloud")
                                case "Rain":
                                    self.loadLottieAnimation(name: "rainy")
                                
                                default:
                                    self.loadLottieAnimation(name: "Cloud")
                                }

                                
                            }
                        }
                    } catch {
                        print("JSON parsing failed: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
        }
    }
    
    func loadLottieAnimation(name : String) {
           let animationView = LottieAnimationView()
           animationView.animation = LottieAnimation.named(name)
           animationView.frame = weatherImageView.bounds
           animationView.contentMode = .scaleAspectFit
           animationView.loopMode = .loop
           animationView.play()
          weatherImageView.addSubview(animationView)
       }

    }





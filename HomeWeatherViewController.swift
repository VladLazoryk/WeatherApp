import UIKit
import Alamofire
import SwiftyJSON

class HomeWeatherViewController: UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var imageWeatherView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    private var setts = UserDefaults.standard
    private var cityName: String{
        get{
            if let name = setts.value(forKey: "cityName"){
                return name as! String
            }
            else{
                return "Saint Petersburg"
            }
        }
    }
    private let constrain: Constants = Constants()
    private var currentForecast: WeatherForecast? {
        didSet{
            reloadUI()
        }
    }
    
    private let photoResources: [String: UIImage] = [
        "01d":#imageLiteral(resourceName: "sunny"),
        "01n":#imageLiteral(resourceName: "moon"),
        "02d":#imageLiteral(resourceName: "sunny_clouds"),
        "02n":#imageLiteral(resourceName: "moodCloud"),
        "03d":#imageLiteral(resourceName: "clouds"),
        "03n":#imageLiteral(resourceName: "clouds"),
        "04d":#imageLiteral(resourceName: "clouds"),
        "04n":#imageLiteral(resourceName: "clouds"),
        "09d":#imageLiteral(resourceName: "cloud_rain"),
        "09n":#imageLiteral(resourceName: "cloud_rain"),
        "10d":#imageLiteral(resourceName: "sunCloudRain"),
        "10n":#imageLiteral(resourceName: "moonrain"),
        "11d":#imageLiteral(resourceName: "storm"),
        "11n":#imageLiteral(resourceName: "storm"),
        "13d":#imageLiteral(resourceName: "CloudSnow"),
        "13n":#imageLiteral(resourceName: "CloudSnow"),
        "50d":#imageLiteral(resourceName: "fog"),
        "50n":#imageLiteral(resourceName: "fog")
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCurrentForecast()
    }
    
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        updateCurrentForecast()
    }

    
    private func updateCurrentForecast(){
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather",
                          parameters: ["q": cityName,
                                       "APPID": constrain.apiKey,
                                       "units":"metric"])
            .responseJSON{response in
                guard response.result.isSuccess else{
                    return
                }
                let json = JSON(response.result.value!)
                self.currentForecast = WeatherForecast(currentWeatherTempurature: round(10 * json["main"]["temp"].doubleValue) / 10,
                                                       timeStamp: self.getCurrentTime(),
                                                       imageName: json["weather"][0]["icon"].string!,
                                                       locationCoordinates: (0, 0),
                                                       humidity: json["main"]["humidity"].int,
                                                       pressure: json["main"]["pressure"].int,
                                                       wind: round(10 * json["wind"]["speed"].doubleValue) / 10, cityName: json["name"].string,
                                                       stateWeather: json["weather"][0]["description"].string)
        }
    }
    
    private func getCurrentTime() -> String{
        let date = NSDate()
        let calendar = NSCalendar.current
        var currentTime: String
        let components = calendar.dateComponents([.hour, .minute], from: date as Date!)
        var hour: String = String(describing: components.hour!)
        var minute: String = String(describing: components.minute!)
        if hour.characters.count == 1{
            hour = "0" + hour
        }
        if(minute.characters.count == 1){
            minute = "0" + minute
        }
        currentTime = "\(hour):\(minute)"
        return currentTime
    }
    
    private func reloadUI(){
        timeLabel.text = "Updated: \(currentForecast!.timeStamp)"
        if let temp = currentForecast?.currentWeatherTempurature{
            temperatureLabel.text = "\(temp)℃"
        }
        if let city = currentForecast?.cityName{
            cityNameLabel.text = city
        }
        if let wi = currentForecast?.wind{
            windLabel.text = "\(wi)"
        }
        if let st = currentForecast?.stateWeather{
            stateLabel.text = st
        }
        imageWeatherView.image = photoResources[(currentForecast?.imageName)!]
    }
    
    
    
}

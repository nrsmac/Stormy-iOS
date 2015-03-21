//
//  ViewController.swift
//  Stormy
//
//  Created by Noah Schill on 3/19/15.
//  Copyright (c) 2015 nrsmac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    
    private let apiKey = "7a73984cc278e10ed332f1e5d6db96e9"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshActivityIndicator.hidden = true
        getCurrentWeatherData()
    }
    
    func getCurrentWeatherData() -> Void {
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")!
        var forecastURL = NSURL(string: "37.8267,-122.423", relativeToURL: baseURL)!
        
        var weatherData = NSData(contentsOfURL: forecastURL)
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            if (error == nil) {
                let dataObject = NSData(contentsOfURL: location)
                let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
                
                let currentWeather = Current(weatherDictionary: weatherDictionary)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.temperatureLabel.text = "\(currentWeather.temperature)"
                    self.iconView.image = currentWeather.icon!
                    self.currentTimeLabel.text = "At \(currentWeather.currentTime!) it is"
                    self.humidityLabel.text = "\(currentWeather.humidity)"
                    self.precipitationLabel.text = "\(currentWeather.precipProbability)"
                    self.summaryLabel.text = "\(currentWeather.summary)"
                    
                    //Stop refresh animation
                    self.refreshActivityIndicator.stopAnimating()
                    self.refreshActivityIndicator.hidden = true
                    self.refreshButton.hidden = false
                })
                
            } else {
                
                let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Connectivity error", preferredStyle: .Alert)
                
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                networkIssueController.addAction(okButton)
                let cancelButton = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                networkIssueController.addAction(cancelButton)
                
                self.presentViewController(networkIssueController, animated: true, completion: nil)
                
               dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //Stop refresh animation
                self.refreshActivityIndicator.stopAnimating()
                self.refreshActivityIndicator.hidden = true
                self.refreshButton.hidden = false
               })
                
            }
            
        })
        downloadTask.resume()
    }
    
    
    @IBAction func refresh() {
        refreshButton.hidden = true
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
        getCurrentWeatherData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        
    }


}


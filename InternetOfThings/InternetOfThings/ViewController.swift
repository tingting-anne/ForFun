//
//  ViewController.swift
//  InternetOfThings
//
//  Created by liutingting on 2017/3/10.
//  Copyright © 2017年 liutingting. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var currentAQILabel: UILabel!
    @IBOutlet weak var lampStatusSwitch: UISwitch!
    
    private let viewModel = ViewModel()
    private let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    private var isLoadingAQI = false {
        didSet {
            currentAQILabel.isHidden = isLoadingAQI
            setViewLoadingStatus()
        }
    }
    
    private var isLoadingLampStatus = false {
        didSet {
            lampStatusSwitch.isHidden = isLoadingLampStatus
            setViewLoadingStatus()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(indicator)
        NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 10).isActive = true
        NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.refresh), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    func refresh() {
        loadAQI()
        loadLampStatus()
    }
    
    private func loadAQI() {
        isLoadingAQI = true
        
        viewModel.getCurrentAQI {[weak self] data, error in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.isLoadingAQI = false
            
            if let aqi = data {
                strongSelf.currentAQILabel.text = "\(aqi)"
            }else {
                strongSelf.showError(error)
            }
        }
    }
    
    private func loadLampStatus() {
        isLoadingLampStatus = true
        
        viewModel.getLampStatus {[weak self] status, error in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.isLoadingLampStatus = false
            
            if let status = status {
               strongSelf.lampStatusSwitch.isOn = status == .on
            }else {
                strongSelf.showError(error)
            }
        }
    }
    
    private func setViewLoadingStatus() {
        if isLoadingAQI || isLoadingLampStatus {
            indicator.startAnimating()
        }else {
            indicator.stopAnimating()
        }
    }
    
    private func showError(_ error: CustomError?) {
        if let error = error {
            let alertController = UIAlertController(title: nil, message: error.description, preferredStyle: .alert)
            let action = UIAlertAction(title: "知道了", style: .cancel)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func goToChartsView(_ sender: Any) {
        let chartViewController = AQIChartsViewController(viewModel: viewModel)
        navigationController?.pushViewController(chartViewController, animated: true)
    }
    
    @IBAction func changeLampStatus(_ sender: Any) {
        lampStatusSwitch.isUserInteractionEnabled = false
        
        viewModel.changeLampStatus() {[weak self] error in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                strongSelf.showError(error)
                strongSelf.lampStatusSwitch.isOn = !strongSelf.lampStatusSwitch.isOn
            }
            strongSelf.lampStatusSwitch.isUserInteractionEnabled = true
        }
    }
}


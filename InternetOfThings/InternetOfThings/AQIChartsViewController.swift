//
//  AQIChartsViewController.swift
//  InternetOfThings
//
//  Created by liutingting on 2017/3/15.
//  Copyright © 2017年 liutingting. All rights reserved.
//

import UIKit
import CoreLocation
import Charts

class AQIChartsViewController: UIViewController {
    
    private let chartView = LineChartView()
    private let viewModel: ViewModel
    fileprivate let dateFomater = DateFormatter()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFomater.dateFormat = "MM/dd/yyyy"
        configChartView()
        
        view.backgroundColor = UIColor.white
        view.addSubview(chartView)
        NSLayoutConstraint(item: chartView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 10).isActive = true
        NSLayoutConstraint(item: chartView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: chartView, attribute: .top, relatedBy: .equal, toItem: view, attribute:.top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: chartView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute:.bottom, multiplier: 1.0, constant: -50).isActive = true
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        //chartView.animate(xAxisDuration: 2, yAxisDuration: 2)
        
        loadData()
    }
    
    private func configChartView() {
        chartView.delegate = self
        chartView.backgroundColor = UIColor.white
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.pinchZoomEnabled = true
        chartView.drawGridBackgroundEnabled = false
        chartView.maxHighlightDistance = 300.0
        
        chartView.scaleXEnabled = true
        chartView.scaleYEnabled = false
        
        let dateFomatter = DateAxisValueFormatter()
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = UIFont.systemFont(ofSize: 11)
        xAxis.labelTextColor = UIColor.darkGray
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.granularity = 24 * 3600
        xAxis.axisLineColor = UIColor.darkGray
        //xAxis.centerAxisLabelsEnabled = true
        //xAxis.labelCount = 4
        xAxis.valueFormatter = dateFomatter
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = UIColor.darkGray
        //leftAxis.labelCount = 6
        leftAxis.drawGridLinesEnabled = false
        leftAxis.granularityEnabled = true
        leftAxis.drawAxisLineEnabled = true
        leftAxis.axisLineColor = UIColor.darkGray
        leftAxis.centerAxisLabelsEnabled = true
        
        chartView.rightAxis.enabled = false
        
        //图表描述
        let lengend = chartView.legend
        lengend.form = .line
        lengend.font = UIFont.systemFont(ofSize: 16)
        lengend.textColor = UIColor.darkGray
        lengend.horizontalAlignment = .left
        lengend.verticalAlignment = .bottom
        lengend.orientation = .horizontal
        lengend.drawInside = false
        
        //点击后的详情描述
        let marker = CustomMarkerView(color: UIColor(white: 180/255, alpha: 1), font: UIFont.systemFont(ofSize: 12), textColor: UIColor.white, insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                      xAxisValueFormatter: dateFomatter)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
    }
    
    fileprivate func loadData() {
        let now = Date()
        guard let endTime = Calendar.current.date(byAdding: .day, value: 1, to: now),
            let startTime = Calendar.current.date(byAdding: .month, value: -1, to: endTime) else {
            showError("日期计算错误")
            return
        }
        
        let fomater = DateFormatter()
        fomater.dateFormat = "yyyy-MM-dd"
        let startTimeString = fomater.string(from: startTime)
        let endTimeString = fomater.string(from: endTime)
        
        viewModel.getHistoryAQI(startTime: startTimeString, endTime: endTimeString) {[weak self] times, aqis, error in
            guard let strongSelf = self else {
                return
            }
            
            if let times = times, let aqis = aqis {
                strongSelf.setData(times: times, aqis: aqis)
            }else {
                strongSelf.showError(error)
            }
        }
    }
    
    private func setData(times: [String], aqis: [Double]) {
        var values = [ChartDataEntry]()
        for (index, timeString) in times.enumerated() {
            if index >= aqis.count {
                break
            }
        
            if let time = dateFomater.date(from: timeString)?.timeIntervalSince1970 {
                values.append(ChartDataEntry(x: time, y: aqis[index]))
            }
        }
        
        if values.count <= 0 {
            return
        }
        
        if let data = chartView.data, data.dataSetCount > 0 {
            if let set = data.dataSets[0] as? LineChartDataSet {
                set.values = values
                data.notifyDataChanged()
                chartView.notifyDataSetChanged()
            }
        }
        else {
            let set = LineChartDataSet(values: values, label: "杭州 AQI")
            set.mode = .horizontalBezier
            set.axisDependency = .left
            set.valueTextColor = UIColor.blue
            set.lineWidth = 1.5         //曲线宽度
            set.drawCirclesEnabled = false
            set.drawValuesEnabled = true
            set.drawCircleHoleEnabled = false
            //set.fillAlpha = 0.26
            set.fillColor = UIColor.red
            set.highlightColor = UIColor.clear
            
            let data = LineChartData(dataSets: [set])
            data.setValueTextColor(UIColor.white)
            data.setValueFont(UIFont.systemFont(ofSize: 9))
            chartView.data = data
        }
    }
    
    private func showError(_ error: CustomError?) {
        if let error = error {
            showError(error.description)
        }
    }
    
    private func showError(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "知道了", style: .cancel)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - ChartViewDelegate

extension AQIChartsViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    }
}


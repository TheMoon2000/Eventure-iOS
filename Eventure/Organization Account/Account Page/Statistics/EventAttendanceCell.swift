//
//  EventAttendanceCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/11/11.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import Charts
import BonMot

class EventAttendanceCell: UICollectionViewCell {
    
    private var bgView: UIView!
    private var titleLabel: UILabel!
    private var barChart: BarChartView!
    private var lastSelected: ChartDataEntry?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.card.withAlphaComponent(0.5)
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 7
            view.layer.masksToBounds = true
            view.layer.borderColor = AppColors.line.cgColor
            view.applyMildShadow()
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -5).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
            
            return view
        }()
                
        titleLabel = {
            let label = UILabel()
            label.text = "Event Attendance"
            label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        barChart = {
            let bar = BarChartView()
            
            bar.drawBarShadowEnabled = false
            bar.highlightFullBarEnabled = true
            bar.drawValueAboveBarEnabled = true
            bar.doubleTapToZoomEnabled = false
            bar.maxHighlightDistance = 100
            bar.highlightPerDragEnabled = false
            bar.highlightPerTapEnabled = false
            
            bar.xAxis.labelFont = .systemFont(ofSize: 10)
            bar.xAxis.labelTextColor = AppColors.value
            bar.xAxis.labelPosition = .bottom
            // bar.xAxis.axisMinimum = 1
            bar.xAxis.granularity = 1
            bar.xAxis.labelCount = 10
            bar.xAxis.drawGridLinesEnabled = false
            bar.xAxis.xOffset = 8
            
            bar.leftAxis.labelFont = .systemFont(ofSize: 10)
            bar.leftAxis.labelTextColor = AppColors.prompt
            bar.leftAxis.drawGridLinesEnabled = true
            bar.leftAxis.drawAxisLineEnabled = true
            bar.leftAxis.axisMinimum = 0
            bar.leftAxis.axisLineColor = AppColors.placeholder
            bar.leftAxis.gridColor = AppColors.placeholder
            bar.leftAxis.granularity = 1
            
            bar.rightAxis.labelFont = .systemFont(ofSize: 10)
            bar.rightAxis.labelTextColor = AppColors.prompt
            bar.rightAxis.drawAxisLineEnabled = true
            bar.rightAxis.axisMinimum = 0
            bar.rightAxis.axisLineColor = AppColors.placeholder
            bar.rightAxis.gridColor = AppColors.placeholder
            bar.rightAxis.granularity = 1
            
            bar.delegate = self
            
            bar.legend.orientation = .horizontal
            bar.legend.horizontalAlignment = .center
            bar.legend.verticalAlignment = .bottom
            bar.legend.form = .square
            bar.legend.xEntrySpace = 10.0
            bar.legend.yEntrySpace = 5.0
            bar.legend.font = .systemFont(ofSize: 11)
            bar.legend.textColor = AppColors.label
            
            bar.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(bar)
            
            bar.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            bar.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -20).isActive = true
            bar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
            bar.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -20).isActive = true
            
            return bar
        }()
    }
    
    func setup(statsManager: StatsManager) {
        let eventData = statsManager.events.values.first!
        
        var entries = [BarChartDataEntry]()
        
        entries.append(BarChartDataEntry(x: 0, y: Double(eventData.views)))
        entries.append(BarChartDataEntry(x: 1, y: Double(eventData.interested)))
        entries.append(BarChartDataEntry(x: 2, y: Double(eventData.attendees.count)))
                
        let set = BarChartDataSet(entries: entries, label: "")
        set.drawIconsEnabled = false
        set.colors = [AppColors.lightGray, AppColors.mainLight, AppColors.main]
        
        let data = BarChartData(dataSet: set)
        data.setValueFormatter(IntegerFormatter())
        data.setValueFont(.systemFont(ofSize: 10))
        data.setValueTextColor(AppColors.value)
        
        barChart.data = data
        barChart.xAxis.valueFormatter = XAxisFormatter()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        bgView.layer.borderColor = AppColors.line.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


extension EventAttendanceCell: ChartViewDelegate {

    class IntegerFormatter: IValueFormatter {
        func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
                        
            return Int(value).description
        }
    }
    
    class XAxisFormatter: IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return ["Views", "Interested", "Attended"][Int(value)]
        }
    }
    
}

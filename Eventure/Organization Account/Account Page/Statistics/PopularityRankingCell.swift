//
//  PopularityRankingCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/11/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import Charts
import BonMot

class PopularityRankingCell: UICollectionViewCell {
    
    private var bgView: UIView!
    private var titleLabel: UILabel!
    private var captionLabel: UILabel!
    
    private var barChart: HorizontalBarChartView!
    
    private var top10Events = [(title: String, views: Int, interested: Int, attended: Int)]()
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
            label.text = "Most Popular Events"
            label.font = .appFontSemibold(20)
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        barChart = {
            let bar = HorizontalBarChartView()
            
            bar.drawBarShadowEnabled = false
            bar.highlightFullBarEnabled = true
            bar.drawValueAboveBarEnabled = true
            bar.doubleTapToZoomEnabled = false
            bar.maxHighlightDistance = 100
            bar.highlightPerDragEnabled = false
            
            bar.xAxis.labelFont = .appFontRegular(10)
            bar.xAxis.labelTextColor = AppColors.value
            bar.xAxis.labelPosition = .bottom
            // bar.xAxis.axisMinimum = 1
            bar.xAxis.granularity = 1
            bar.xAxis.labelCount = 10
            bar.xAxis.gridColor = AppColors.lightControl
            bar.xAxis.xOffset = 8
            
            bar.leftAxis.labelFont = .appFontRegular(10)
            bar.leftAxis.labelTextColor = AppColors.prompt
            bar.leftAxis.drawGridLinesEnabled = true
            bar.leftAxis.drawAxisLineEnabled = true
            bar.leftAxis.axisMinimum = 0
            bar.leftAxis.axisLineColor = AppColors.placeholder
            bar.leftAxis.gridColor = AppColors.placeholder
            bar.leftAxis.granularity = 1
            
            bar.rightAxis.labelFont = .appFontRegular(10)
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
            bar.legend.font = .appFontRegular(11)
            bar.legend.textColor = AppColors.label
            
            bar.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bar)
            
            bar.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            bar.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            bar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
            
            return bar
        }()
        
        captionLabel = {
            let label = UILabel()
            label.attributedText = "No event selected.".styled(with: .basicStyle)
            label.numberOfLines = 5
            label.textColor = AppColors.plainText
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.topAnchor.constraint(equalTo: barChart.bottomAnchor, constant: 15).isActive = true
            label.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
            
            
            return label
        }()
    }
    
    func setup(statsManager: StatsManager) {
        let eventData = statsManager.top10Events
        self.top10Events = eventData
        
        var entries = [BarChartDataEntry]()
        let offset = max(0, 5 - eventData.count)
        
        
        if eventData.count < 5 {
            for i in 0..<offset {
                entries.append(.init(x: Double(i), yValues: []))
            }
        }
        
        for i in 0..<eventData.count {
            let attended = Double(eventData[i].attended)
            let interestedOnly = max(0, Double(eventData[i].interested) - attended)
            let viewsOnly = Double(eventData[i].views) - attended - interestedOnly
            entries.append(BarChartDataEntry(x: Double(i + offset), yValues: [attended, interestedOnly, viewsOnly]))
        }
                
        let set = BarChartDataSet(entries: entries, label: "")
        set.stackLabels = ["Attended", "Interested", "Views"]
        set.drawIconsEnabled = false
        set.colors = [AppColors.main, AppColors.mainLight, AppColors.lightGray]
        
        let data = BarChartData(dataSet: set)
        data.setValueFormatter(IntegerFormatter())
        data.setValueFont(.appFontRegular(10))
        data.setValueTextColor(AppColors.value)
        
        barChart.data = data
         barChart.xAxis.valueFormatter = InvertedFormatter(total: max(5, eventData.count))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        bgView.layer.borderColor = AppColors.line.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension PopularityRankingCell: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        guard let entry = entry as? BarChartDataEntry else { return }
        
        let entryIndex = Int(entry.x) - max(0, 5 - top10Events.count)
        if entryIndex >= top10Events.count { return }
        
        UISelectionFeedbackGenerator().selectionChanged()
        if lastSelected != entry {
            self.lastSelected = entry
            captionLabel.attributedText = NSAttributedString.composed(of: [
                "Event: ".styled(with: .basicStyle),
                top10Events[entryIndex].title.styled(with: .valueStyle)
            ])
            captionLabel.textAlignment = .center
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        if lastSelected == nil { return }
        UISelectionFeedbackGenerator().selectionChanged()
        self.lastSelected = nil
        captionLabel.attributedText = "No event selected.".styled(with: .basicStyle)
        captionLabel.textAlignment = .center
    }
    
    class InvertedFormatter: IAxisValueFormatter {
        
        private var totalColumns = 0
        
        init(total: Int) {
            totalColumns = total
        }
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let value = (totalColumns - Int(value))
            if value == 0 || value > totalColumns { return "" }
            return "No. \(value.description)"
        }
    }
    
    class IntegerFormatter: IValueFormatter {
        func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
                        
            guard let values = (entry as? BarChartDataEntry)?.yValues else { return "error" }
            
            if values.isEmpty { return "" }
            
            if value == values[0] {
                return Int(value).description
            } else if value == values[1] {
                return Int(value + max(0, values[0])).description
            } else {
                return Int(value + max(0, values[0]) + max(0, values[1])).description
            }
        }
    }
    
}

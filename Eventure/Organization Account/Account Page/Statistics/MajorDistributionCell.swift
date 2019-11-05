//
//  MajorDistributionCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import Charts
import BonMot

class MajorDistributionCell: UICollectionViewCell {
    
    private var bgView: UIView!
    private var pieChart: PieChartView!
    private var titleLabel: UILabel!
    private var bottomLabel: UILabel!
    
    private var noSelectionText = "Nothing selected."
    
    var currentSelection: ChartDataEntry?
    
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
            label.text = "Attendee Composition"
            label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            label.textColor = AppColors.label
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
            
            return label
        }()
        
        pieChart = {
            let pie = PieChartView()
            
            // Basic appearance
            pie.centerAttributedText = "Majors".styled(with: .color(AppColors.value))
            pie.holeRadiusPercent = 0.4 // 0.3
            pie.drawHoleEnabled = false
            pie.transparentCircleRadiusPercent = 0
            pie.transparentCircleColor = AppColors.subview.withAlphaComponent(0.1)
            pie.holeColor = .clear
            pie.drawCenterTextEnabled = false
            pie.minOffset = 20
            pie.rotationEnabled = false
            pie.usePercentValuesEnabled = true
            pie.drawEntryLabelsEnabled = false
            pie.delegate = self
            
            
            // Legends
            pie.legend.form = .circle
            pie.legend.xEntrySpace = 10.0
            pie.legend.yEntrySpace = 5.0
            pie.legend.formSize = 10
            pie.legend.font = .systemFont(ofSize: 11)
            pie.legend.horizontalAlignment = .center
            pie.legend.textColor = AppColors.label
            
            pie.translatesAutoresizingMaskIntoConstraints = false
            addSubview(pie)
            
            pie.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
            pie.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
            pie.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -5).isActive = true
            pie.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            pie.widthAnchor.constraint(lessThanOrEqualToConstant: 600).isActive = true
            
            return pie
        }()
        
        bottomLabel = {
            let label = UILabel()
            label.attributedText = noSelectionText.styled(with: .basicStyle)
            label.numberOfLines = 3
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16)
            label.textColor = AppColors.plainText
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 20).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: pieChart.bottomAnchor, constant: 15).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
            
            return label
        }()
        
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            pieChart.legend.orientation = .horizontal
            pieChart.legend.verticalAlignment = .bottom
            pieChart.legend.horizontalAlignment = .center
        } else {
            pieChart.legend.orientation = .vertical
            pieChart.legend.verticalAlignment = .center
            pieChart.legend.horizontalAlignment = .right
        }
    }
    
    func setup(_ statManager: StatsManager) {
        let majorData = statManager.top10Majors
        
        var entries = majorData.map { (data) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            return PieChartDataEntry(value: Double(data.count),
                                     label: data.major)
        }
        
        if statManager.undeclaredCount > 0 {
            entries.append(.init(value: Double(statManager.undeclaredCount),
                                 label: "Unknown / Undeclared"))
        }
        
        let set = PieChartDataSet(entries: entries, label: "")
        set.drawIconsEnabled = false
        set.sliceSpace = 1.0
        set.selectionShift = 8
        
        set.colors = ChartColorTemplates.material()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.colorful()
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 12))
        data.setValueTextColor(.white)
        
        pieChart.data = data
        
        let plural = majorData.count == 1 ? "" : "s"
        bottomLabel.attributedText = "\(majorData.count) Major\(plural) in total.".styled(with: .basicStyle)
        bottomLabel.textAlignment = .center
        noSelectionText = bottomLabel.text!
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
                
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            pieChart.legend.orientation = .horizontal
            pieChart.legend.verticalAlignment = .bottom
            pieChart.legend.horizontalAlignment = .center
        } else {
            pieChart.legend.orientation = .vertical
            pieChart.legend.verticalAlignment = .center
            pieChart.legend.horizontalAlignment = .right
        }
        
        bgView.layer.borderColor = AppColors.line.cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


extension MajorDistributionCell: ChartViewDelegate {
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        bottomLabel.attributedText = noSelectionText.styled(with: .basicStyle)
        bottomLabel.textAlignment = .center
        currentSelection = nil
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        guard let data = entry as? PieChartDataEntry else { return }
        
        if currentSelection != entry {
            UISelectionFeedbackGenerator().selectionChanged()
            currentSelection = entry
            
            let plural = data.value == 1.0 ? "" : "s"
            if data.label!.hasPrefix("Unknown") {
                bottomLabel.attributedText = "Unknown / undeclared: \(Int(data.value)) attendee\(plural)".styled(with: .basicStyle)
            } else {
                bottomLabel.attributedText = NSAttributedString.composed(of: [
                    data.label!.styled(with: .valueStyle),
                    " major: \(Int(data.value)) attendee\(plural)".styled(with: .basicStyle)
                ])
            }
            bottomLabel.textAlignment = .center
        } else {
            UISelectionFeedbackGenerator().selectionChanged()
            chartView.highlightValues(nil)
            chartValueNothingSelected(chartView)
        }
    }
}

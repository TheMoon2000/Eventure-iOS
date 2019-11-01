//
//  MajorDistributionCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/10/31.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import Charts

class MajorDistributionCell: UICollectionViewCell {
    
    private var pieChart: PieChartView!
    private var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
            pie.holeRadiusPercent = 0.3
            pie.transparentCircleRadiusPercent = 0.31
            pie.transparentCircleColor = AppColors.subview.withAlphaComponent(0.1)
            pie.holeColor = .clear
            pie.highlightPerTapEnabled = false
            
            let entries = (0..<8).map { (i) -> PieChartDataEntry in
                // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
                return PieChartDataEntry(value: Double(arc4random_uniform(100) + 100 / 5),
                                         label: "Label \(i)",
                                         icon: #imageLiteral(resourceName: "default_user"))
            }
            
            let set = PieChartDataSet(entries: entries, label: "Majors")
            set.drawIconsEnabled = false
            set.sliceSpace = 2
            
            
            set.colors = ChartColorTemplates.material() + ChartColorTemplates.colorful()
            
            let data = PieChartData(dataSet: set)
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .percent
            pFormatter.maximumFractionDigits = 1
            pFormatter.multiplier = 1
            pFormatter.percentSymbol = " %"
            data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            
            data.setValueFont(.systemFont(ofSize: 12))
            data.setValueTextColor(.white)
            
            pie.data = data
            
            
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
            
            pie.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 5).isActive = true
            pie.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -5).isActive = true
            pie.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
            pie.heightAnchor.constraint(equalTo: pie.widthAnchor).isActive = true
            pie.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50).isActive = true
            
            return pie
        }()
    
        
        if frame.width > 500 {
            pieChart.legend.orientation = .vertical
            pieChart.legend.verticalAlignment = .center
            pieChart.legend.horizontalAlignment = .right
        } else {
            pieChart.legend.orientation = .horizontal
            pieChart.legend.verticalAlignment = .bottom
            pieChart.legend.horizontalAlignment = .center
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

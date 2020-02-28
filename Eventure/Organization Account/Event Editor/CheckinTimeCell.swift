//
//  CheckinTimeCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/13.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckinTimeCell: UITableViewCell {
    
    private var bgView: UIView!
    private(set) var slider: UISlider!
    private(set) var sliderTicks: UIView!
    
    private(set) var options: [(label: String, timeInterval: Int)] = [
        ("Start of event", 0),
        ("15 minutes before event starts", 15 * 60),
        ("1 hour before event starts", 3600),
        ("2 hours before event starts", 7200),
        ("1 day before event starts", 24 * 3600),
        ("Any time", -1)
    ]
    private var thumbWidth: CGFloat = 0
    private(set) var caption: UILabel!
    
    var currentValue: Float = 50.0 {
        didSet {
            let segmentLength = 100.0 / Float(options.count - 1)
            let index = Int(round(currentValue / segmentLength))
            caption.text = options[index].label
            changeHandler?(options[index].timeInterval, options[index].label)
        }
    }

    var changeHandler: ((Int, String) -> ())?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let view = UIView()
            view.backgroundColor = AppColors.subview
            view.layer.cornerRadius = 7
            view.applyMildShadow()
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
            
            let b = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
            b.priority = .defaultHigh
            b.isActive = true
            
            return view
        }()
        
        slider = {
            let slider = UISlider()
            slider.alpha = 0.0
            slider.maximumTrackTintColor = .clear
            slider.minimumTrackTintColor = .clear
            slider.thumbTintColor = AppColors.main
            slider.maximumValue = 100
            slider.value = 40.0
            
            slider.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(slider)
            
            slider.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            slider.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            let t = slider.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 20)
            t.priority = .defaultLow
            t.isActive = true
            
            slider.isContinuous = true
            slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
            
            return slider
        }()
        
        caption = {
            let label = UILabel()
            label.font = .appFontRegular(16)
            label.textColor = AppColors.prompt
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: bgView.centerXAnchor).isActive = true
            
            label.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 18).isActive = true
            
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
        
        sliderTicks = addTicks()
    }
    
    private func addTicks() -> UIView {
        
        let ticks = UIView()
        ticks.alpha = 0.0
        ticks.translatesAutoresizingMaskIntoConstraints = false
        bgView.insertSubview(ticks, belowSubview: slider)
        ticks.leftAnchor.constraint(equalTo: slider.leftAnchor).isActive = true
        ticks.rightAnchor.constraint(equalTo: slider.rightAnchor).isActive = true
        ticks.topAnchor.constraint(equalTo: slider.topAnchor).isActive = true
        ticks.bottomAnchor.constraint(equalTo: slider.bottomAnchor).isActive = true
        
        let segmentCount = CGFloat(options.count) - 1
        thumbWidth = slider.thumbRect(
            forBounds: slider.bounds,
            trackRect: slider.trackRect(forBounds: slider.bounds), value: 0).width - 3
        
        let track = UIView()
        track.backgroundColor = AppColors.line
        track.translatesAutoresizingMaskIntoConstraints = false
        ticks.addSubview(track)
        
        track.heightAnchor.constraint(equalToConstant: 2).isActive = true
        track.leftAnchor.constraint(equalTo: slider.leftAnchor,
                                    constant: thumbWidth / 2).isActive = true
        track.rightAnchor.constraint(equalTo: slider.rightAnchor,
                                     constant: -thumbWidth / 2).isActive = true
        track.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
        
        // Ticks
        
        func makeTickmark() -> UIView {
            let tick = UIView()
            tick.backgroundColor = track.backgroundColor
            tick.translatesAutoresizingMaskIntoConstraints = false
            ticks.addSubview(tick)
            
            tick.widthAnchor.constraint(equalToConstant: 2).isActive = true
            tick.heightAnchor.constraint(equalToConstant: 12).isActive = true
            tick.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
            
            return tick
        }
        
        for i in 0..<options.count {
            let tickmark = makeTickmark()
            
            
            //  Pseudocode:
            //  tick.centerX = (slider.right - thumbWidth) * i / segmentCount + thumbWidth / 2
            
            
            //  Note: The `multiplier` property cannot be zero, so we need to use a sufficiently small but positive number instead.
            
            NSLayoutConstraint(item: tickmark,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: ticks,
                               attribute: .right,
                               multiplier: max(0.000001,
                                               CGFloat(i) / segmentCount),
                               constant: -thumbWidth * CGFloat(i) / segmentCount + thumbWidth / 2).isActive = true
            
        }
        
        return ticks
    }
    
    @objc private func sliderChanged() {
        let segment: Float = 100.0 / (Float(options.count) - 1)
        
        let halfThumb = thumbWidth / 2 / slider.frame.width * 100
        
        // Note: we need to recalculate the actual slider value as appeared to the user, because our custom track is narrower than the default track.
        let apparentSliderValue = max(0, CGFloat(slider.value) - halfThumb) * slider.frame.width / (slider.frame.width - thumbWidth)
        
        slider.value = round(Float(apparentSliderValue) / segment) * segment
        if slider.value != currentValue {
            currentValue = slider.value
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

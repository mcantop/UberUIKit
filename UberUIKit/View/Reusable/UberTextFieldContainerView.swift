//
//  UberTextFieldContainerView.swift
//  UberUIKit
//
//  Created by Maciej on 14/08/2023.
//

import UIKit

final class UberTextFieldContainerView: UIView {
    init(image: UIImage?, textfield: UITextField? = nil, segmentedControl: UISegmentedControl? = nil) {
        super.init(frame: .zero)
        
        if let textfield {
            let imageView = UIImageView()
            imageView.image = image?
                .style(size: .largeTitle, weight: .semibold)
            imageView.contentMode = .scaleAspectFit
            imageView.alpha = OpacityType.default.value
            
            addSubview(imageView)
            addSubview(textfield)
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            textfield.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 24),
                
                textfield.centerYAnchor.constraint(equalTo: centerYAnchor),
                textfield.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
                textfield.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            ])
        }
        
        if let segmentedControl {
            addSubview(segmentedControl)
            
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
                segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor),
                segmentedControl.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        /// Don't show a separator for a segmented control.
        if segmentedControl == nil {
            let separatorView = UIView()
            separatorView.backgroundColor = .colorSchemeForegroundColor.withOpacity()
            
            addSubview(separatorView)
            
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
                separatorView.heightAnchor.constraint(equalToConstant: 1),
                separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
                separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

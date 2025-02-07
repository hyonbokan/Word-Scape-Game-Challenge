//
//  GameButton.swift
//  WordScapeGame
//
//  Created by Khen Bo Kan on 2/5/25.
//

import UIKit

/// Custom UIButton for reusability
final class GameButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

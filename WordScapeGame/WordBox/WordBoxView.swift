//
//  WordBoxView.swift
//  WordScapeGame
//
//  Created by Khen Bo Kan on 2/6/25.
//

import UIKit

/// UILabel for a single moving word box
final class WordBoxView: UILabel {
    /// Called when the word is tapped
    var onTap: (() -> Void)?
    
    // MARK: Init
    
    init(viewModel: WordBoxViewModel) {
        super.init(frame: .zero)
        
        self.frame.size = CGSize(width: 80, height: 25) // could be dynamic
        self.text = viewModel.word
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        self.textColor = .white
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        
        self.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSelf))
        self.addGestureRecognizer(tapGesture)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        updateState(state: viewModel.state)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Tap action handling
    
    @objc private func didTapSelf() {
        onTap?()
    }
    
    // MARK: Update UI
    
    func updateState(state: WordState) {
        switch state {
        case .set:
            self.backgroundColor = .systemOrange
        case .moving:
            self.backgroundColor = .systemGreen
        case .finished:
            self.backgroundColor = .systemBlue
        case .captured:
            self.backgroundColor = .systemRed
        }
    }
}

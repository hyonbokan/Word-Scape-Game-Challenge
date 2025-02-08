//
//  WordBoxViewModel.swift
//  WordScapeGame
//
//  Created by Khen Bo Kan on 2/6/25.
//

import UIKit

/// The staes of a word
enum WordState {
    case set
    case moving
    case finished
    case captured
}


/// Manages the logic for a single moving word
final class WordBoxViewModel {
    
    // MARK: Props
    
    private let model: WordModel
    var state: WordState {
        didSet {
            onUpdateState?(state) // notify the view of the state changes
        }
    }
    var xPosition: CGFloat {
        didSet {
            onUpdatePosition?(xPosition)
        }
    }
    
    var onUpdatePosition: ((CGFloat) -> Void)? // notify the position changes
    var onUpdateState: ((WordState) -> Void)? // notify the state changes
    
    var word: String { model.text }
    var speedPercentage: CGFloat { model.speedPercentage }
    
    // MARK: init
    init(model: WordModel) {
        self.model = model
        self.state = .set
        self.xPosition = 0
    }
    
    // MARK: Word movement
    
    /// moves the word on the x axis
    func move(deltaTime: CGFloat, finishLine: CGFloat) {
        guard state == .moving else { return }
        
        let screenWidth = UIScreen.main.bounds.width
        let dynamicSpeed = speedPercentage * screenWidth
        
        xPosition += dynamicSpeed * deltaTime
        if xPosition >= finishLine {
            xPosition = finishLine
            state = .finished
        }
    }
    
    /// captures the word when tapped
    func capture() {
        guard state == .moving else { return }
        state = .captured
    }
}

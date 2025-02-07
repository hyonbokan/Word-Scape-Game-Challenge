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
            onUpdate?() // notify the view of the state changes
        }
    }
    var xPosition: CGFloat
    var onUpdate: (() -> Void)? // notify the view to update color
    var onCapture: ((String) -> Void)? // notify main VC when captured
    
    var word: String { model.text }
    var speed: CGFloat { model.speed }
    
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
        xPosition += speed * deltaTime
        if xPosition >= finishLine {
            xPosition = finishLine
            state = .finished
        }
        
        onUpdate?() // trigger ui update
    }
    
    /// captures the word when tapped
    func capture() {
        guard state == .moving else { return }
        state = .captured
        onCapture?(word)
    }
}

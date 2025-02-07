//
//  GameManager.swift
//  WordScapeGame
//
//  Created by Khen Bo Kan on 2/7/25.
//

import UIKit

protocol GameManagerDelegate: AnyObject {
    func wordDidCapture(_ word: String)
    func wordDidRemove(_ wordBoxView: WordBoxView)
}

/// Handles the game logic such as word movements, captures and game loop
final class GameManager {
    
    // MARK: Props
    weak var delegate: GameManagerDelegate?
    
    private var laneViewModels: [[WordBoxViewModel]] = []
    private var displayLink: CADisplayLink?
    private var lastFrameTime: CFTimeInterval = 0
    
    var onWordCaptured: ((String) -> Void)?
    var onWordRemoved: ((WordBoxView) -> Void)?
    var onNextWordStart: ((WordBoxViewModel) -> Void)?
    
    init(){}
    
    /// Starts the game loop and word movement.
    func startGame() {
        // check if there are any words left
        let wordsToMove = laneViewModels.flatMap { $0 }.contains { $0.state == .set }
        guard wordsToMove else { return }
        
        if displayLink == nil {
            lastFrameTime = CACurrentMediaTime()
            displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
            displayLink?.add(to: .main, forMode: .common)
        }
        for lane in laneViewModels {
            if let firstWord = lane.first(where: { $0.state == .set }) {
                firstWord.state = .moving
            }
        }
    }
    
    /// Resets the game by clearing the lanes and captured words.
    func resetGame() {
        displayLink?.invalidate()
        displayLink = nil
        laneViewModels.removeAll()
    }
    
    // MARK: Game loop
    /// Updates the word position.
    @objc private func gameLoop() {
        guard let displayLink = displayLink else { return }

        let currentTime = displayLink.timestamp
        let deltaTime = CGFloat(currentTime - lastFrameTime)
        lastFrameTime = currentTime

        let finishLine = UIScreen.main.bounds.width - 120 // needs to be dynamic
        
        var hasActiveWords = false

        for words in laneViewModels {
            if let activeWord = words.first(where: { $0.state == .moving }) {
                activeWord.move(deltaTime: deltaTime, finishLine: finishLine)
                hasActiveWords = true
            }
        }
        
        // stop the game loop when tehre are no active words
        if !hasActiveWords {
            displayLink.invalidate()
            self.displayLink = nil
        }
    }
    
    // MARK: Setup lanes
    
    /// Sets up lanes with words and linking VMs to UI Views
    func setupLanes(lanes: [[String]], gameAreaView: UIView) {
        
        let wordHeight: CGFloat = 20
        let lanePadding: CGFloat = 20
        var yOffset: CGFloat = 10
        
        
        for lane in lanes {
            var laneViewModel: [WordBoxViewModel] = []
            
            for (index, word) in lane.enumerated() {
                let wordModel = WordModel(text: word, speed: CGFloat.random(in: 100...300))
                let wordBoxViewModel = WordBoxViewModel(model: wordModel)
                let wordBoxView = WordBoxView(viewModel: wordBoxViewModel)
                
                let wordY = yOffset + CGFloat(index) * (wordHeight + 5)
                wordBoxView.frame.origin = CGPoint(x: 0, y: wordY)
                
                // handle capture tap-capture action
                wordBoxView.onTap = {
                    wordBoxViewModel.capture()
                }
                
                // link VM updates to UI
                wordBoxViewModel.onUpdate = { [weak self, weak wordBoxView, weak wordBoxViewModel] in
                    guard let self = self, let wordBoxView = wordBoxView, let wordBoxViewModel = wordBoxViewModel else { return }

                    // Update word position and color
                    wordBoxView.frame.origin.x = wordBoxViewModel.xPosition
                    wordBoxView.updateState(state: wordBoxViewModel.state)

                    switch wordBoxViewModel.state {
                    case .captured:
                        self.delegate?.wordDidCapture(wordBoxViewModel.word)
                        self.delegate?.wordDidRemove(wordBoxView)
                        if let lane = self.laneViewModels.first(where: { $0.contains(where: { $0 === wordBoxViewModel }) }) {
                            self.startNextWord(in: lane, after: wordBoxViewModel)
                        }

                    case .finished:
                        if let lane = self.laneViewModels.first(where: { $0.contains(where: { $0 === wordBoxViewModel }) }) {
                            self.startNextWord(in: lane, after: wordBoxViewModel)
                        }

                    default:
                        break
                    }
                }
                gameAreaView.addSubview(wordBoxView)
                laneViewModel.append(wordBoxViewModel)
            }
            laneViewModels.append(laneViewModel)
            yOffset += CGFloat(lane.count) * (wordHeight + 5) + lanePadding
        }
    }
    
    /// Starts the next words in the lane after the current words is captured.
    private func startNextWord(in lane: [WordBoxViewModel], after current: WordBoxViewModel) {
        guard let index = lane.firstIndex(where: { $0 === current }), index + 1 < lane.count else { return }
        lane[index + 1].state = .moving
    }
}

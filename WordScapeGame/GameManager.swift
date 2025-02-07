//
//  GameManager.swift
//  WordScapeGame
//
//  Created by Khen Bo Kan on 2/7/25.
//

import UIKit

final class GameManager {
    
    // MARK: Props
    private var laneViewModels: [[WordBoxViewModel]] = []
    var capturedWords: [String] = []
    private var displayLink: CADisplayLink?
    private var lastFrameTime: CFTimeInterval = 0
    
    var onWordCaptured: ((String) -> Void)?
    var onWordRemoved: ((WordBoxView) -> Void)?
    var onNextWordStart: ((WordBoxViewModel) -> Void)?
    
    init(){}
    
    func startGame() {
        // check if there are any words left
        let wordsToMove = laneViewModels.flatMap { $0 }.contains { $0.state == .set }
        guard wordsToMove else { return }
        
        if displayLink == nil {
            lastFrameTime = CACurrentMediaTime()
            displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
            displayLink?.add(to: .main, forMode: .common)
        }
        for words in laneViewModels {
            if let firstWord = words.first(where: { $0.state == .set }) {
                firstWord.state = .moving
            }
        }
    }
    
    func resetGame() {
        displayLink?.invalidate()
        displayLink = nil
        laneViewModels.removeAll()
        capturedWords.removeAll()
    }
    
    // MARK: Game loop
    /// Updates the word position
    @objc private func gameLoop() {
        guard let displayLink = displayLink else { return }

        let currentTime = displayLink.timestamp
        let deltaTime = CGFloat(currentTime - lastFrameTime)
        lastFrameTime = currentTime

        let finishLine = UIScreen.main.bounds.width - 120 // needs to be dynamic
        
        var hasActiveWords = false

        for words in laneViewModels {
            guard let activeWord = words.first(where: { $0.state == .moving }) else { continue }

            activeWord.move(deltaTime: deltaTime, finishLine: finishLine)
            hasActiveWords = true

            if activeWord.state == .finished {
                if let nextIndex = words.firstIndex(where: { $0 === activeWord })?.advanced(by: 1),
                   nextIndex < words.count {
                    words[nextIndex].state = .moving
                }
            }
        }
        
        // stop the game loop when tehre are no active words
        if !hasActiveWords {
            displayLink.invalidate()
            self.displayLink = nil
        }
    }
    
    // MARK: Setup Words
    
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
                
                wordBoxView.onTap = { [ weak wordBoxViewModel ] in
                    wordBoxViewModel?.capture()
                }
                
                // link VM updates to UI
                wordBoxViewModel.onUpdate = { [weak wordBoxView, weak wordBoxViewModel] in
                    guard let wordBoxView = wordBoxView, let wordBoxViewModel = wordBoxViewModel else { return }
                    wordBoxView.frame.origin.x = wordBoxViewModel.xPosition
                    wordBoxView.updateState(state: wordBoxViewModel.state)
                }
                
                wordBoxViewModel.onCapture = { [weak self, weak wordBoxView, weak wordBoxViewModel] capturedWord in
                    self?.capturedWords.append(capturedWord)
                    if let view = wordBoxView {
                        self?.onWordRemoved?(view)
                    }
                    self?.startNextWord(in: laneViewModel, after: wordBoxViewModel)
                    self?.onWordCaptured?(capturedWord)
                }
                
                gameAreaView.addSubview(wordBoxView)
                laneViewModel.append(wordBoxViewModel)
            }
            laneViewModels.append(laneViewModel)
            yOffset += CGFloat(lane.count) * (wordHeight + 5) + lanePadding
        }
    }
    
    private func startNextWord(in lane: [WordBoxViewModel], after capturedWord: WordBoxViewModel?) {
        guard let capturedIndex = lane.firstIndex(where: { $0 === capturedWord }) else { return }
        let nextIndex = capturedIndex + 1
        if nextIndex < lane.count {
            lane[nextIndex].state = .moving
            onNextWordStart?(lane[nextIndex])
        }
    }
}

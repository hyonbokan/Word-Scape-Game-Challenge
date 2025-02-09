//
//  GameManager.swift
//  WordScapeGame
//
//  Created by Khen Bo Kan on 2/7/25.
//

import UIKit
import AVFoundation

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
    private var lastFrame: CFTimeInterval = 0
    
    private weak var gameAreaView: UIView?
    private var previousGameAreaWidth: CGFloat?
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    init(){}
    
    /// Starts the game loop and word movement.
    func startGame() {
        // check if there are any words left
        let wordsToMove = laneViewModels.flatMap { $0 }.contains { $0.state == .set }
        
        guard wordsToMove else { return }
        
        
        if displayLink == nil {
            lastFrame = CACurrentMediaTime()
            displayLink = CADisplayLink(target: self, selector: #selector(gameLoop(displayLink:)))
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
    @objc private func gameLoop(displayLink: CADisplayLink) {
        let currentTime = displayLink.timestamp
        let deltaTime = CGFloat(currentTime - lastFrame)
        lastFrame = currentTime
        
        guard let gameAreaView = gameAreaView else { return }
        
        let gameAreaWidth = gameAreaView.width
        let wordBoxWidth: CGFloat = 80
        let finishLine = gameAreaWidth - wordBoxWidth
        
        var hasActiveWords = false

        for lane in laneViewModels {
            if let activeWord = lane.first(where: { $0.state == .moving }) {
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
        self.gameAreaView = gameAreaView
        
        let wordHeight: CGFloat = 20
        let lanePadding: CGFloat = 20
        var yOffset: CGFloat = 10
        
        
        for (laneIndex, lane) in lanes.enumerated() {
            var laneViewModel: [WordBoxViewModel] = []
            
            for (index, word) in lane.enumerated() {
                let wordModel = WordModel(text: word)
                let wordBoxViewModel = WordBoxViewModel(model: wordModel)
                let wordBoxView = WordBoxView(viewModel: wordBoxViewModel)
                
                gameAreaView.addSubview(wordBoxView)
                
                let leadingConstraint = wordBoxView.leadingAnchor.constraint(equalTo: gameAreaView.leadingAnchor, constant: 0)
                
                NSLayoutConstraint.activate([
                    wordBoxView.topAnchor.constraint(equalTo: gameAreaView.topAnchor, constant: yOffset + CGFloat(index) * (wordHeight + 5)),
                    leadingConstraint,
                    wordBoxView.widthAnchor.constraint(equalToConstant: 80),
                    wordBoxView.heightAnchor.constraint(equalToConstant: wordHeight)
                ])
                
                // handle tap-to-capture action
                wordBoxView.onTap = {
                    wordBoxViewModel.capture()
                }
                
                // update xPosition changes
                wordBoxViewModel.onUpdatePosition = { newXPosition in
                    leadingConstraint.constant = newXPosition
                }
                
                // handle state changes
                wordBoxViewModel.onUpdateState = { [weak self] newState in
                    guard let self = self else { return }
                    
                    wordBoxView.updateState(state: newState)

                    switch newState {
                    case .captured:
                        self.delegate?.wordDidCapture(wordBoxViewModel.word)
                        self.delegate?.wordDidRemove(wordBoxView)
                        self.startNextWord(in: laneIndex, after: wordBoxViewModel)

                    case .finished:
                        self.speak(wordBoxViewModel.word)
                        self.startNextWord(in: laneIndex, after: wordBoxViewModel)

                    default:
                        break
                    }
                }
                
                laneViewModel.append(wordBoxViewModel)
            }
            laneViewModels.append(laneViewModel)
            yOffset += CGFloat(lane.count) * (wordHeight + 5) + lanePadding
        }
    }
    
    /// Starts the next words in the lane after the current words is captured.
    private func startNextWord(in laneIndex: Int, after current: WordBoxViewModel) {
        guard laneIndex < laneViewModels.count else { return }
        
        let lane = laneViewModels[laneIndex]
        guard let index = lane.firstIndex(where: { $0 === current }), index + 1 < lane.count else { return }
        lane[index + 1].state = .moving
    }
    
    private func speak(_ word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.rate = 0.6
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 1.0
        
        DispatchQueue.main.async {
            self.speechSynthesizer.speak(utterance)
        }
    }
    
    func warmUpTTS() {
        let emptyUtterance = AVSpeechUtterance(string: " ")
        emptyUtterance.rate = 0.6

        speechSynthesizer.speak(emptyUtterance)
    }

}

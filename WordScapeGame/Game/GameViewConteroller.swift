//
//  ViewController.swift
//  WordScapeGame
//
//  Created by Khen Bo Kan on 2/5/25.
//

import UIKit

/// The main VC that manages the game UI
final class GameViewController: UIViewController {
    
    private let gameManager = GameManager()
    
    // MARK: UI elemets
    private let startButton: GameButton = {
        let button = GameButton()
        button.setTitle("Start", for: .normal)
        button.backgroundColor = .systemGreen
        return button
    }()
    
    private let resetButton: GameButton = {
        let button = GameButton()
        button.setTitle("Reset", for: .normal)
        button.backgroundColor = .systemGreen
        return button
    }()
    
    private let capturedLabel: UILabel = {
       let label = UILabel()
        label.text = "Captured Words:\n"
        label.numberOfLines = 0
        label.backgroundColor = .systemGray6
        label.layer.borderWidth = 0.5
        label.layer.borderColor = UIColor.lightGray.cgColor
        return label
    }()
    
    private let gameAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        gameManager.delegate = self
        setupUI()
        setupConstraints()
        setupGame()
        gameManager.warmUpTTS()
    }
    
    private func setupUI() {
        view.addSubview(gameAreaView)
        view.addSubview(capturedLabel)
        view.addSubview(startButton)
        view.addSubview(resetButton)
        
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        [gameAreaView, capturedLabel, startButton, resetButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // GameArea
            gameAreaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            gameAreaView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            gameAreaView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            gameAreaView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            // capturedLabel
            capturedLabel.topAnchor.constraint(equalTo: gameAreaView.bottomAnchor, constant: 20),
            capturedLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            capturedLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            capturedLabel.heightAnchor.constraint(equalToConstant: 80),
            
            // startButton
            startButton.topAnchor.constraint(equalTo: capturedLabel.bottomAnchor, constant: 20),
            startButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 44),
            
            // resetButton
            resetButton.topAnchor.constraint(equalTo: capturedLabel.bottomAnchor, constant: 20),
            resetButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            resetButton.widthAnchor.constraint(equalToConstant: 100),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: Button actions
    @objc private func didTapStartButton() {
        gameManager.startGame()
        startButton.isEnabled = false
    }
    
    @objc private func didTapResetButton() {
        gameManager.resetGame()
        capturedLabel.text = "Captured Words:\n"
        gameAreaView.subviews.forEach { $0.removeFromSuperview() }
        setupGame()
        startButton.isEnabled = true
    }
    
    private func setupGame() {
        let lanes = [
            ["apple", "banana", "cherry", "date"],
            ["fig", "elderberry", "grape", "honeydew"],
            ["kiwi", "lemon", "mango", "nectarine"],
            ["papaya", "resberry", "orange", "quince"],
        ]
        gameManager.setupLanes(lanes: lanes, gameAreaView: gameAreaView)
    }
}

// MARK: GameManagerDelegate
extension GameViewController: GameManagerDelegate {
    func wordDidCapture(_ word: String) {
        capturedLabel.text?.append("\(word)  ")
    }
    
    func wordDidRemove(_ wordBoxView: WordBoxView) {
        wordBoxView.removeFromSuperview()
    }
}

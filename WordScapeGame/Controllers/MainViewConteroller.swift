//
//  ViewController.swift
//  WordScapeGame
//
//  Created by Khen Bo Kan on 2/5/25.
//

import UIKit

/// The main VC that manages the game UI
final class MainViewController: UIViewController {
    
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
        addSubviews()
        configureButtons()
        addBindings()
        setupGame()
    }
    
    private func addSubviews() {
        view.addSubview(gameAreaView)
        view.addSubview(capturedLabel)
        view.addSubview(startButton)
        view.addSubview(resetButton)
    }
    
    private func configureButtons() {
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let padding: CGFloat = 20
        let topInset = view.safeAreaInsets.top
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        let gameAreaHeight = viewHeight * 0.6
        
        gameAreaView.frame = CGRect(
            x: padding,
            y: topInset + padding,
            width: viewWidth - padding * 2,
            height: gameAreaHeight
         )

         capturedLabel.frame = CGRect(
            x: padding,
            y: gameAreaView.frame.maxY + padding,
            width: viewWidth - padding * 2,
            height: 80
        )

        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        let totalButtonWidth = buttonWidth * 2 + padding
        let buttonX = (viewWidth - totalButtonWidth) / 2
        
        startButton.frame = CGRect(
             x: buttonX,
             y: capturedLabel.bottom + padding,
             width: buttonWidth,
             height: buttonHeight
        )
        resetButton.frame = CGRect(
            x: startButton.right + padding,
            y: capturedLabel.bottom + padding,
            width: buttonWidth,
            height: buttonHeight
        )
    }

    // MARK: Button actions
    @objc private func didTapStartButton() {
        gameManager.startGame()
    }
    
    @objc private func didTapResetButton() {
        gameManager.resetGame()
        capturedLabel.text = "Captured Words:\n"
        gameAreaView.subviews.forEach { $0.removeFromSuperview() }
        setupGame()
    }
    
    private func addBindings() {
        gameManager.onWordCaptured = { [weak self] word in
            self?.updateCapturedWord()
        }
        
        gameManager.onWordRemoved = { wordBoxView in
            wordBoxView.removeFromSuperview()
        }
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
    
    private func updateCapturedWord() {
        capturedLabel.text = "Captured Words:\n" + gameManager.capturedWords.joined(separator: "  ")
    }
}

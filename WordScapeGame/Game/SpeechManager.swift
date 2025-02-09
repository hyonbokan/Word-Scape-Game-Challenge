//
//  SpeechManager.swift
//  WordScapeGame
//
//  Created by Khen Bo Kan on 2/9/25.
//

import Speech

protocol SpeechManagerDelegate: AnyObject {
    func didRecognizeWord(_ recognizedWord: String)
}

class SpeechManager: NSObject, SFSpeechRecognizerDelegate {
    
    weak var delegate: SpeechManagerDelegate?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var isAuthorized: Bool = false
    
    override init() {
        super.init()
        // Request speech authorization once at init (or from your ViewController’s viewDidLoad).
        requestSpeechAuthorization()
    }
    
    func startListening() {
        guard isAuthorized else {
            print("SpeechManager: Not authorized, can't start listening.")
            return
        }
        
        // If there's a running session, stop it first
        if audioEngine.isRunning {
            stopListening()
        }
        
        beginSession()
    }
    
    func stopListening() {
        let inputNode = audioEngine.inputNode
        
        // Remove the tap
        inputNode.removeTap(onBus: 0)
        
        // Stop the engine
        audioEngine.stop()
        
        // End the recognition request & cancel task
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        // Cleanup
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    private func beginSession() {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // Enough for speech + record
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("SpeechManager: Audio session error - \(error.localizedDescription)")
            return
        }

        let inputNode = audioEngine.inputNode
        
        // Create a new request & re-install tap
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            [weak recognitionRequest] buffer, _ in
            recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("SpeechManager: Audio engine couldn't start. \(error.localizedDescription)")
            return
        }

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else { return }
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let recognizedText = result.bestTranscription.formattedString.lowercased()
                self.delegate?.didRecognizeWord(recognizedText)
            }
            
            if let error = error {
                print("Recognition error: \(error.localizedDescription)")
                // Re-start if we want continuous indefinite listening
                self.restartSessionIfNeeded()
            } else if result?.isFinal == true {
                // Re-start if indefinite, or do nothing if final is enough
                self.restartSessionIfNeeded()
            }
        }
    }
    
    private func restartSessionIfNeeded() {
        stopListening()
        beginSession()
    }

    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.isAuthorized = true
                    print("SpeechManager: Speech recognition authorized.")
                case .denied, .restricted, .notDetermined:
                    self.isAuthorized = false
                    print("SpeechManager: Speech recognition not authorized.")
                @unknown default:
                    self.isAuthorized = false
                }
            }
        }
    }
}

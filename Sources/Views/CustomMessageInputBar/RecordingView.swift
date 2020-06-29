//
//  RecordingView.swift
//  MessageKit
//
//  Created by Ankush Bhatia on 26/06/20.
//

import UIKit

protocol RecordingViewDelegate: AnyObject {

    func remove(_ view: RecordingView)
}

class RecordingView: UIView {
    
    // MARK: - Properties
    private var micImageView = UIImageView()
    private var trashImageView: UIImageView?
    private var timerLabel: UILabel = UILabel()
    private var currentTime = Date()
    private var recordingTimer: Timer?
    private var slidingButton = UIButton()
    private var shakeAnimation: CAKeyframeAnimation?
    private let shakeAnimationKey = "transform"
    
    weak var delegate: RecordingViewDelegate?
    
    // MARK: - Initialisers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented in the storyboard.")
    }
    
    // MARK: - Functions
    private func setup() {
        setupMicTimerImageView()
        setupTimerLabel()
        createTimer()
        setupSlideToCancelButton()
        addConstraintsToMicImageView()
        addConstraintsToTimerLabel()
        addConstrintsToSlideToCancelButton()
        
        addAnimations()
    }
    
    private func setupMicTimerImageView() {
        var micImageView: UIImageView!
        if #available(iOS 13.0, *) {
            micImageView = UIImageView(image: UIImage(systemName: "mic.fill"))
        } else {
            // Fallback on earlier versions
        }
        micImageView.tintColor = .white
        self.micImageView = micImageView
        addSubview(micImageView)
    }
    
    private func addConstraintsToMicImageView() {
        micImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            micImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
            micImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupTimerLabel() {
        let timerLabel = UILabel()
        timerLabel.textColor = .white
        timerLabel.text = "0s"
        addSubview(timerLabel)
        self.timerLabel = timerLabel
    }
    
    private func addConstraintsToTimerLabel() {
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timerLabel.leadingAnchor.constraint(equalTo: micImageView.trailingAnchor, constant: 12),
            timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func createTimer() {
        if recordingTimer == nil {
            self.currentTime = Date()
            let timer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(handleTimer),
                                             userInfo: nil,
                                             repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1
            self.recordingTimer = timer
        }
    }
    
    private func cancelRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    @objc private func handleTimer() {
        let time = Date().timeIntervalSince(currentTime)
        
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        var times: [String] = []
        if hours > 0 {
            times.append("\(hours)h")
        }
        if minutes > 0 {
            times.append("\(minutes)m")
        }
        times.append("\(seconds)s")
        
        self.timerLabel.text = times.joined(separator: " ")
    }
    
    private func setupSlideToCancelButton() {
        let button = UIButton(type: .custom)
        button.isUserInteractionEnabled = false
        button.setTitle("Slide to Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        var leftImage: UIImage?
        if #available(iOS 13.0, *) {
            leftImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        button.tintColor = .black
        button.setImage(leftImage, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: 0,
                                              right: 10)
        button.titleEdgeInsets = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: 0,
                                              right: -10)
        
        addSubview(button)
        self.slidingButton = button
    }
    
    private func addConstrintsToSlideToCancelButton() {
        slidingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slidingButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            slidingButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func addAnimations() {
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       options: [.curveEaseInOut, .repeat, .autoreverse],
                       animations: {
                        self.micImageView.tintColor = .red
                        self.timerLabel.alpha = 0.0
        }, completion: nil)
    }
    
    func clean() {
        cancelRecordingTimer()
    }
    
    func handlePan(_ state: UIPanGestureRecognizer.State,
                   translation: CGPoint) {
        switch state {
        case .changed:
            if translation.x < 0 {
                if slidingButton.frame.intersects(timerLabel.frame.offsetBy(dx: 1.0, dy: 0)) {
                    stopShakeAnimation()
                    delegate?.remove(self)
                } else {
                    slidingButton.transform = CGAffineTransform(translationX: translation.x, y: 0)
                }
                if slidingButton.frame.intersects(timerLabel.frame.offsetBy(dx: 30.0, dy: 0)) {
                    slidingButton.tintColor = .red
                    slidingButton.setTitleColor(.red, for: .normal)
                    if shakeAnimation == nil {
                        startShakeAnimation()
                    }
                } else {
                    slidingButton.tintColor = .black
                    slidingButton.setTitleColor(.black, for: .normal)
                    stopShakeAnimation()
                }
            }
        case .ended:
            delegate?.remove(self)
        default:
            break
        }
    }
    
    private func startShakeAnimation() {
        let shakeAnimation = CAKeyframeAnimation(keyPath: shakeAnimationKey)
        shakeAnimation.values = [NSValue(caTransform3D: CATransform3DMakeRotation(0.2, 0.0, 0.0, 1.0)),
                                  NSValue(caTransform3D: CATransform3DMakeRotation(-0.2, 0, 0, 1))]
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.2
        shakeAnimation.repeatCount = .infinity
        micImageView.layer.add(shakeAnimation, forKey: shakeAnimationKey)
        self.shakeAnimation = shakeAnimation
    }
    
    private func stopShakeAnimation() {
        micImageView.layer.removeAnimation(forKey: shakeAnimationKey)
        shakeAnimation = nil
    }
}

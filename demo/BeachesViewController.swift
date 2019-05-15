//
//  ViewController.swift
//  demo
//
//  Created by Johan Halin on 12/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import UIKit
import AVFoundation
import SceneKit
import Foundation

class BeachesViewController: UIViewController {
    let autostart = false
    
    let audioPlayer: AVAudioPlayer
    let startButton: UIButton
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)
    let containerView = UIView(frame: .zero)
    
    var wobblyViews = [BeachesWobblyView]()
    var wobblyView: BeachesWobblyView?
    var textView: BeachesTextView?
    var bg: UIView?
    
    var introPosition = 0
    
    var textTimer: Timer?
    
    // MARK: - UIViewController
    
    init() {
        if let trackUrl = Bundle.main.url(forResource: "beaches", withExtension: "m4a") {
            guard let audioPlayer = try? AVAudioPlayer(contentsOf: trackUrl) else {
                abort()
            }
            
            self.audioPlayer = audioPlayer
        } else {
            abort()
        }
        
        let startButtonText =
            "\"beaches leave\"\n" +
                "by jumalauta\n" +
                "\n" +
                "programming and music by ylvaes\n" +
                "text by soluttautuja\n" +
                "\n" +
                "presented at skeneklubi annual meeting 2019\n" +
                "\n" +
        "tap anywhere to start"
        self.startButton = UIButton.init(type: UIButton.ButtonType.custom)
        self.startButton.setTitle(startButtonText, for: UIControl.State.normal)
        self.startButton.titleLabel?.numberOfLines = 0
        self.startButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.startButton.backgroundColor = UIColor.black
        
        super.init(nibName: nil, bundle: nil)
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControl.Event.touchUpInside)
        
        self.view.backgroundColor = .black
        
        self.qtFoolingBgView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // barely visible tiny view for fooling Quicktime player. completely black images are ignored by QT
        self.view.addSubview(self.qtFoolingBgView)
        
        self.containerView.backgroundColor = .black
        self.containerView.isHidden = true
        self.view.addSubview(self.containerView)
        
        if !self.autostart {
            self.view.addSubview(self.startButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.audioPlayer.prepareToPlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.qtFoolingBgView.frame = CGRect(
            x: (self.view.bounds.size.width / 2) - 1,
            y: (self.view.bounds.size.height / 2) - 1,
            width: 2,
            height: 2
        )

        self.containerView.frame = self.view.bounds
        
        self.bg = UIView()
        self.bg?.frame = CGRect(x: self.view.bounds.size.width / 2.0, y: 0, width: 0, height: self.view.bounds.size.height)
        self.bg?.backgroundColor = .white
        self.containerView.addSubview(self.bg!)

        for i in 0...7 {
            let color: UIColor
            switch i {
            case 0:
                color = UIColor(red: (127.0 / 255.0), green: 0, blue: 1, alpha: 1)
            case 1:
                color = UIColor(red: (63.0 / 255.0), green: 0, blue: 1, alpha: 1)
            case 2:
                color = .blue
            case 3:
                color = .green
            case 4:
                color = .yellow
            case 5:
                color = .orange
            case 6:
                color = .red
            case 7:
                color = .white
            default:
                abort()
            }
            
            let scale: CGFloat = 3.0 - ((CGFloat(i) / 7.0) * 2.0)
            
            let wobblyView = BeachesWobblyView(frame: self.view.bounds, tintColor: color, singleImage: true)
            wobblyView.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            wobblyView.isHidden = true
            self.containerView.addSubview(wobblyView)

            self.wobblyViews.append(wobblyView)
        }

        let wobblyView = BeachesWobblyView(frame: self.view.bounds, tintColor: .black, singleImage: false)
        self.containerView.addSubview(wobblyView)
        self.wobblyView = wobblyView
        
        let textView = BeachesTextView(frame: self.view.bounds)
        self.containerView.addSubview(textView)
        self.textView = textView
        
        self.startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.autostart {
            start()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.audioPlayer.stop()
        
        self.textTimer?.invalidate()
        self.textTimer = nil
    }
    
    // MARK: - Private
    
    @objc
    fileprivate func startButtonTouched(button: UIButton) {
        self.startButton.isUserInteractionEnabled = false
        
        // long fadeout to ensure that the home indicator is gone
        UIView.animate(withDuration: 4, animations: {
            self.startButton.alpha = 0
        }, completion: { _ in
            self.start()
        })
    }
    
    fileprivate func start() {
        self.audioPlayer.play()
        
        self.containerView.isHidden = false
        
        scheduleEvents()
    }
    
    private func scheduleEvents() {
        let bpm = 120.0
        let bar = (120.0 / bpm)
        let tick = bar / 16.0

        perform(#selector(startTransition), with: nil, afterDelay: 0)
        
        let introStart = 4.0
        
        perform(#selector(introEvent), with: nil, afterDelay: introStart)
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 6.0))
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 12.0))
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 16.0))
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 28.0))
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 30.0))
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 32.0))
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 38.0))
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 44.0))
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 48.0))
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 52.0))
        perform(#selector(introEvent), with: nil, afterDelay: introStart + (tick * 60.0))

        perform(#selector(startAnimation), with: nil, afterDelay: 8)
        
        perform(#selector(startShowingText), with: nil, afterDelay: 16)
    }
    
    @objc private func startTransition() {
        UIView.animate(withDuration: 4, delay: 0, options: [.curveEaseOut], animations: {
            self.bg?.bounds.size.width = self.view.bounds.size.width
            self.bg?.frame.origin.x = 0
        }, completion: nil)
    }
    
    @objc private func introEvent() {
        self.wobblyView?.showImage(index: self.introPosition)
        
        if self.introPosition == 11 {
            UIView.animate(withDuration: 0.25, animations: {
                self.wobblyView?.transform = CGAffineTransform.identity.scaledBy(x: 3, y: 3)
            })
        }
        
        self.introPosition += 1
    }
    
    @objc private func startAnimation() {
        self.wobblyView?.isHidden = true
        
        for view in self.wobblyViews {
            view.isHidden = false
            view.animate()
        }
    }
    
    @objc private func startShowingText() {
        self.textView?.showNextImage()

        self.textTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true, block: { timer in
            self.textView?.showNextImage()
        })
    }
}

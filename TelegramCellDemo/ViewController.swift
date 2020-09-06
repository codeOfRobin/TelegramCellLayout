//
//  ViewController.swift
//  TelegramCellDemo
//
//  Created by Robin Malhotra on 06/09/20.
//

import UIKit

class TelegramView: UIView {
	let messageLabel = UITextView()
	let timeLabel = UITextView()

	var cachedFrames: (message: CGRect, time: CGRect, sameLine: Bool)?

	init(message: String, time: String) {
		///BLEEH why isn't this fixed yet
		super.init(frame: .zero)
		/// Still sucks that UIKit doesn't have a well defined place to "set the state", so here we are
		self.messageLabel.text = message
		self.timeLabel.text = time
		self.addSubview(messageLabel)
		self.addSubview(timeLabel)
		self.timeLabel.textAlignment = .right
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	///TODO: make the return an elegant enum
	func calculateFrames(size: CGSize) -> (message: CGRect, time: CGRect, sameLine: Bool) {
		let textContainer = NSTextContainer(size: size)
		messageLabel.layoutManager.insertTextContainer(textContainer, at: 0)
		messageLabel.layoutManager.ensureLayout(for: textContainer)
		let messageLabelLastGlyphFrame = messageLabel.layoutManager.boundingRect(forGlyphRange: NSRange(location: messageLabel.text.count - 1, length: 1), in: textContainer)

		print(messageLabel.layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: 1), in: textContainer))

		let timeTextContainer = NSTextContainer(size: CGSize(width: size.width - messageLabelLastGlyphFrame.maxY, height: size.height))
		timeLabel.layoutManager.insertTextContainer(timeTextContainer, at: 0)
		timeLabel.layoutManager.ensureLayout(for: timeTextContainer)

		let timeLabelLastGlyphFrame = timeLabel.layoutManager.boundingRect(forGlyphRange: NSRange(location: timeLabel.text.count - 1, length: 1), in: timeTextContainer)
		let timeLabelLastLineFrame = timeLabel.layoutManager.lineFragmentRect(forGlyphAt: 0, effectiveRange: nil)

		let estimatedMessageSize = messageLabel.layoutManager.usedRect(for: textContainer).size
		let estimatedTimeSize = timeLabel.layoutManager.usedRect(for: timeTextContainer).size

		messageLabel.layoutManager.removeTextContainer(at: 0)
		timeLabel.layoutManager.removeTextContainer(at: 0)
		if timeLabelLastGlyphFrame.origin.y > 0 {
			let messageLabelFrame = CGRect(origin: .zero, size: estimatedMessageSize)
			let timeLabelFrame = CGRect(origin: CGPoint(x: 0, y: messageLabelFrame.maxY), size: estimatedTimeSize)
			return (message: messageLabelFrame, time: timeLabelFrame, sameLine: false)
		} else {
			let messageLabelFrame = CGRect(origin: .zero, size: estimatedMessageSize)
			///Assume timeLabel is one line
			let width = size.width - messageLabelFrame.width
			let timeLabelFrame = CGRect(x: messageLabelFrame.maxX, y: messageLabelLastGlyphFrame.minY, width: width, height: timeLabelLastLineFrame.height)
			return (message: messageLabelFrame, time: timeLabelFrame, sameLine: true)
		}
	}

	override func sizeThatFits(_ size: CGSize) -> CGSize {
		let results = calculateFrames(size: size)
		self.cachedFrames = results
		if results.sameLine {
			return CGSize(width: size.width, height: results.message.height)
		} else {
			return CGSize(width: size.width, height: results.message.height + results.time.height)
		}
	}

	override func layoutSubviews() {

		guard let (messageLabelFrame, timeLabelFrame, _) = self.cachedFrames else {
			return
		}
		messageLabel.frame = messageLabelFrame
		timeLabel.frame = timeLabelFrame
	}
}

class ViewController: UIViewController {

	let telegramView = TelegramView(message: "long message that does messagey things", time: "9:41 AM")

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		self.view.addSubview(telegramView)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let size = telegramView.sizeThatFits(CGSize(width: view.frame.width, height: .infinity))
		telegramView.frame = CGRect(origin: .zero, size: size)
	}


}


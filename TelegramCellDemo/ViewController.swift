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

		let timeTextContainer = NSTextContainer(size: size)
		timeLabel.layoutManager.insertTextContainer(timeTextContainer, at: 0)
		timeLabel.layoutManager.ensureLayout(for: timeTextContainer)

		let timeLabelLastGlyphFrame = timeLabel.layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: 1), in: timeTextContainer)

		let estimatedMessageLastLineWidth = messageLabelLastGlyphFrame.maxX
		let estimatedTimeWidth = size.width - timeLabelLastGlyphFrame.minX

		messageLabel.layoutManager.removeTextContainer(at: 0)
		timeLabel.layoutManager.removeTextContainer(at: 0)

		if estimatedTimeWidth + estimatedMessageLastLineWidth < size.width {
			let messageFrame = messageLabel.layoutManager.usedRect(for: textContainer)
			let timeFrame = timeLabel.layoutManager.usedRect(for: timeTextContainer)
			let newTimeFrame = CGRect(x: timeLabelLastGlyphFrame.maxX, y: timeLabelLastGlyphFrame.minY, width: timeFrame.width, height: timeFrame.height)
			return (message: messageFrame, time: newTimeFrame, sameLine: true)
		} else {
			let messageFrame = messageLabel.layoutManager.usedRect(for: textContainer)
			let timeFrame = timeLabel.layoutManager.usedRect(for: timeTextContainer)
			let newTimeFrame = CGRect(x: 0, y: 0, width: timeFrame.width, height: timeFrame.height)
			return (message: messageFrame, time: newTimeFrame, sameLine: true)
		}

		fatalError()
//		if timeLabelLastGlyphFrame.origin.y > 0 {
//			let messageLabelFrame = CGRect(origin: .zero, size: estimatedMessageSize)
//			let timeLabelFrame = CGRect(origin: CGPoint(x: 0, y: messageLabelFrame.maxY), size: estimatedTimeSize)
//			return (message: messageLabelFrame, time: timeLabelFrame, sameLine: false)
//		} else {
//			let messageLabelFrame = CGRect(origin: .zero, size: estimatedMessageSize)
//			///Assume timeLabel is one line
//			let width = size.width - messageLabelFrame.width
//			let timeLabelFrame = CGRect(x: messageLabelFrame.maxX, y: messageLabelLastGlyphFrame.minY, width: width, height: timeLabelLastLineFrame.height)
//			return (message: messageLabelFrame, time: timeLabelFrame, sameLine: true)
//		}
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


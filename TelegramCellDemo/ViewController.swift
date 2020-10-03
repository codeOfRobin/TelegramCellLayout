//
//  ViewController.swift
//  TelegramCellDemo
//
//  Created by Robin Malhotra on 06/09/20.
//

import UIKit

extension CGRect {
	func alignToPixelGrid() -> CGRect {
		return CGRect(x: round(self.origin.x), y: round(self.origin.y), width: round(self.width), height: round(self.height))
	}
}

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
		self.timeLabel.textContainerInset = .zero
		self.messageLabel.textContainerInset = .zero
		self.messageLabel.textContainer.lineFragmentPadding = 0.0
		self.timeLabel.textContainer.lineFragmentPadding = 0.0
		self.messageLabel.font = UIFont.systemFont(ofSize: 20.0)
		self.messageLabel.bounces = false
		self.timeLabel.bounces = false

//		self.messageLabel.backgroundColor = .systemTeal
//		self.timeLabel.backgroundColor = .systemGreen
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	///TODO: make the return an elegant enum
	func calculateFrames(size: CGSize) -> (message: CGRect, time: CGRect, sameLine: Bool) {
		let textContainer = NSTextContainer(size: size)
		messageLabel.layoutManager.insertTextContainer(textContainer, at: 0)
		textContainer.heightTracksTextView = true
		messageLabel.layoutManager.ensureLayout(for: textContainer)
		let messageLabelLastGlyphFrame = messageLabel.layoutManager.boundingRect(forGlyphRange: NSRange(location: messageLabel.text.count - 1, length: 1), in: textContainer)

		let timeTextContainer = NSTextContainer(size: size)
		timeLabel.layoutManager.insertTextContainer(timeTextContainer, at: 0)
		timeLabel.layoutManager.ensureLayout(for: timeTextContainer)

		let timeLabelLastGlyphFrame = timeLabel.layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: 1), in: timeTextContainer)

		let estimatedMessageLastLineWidth = messageLabelLastGlyphFrame.maxX
		let estimatedTimeWidth = size.width - timeLabelLastGlyphFrame.minX

		let oldMessageFrame = messageLabel.layoutManager.usedRect(for: textContainer)
		let messageFrame = CGRect(origin: .zero, size: CGSize(width: size.width, height: oldMessageFrame.height))
		let timeFrame = timeLabel.layoutManager.usedRect(for: timeTextContainer)
		messageLabel.layoutManager.removeTextContainer(at: 0)
		timeLabel.layoutManager.removeTextContainer(at: 0)

		let descenderDiff = ((messageLabel.font!.descender) - (timeLabel.font!.descender))

		if estimatedTimeWidth + estimatedMessageLastLineWidth < size.width {
			let newTimeFrame = CGRect(x: messageLabelLastGlyphFrame.maxX, y: messageLabelLastGlyphFrame.maxY - timeFrame.height + descenderDiff, width: size.width - messageLabelLastGlyphFrame.maxX, height: timeFrame.height)
			return (message: messageFrame.alignToPixelGrid(), time: newTimeFrame.alignToPixelGrid(), sameLine: true)
		} else {
			let newTimeFrame = CGRect(x: 0, y: messageFrame.maxY, width: size.width, height: timeFrame.height)
			return (message: messageFrame.alignToPixelGrid(), time: newTimeFrame.alignToPixelGrid(), sameLine: true)
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

	let telegramView0 = TelegramView(message: "short message short message", time: "9:41 AM")
	let telegramView1 = TelegramView(message: "long message that does messagey things too amongst others", time: "9:41 AM")
	let telegramView2 = TelegramView(message: "long message that doesn't do much", time: "9:41 AM")


	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		self.view.addSubview(telegramView0)
		self.view.addSubview(telegramView1)
		self.view.addSubview(telegramView2)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let size0 = telegramView0.sizeThatFits(CGSize(width: view.frame.width, height: .infinity))
		let size1 = telegramView1.sizeThatFits(CGSize(width: view.frame.width, height: .infinity))
		let size2 = telegramView2.sizeThatFits(CGSize(width: view.frame.width, height: .infinity))
		telegramView0.frame = CGRect(origin: CGPoint(x: 0, y: 100), size: size0)
		telegramView1.frame = CGRect(origin: CGPoint(x: 0, y: telegramView0.frame.maxY + 20), size: size1)
		telegramView2.frame = CGRect(origin: CGPoint(x: 0, y: telegramView1.frame.maxY + 20), size: size2)
	}


}


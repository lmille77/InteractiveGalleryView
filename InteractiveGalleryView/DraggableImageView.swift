//
//  DraggableImageView.swift
//  WhiteStarGalleryView
//
//  Created by Logan Miller on 11/11/22.
//

import UIKit
import RxSwift

enum SwipeAxis {
	case horizontal
	case vertical
	case none
}

enum SwipeDirection {
	case up
	case down
	case left
	case right
	case none
}

enum ViewState {
	case visible
	case hidden
}

class DraggableImageView: UIImageView {
	
	internal let screenWidth = UIScreen.main.bounds.width
	internal let screenHeight = UIScreen.main.bounds.height
	
	//
	// Touch properties
	//
	
	internal var isPanning : Bool = false
	internal var isZoomed : Bool = false
	internal let velocityThreshold : CGFloat = 30.0
	internal let alphaOffset : CGFloat = 0.50
	internal let longAnimationDuration = 0.50
	internal let shortAnimationDuration = 0.25
	internal var localTouchPosition : CGPoint? = nil
	internal var centerScreen : CGPoint? = nil
	internal var initialTouch : CGPoint? = nil
	internal var finalTouch : CGPoint? = nil

	//
	// Swipe properties
	//
	
	internal var swipeAxis : SwipeAxis = SwipeAxis.none
	internal var swipeDirection : SwipeDirection = SwipeDirection.none
	
	internal var alphaOutput = PublishSubject<CGFloat>()
	internal var viewStateOutput = PublishSubject<ViewState>()

	//
	// Initialization
	//
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.isUserInteractionEnabled = true
	}
	
	public init() {
		super.init(image: UIImage.init())
		self.isUserInteractionEnabled = true
	}
	
	public init(image: UIImage) {
		super.init(image: image)
		self.isUserInteractionEnabled = true
	}
	
	//
	// Touch delegate functions
	//
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		let touch = touches.first
		self.localTouchPosition = touch?.preciseLocation(in: self)
		self.initialTouch = touch?.preciseLocation(in: self.superview)
		self.centerScreen = self.frame.origin
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		let touch = touches.first
		
		guard let finalTouch = touch?.preciseLocation(in: self.superview),
			  let previousTouch = touch?.previousLocation(in: self.superview) else { return }
		
		self.isPanning = true
		updateSwipe(finalTouch: finalTouch)
		updateSwipeVelocity(previousTouch: previousTouch, finalTouch: finalTouch)
		updateAlphaValue()
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		guard let centerScreen = self.centerScreen else { return }
		
		UIView.animate(withDuration: shortAnimationDuration) {
			self.frame.origin = CGPoint(x: centerScreen.x, y: centerScreen.y)
			self.alphaOutput.onNext(1.0)
		}
		
		self.isPanning = false
		self.localTouchPosition = nil
		self.initialTouch = nil
		self.finalTouch = nil
		self.centerScreen = nil
		self.swipeAxis = .none
		self.swipeDirection = .none
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		guard let centerScreen = self.centerScreen else { return }
		
		UIView.animate(withDuration: shortAnimationDuration) {
			self.frame.origin = CGPoint(x: centerScreen.x, y: centerScreen.y)
			self.alphaOutput.onNext(1.0)
		}
		
		self.isPanning = false
		self.localTouchPosition = nil
		self.initialTouch = nil
		self.finalTouch = nil
		self.centerScreen = nil
		self.swipeAxis = .none
		self.swipeDirection = .none
	}
	
	public func updateSwipe (finalTouch : CGPoint) {
		guard let localTouchPosition = self.localTouchPosition,
			  let centerScreen = self.centerScreen,
			  let initialTouch = self.initialTouch else { return }
		
		switch (swipeAxis) {
		case .horizontal:
			swipeDirection = (finalTouch.x - initialTouch.x < 0) ? .left : .right
			self.frame.origin = CGPoint(x: finalTouch.x  - localTouchPosition.x, y: centerScreen.y)
		case .vertical:
			swipeDirection = (finalTouch.y - initialTouch.y < 0) ? .up : .down
			self.frame.origin = CGPoint(x: centerScreen.x, y: finalTouch.y - localTouchPosition.y)
		case .none:
			let xDelta = abs(finalTouch.x - initialTouch.x)
			let yDelta = abs(finalTouch.y - initialTouch.y)
			swipeAxis = (xDelta > yDelta) ? .horizontal : .vertical
		}
	}
	
	public func updateAlphaValue() {
		guard let centerScreen = self.centerScreen, !isZoomed else { return }
		
		var alphaValue = 1.0
		
		switch (swipeDirection) {
		case .up:
			alphaValue = self.frame.minY / centerScreen.y
		case .down:
			alphaValue = 1 - ((self.frame.minY / centerScreen.y) - 1)
		case .left:
			alphaValue = self.frame.minX / centerScreen.x
		case .right:
			alphaValue = 1 - ((self.frame.minX / centerScreen.x) - 1)
		default:
			break
		}
		alphaOutput.onNext(alphaValue + alphaOffset)
	}
	
	public func updateSwipeVelocity(previousTouch : CGPoint, finalTouch : CGPoint) {
		var distance : CGFloat?
		
		switch (swipeAxis) {
		case .horizontal:
			distance = previousTouch.x - finalTouch.x
		case .vertical:
			distance = previousTouch.y - finalTouch.y
		default:
			break
		}
		
		if swipeDirection == .right || swipeDirection == .down {
			distance = abs(distance ?? CGFloat.zero)
		}
		
		if distance ?? CGFloat.zero > velocityThreshold {
			self.viewStateOutput.onNext(.hidden)
		}
	}
}

//
//  GalleryView.swift
//  WhiteStarGalleryView
//
//  Created by Logan Miller on 11/11/22.
//

import UIKit
import RxSwift

class GalleryView: UIScrollView {
	
	//
	// View properties
	//
	
	fileprivate var isConstraints : Bool = false
	fileprivate var imageHeight : CGFloat = 0.0
	fileprivate var imageWidth : CGFloat = 0.0
	fileprivate var viewState : ViewState = ViewState.visible

	internal var isZoomed : Bool {
		set { imageView.isZoomed = newValue }
		get { return imageView.isZoomed }
	}
	
	internal var isPanning : Bool  {
		return imageView.isPanning
	}
	
	internal var shortAnimationDuration : Double  {
		return imageView.shortAnimationDuration
	}
	
	internal var longAnimationDuration : Double  {
		return imageView.longAnimationDuration
	}
	
	//
	// Components
	//
	
	fileprivate var disposeBag = DisposeBag()
	internal var baseView = UIView()
	internal var imageView = DraggableImageView()
	internal var viewStateOutput = PublishSubject<ViewState>()
	
	internal var imageViewFrame : CGRect  {
		set { imageView.frame = newValue }
		get { return imageView.frame }
	}
	
	//
	// Initialization
	//
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		if !isConstraints {
			self.bouncesZoom = false
			setupView()
			setupViewBindings()
			isConstraints = true
		}
	}
	
	public func setupView() {
		self.addSubview(baseView)
		self.baseView.translatesAutoresizingMaskIntoConstraints = false
		self.baseView.backgroundColor = .black
		self.baseView.widthToSuperview()
		self.baseView.heightToSuperview()
		self.baseView.centerXToSuperview()
		self.baseView.centerYToSuperview()
	
		self.baseView.addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		self.imageView.widthToSuperview(multiplier: imageWidth)
		self.imageView.heightToSuperview(multiplier: imageHeight)
		self.imageView.centerXToSuperview()
		self.imageView.centerYToSuperview()
	}
	
	public func setupViewBindings() {
		imageView.alphaOutput
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] alphaValue in
				var duration = self?.imageView.shortAnimationDuration
				var alphaValue = alphaValue
				
				if alphaValue.isInfinite || alphaValue.isNaN {
					alphaValue = self?.imageView.alphaOffset ?? CGFloat.zero
					duration = self?.imageView.longAnimationDuration
				}
				
				UIView.animate(withDuration: duration ?? Double.zero) {
					self?.baseView.backgroundColor = UIColor.black.withAlphaComponent(alphaValue)
				}
			}).disposed(by: disposeBag)
		
		imageView.viewStateOutput
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] state in
				self?.viewStateOutput.onNext(state)
			}).disposed(by: disposeBag)
	}
	
	public func setImage(image : UIImage, width : CGFloat, height : CGFloat) {
		imageView = DraggableImageView(image: image)
		imageWidth = width
		imageHeight = height
	}
	
	public func setViewState(_ state : ViewState) {
		viewState = state
	}
	
	public func getViewState() -> ViewState {
		return self.viewState
	}
}



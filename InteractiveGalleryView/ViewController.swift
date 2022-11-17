//
//  ViewController.swift
//  WhiteStarGalleryView
//
//  Created by Logan Miller on 11/11/22.
//

import UIKit
import RxSwift
import TinyConstraints

class ViewController: UIViewController, UIScrollViewDelegate {
	
	let minimumZoom = 1.0
	let maximumZoom = 3.0
	
	var galleryView = GalleryView()
	var middleView = UIView()
	var baseView = UIView()
	
	fileprivate var disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViewController()
	}
	
	public func setupViewController() {
		let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
		doubleTap.numberOfTapsRequired = 2
		galleryView.baseView.addGestureRecognizer(doubleTap)
		
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
		singleTap.numberOfTapsRequired = 1
		singleTap.cancelsTouchesInView = true
		singleTap.require(toFail: doubleTap)
		self.baseView.addGestureRecognizer(singleTap)
		
		self.galleryView.minimumZoomScale = minimumZoom
		self.galleryView.maximumZoomScale = maximumZoom
		self.galleryView.zoomScale = minimumZoom
		self.galleryView.delegate = self
		
		self.view.addSubview(baseView)
		baseView.edgesToSuperview()
		
		let imageView = UIImageView(image: UIImage(named: "Society.jpeg"))
		baseView.addSubview(imageView)
		imageView.edgesToSuperview()
		
		baseView.addSubview(middleView)
		middleView.translatesAutoresizingMaskIntoConstraints = false
		middleView.backgroundColor = .black
		middleView.isHidden = true
		middleView.edgesToSuperview()
		
		galleryView.setImageView(image: UIImage(named: "Yoko.png")!, width: 1.0, height: 0.6)
		self.baseView.addSubview(galleryView)
		galleryView.edgesToSuperview()
		
		galleryView.viewStateOutput
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] state in
				
				var alphaValue = 1.0
				
				switch (state) {
				case .hidden:
					self?.galleryView.setViewState(ViewState.hidden)
					alphaValue = 0.0
				case .visible:
					self?.galleryView.setViewState(ViewState.visible)
				}
				
				UIView.animate(withDuration: self?.galleryView.shortAnimationDuration ?? Double.zero,
							   delay: 0,
							   options: .curveEaseInOut,
							   animations: {
					self?.galleryView.alpha = alphaValue
				})
			}).disposed(by: disposeBag)
	}
	
	//
	// MARK: Zoom delegate functions
	//
	
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return galleryView.imageView
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return galleryView.baseView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		galleryView.isZoomed = !galleryView.isZoomed
		updateBaseViewBackground()
		centerScrollViewContents()
	}
	
	func centerScrollViewContents() {
		let boundsSize = galleryView.bounds.size
		var contentFrame = galleryView.imageViewFrame
		
		if contentFrame.size.width < boundsSize.width {
			contentFrame.origin.x = (boundsSize.width - contentFrame.size.width) / 2.0
		} else {
			contentFrame.origin.x = 0.0
		}
		
		if contentFrame.size.height < boundsSize.height {
			contentFrame.origin.y = (boundsSize.height - contentFrame.size.height) / 2.0
		} else {
			contentFrame.origin.y = 0.0
		}
		galleryView.imageViewFrame = contentFrame
	}
	
	@objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
		let zoomScale = min(galleryView.zoomScale * 4, galleryView.maximumZoomScale)
		
		if zoomScale != galleryView.zoomScale {
			let touchPoint = sender.location(in: galleryView.baseView)
			
			let gallerySize = galleryView.frame.size
			let newSize = CGSize(width: gallerySize.width / zoomScale,
								 height: gallerySize.height / zoomScale)
			let origin = CGPoint(x: touchPoint.x - newSize.width / 2,
								 y: touchPoint.y - newSize.height / 2)
			galleryView.zoom(to:CGRect(origin: origin, size: newSize), animated: true)
		} else {
			galleryView.setZoomScale(minimumZoom, animated: true)
		}
	}
	
	//TODO: For demo purposes only, toggles between the galleryView being active
	@objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
		guard !galleryView.isPanning, !galleryView.isZoomed else { return }
		
		switch(galleryView.getViewState()) {
		case .hidden:
			galleryView.viewStateOutput.onNext(.visible)
		case .visible:
			galleryView.viewStateOutput.onNext(.hidden)
		}
	}
	
	fileprivate func updateBaseViewBackground() {
		galleryView.isZoomed == true ? (middleView.isHidden = false) : (middleView.isHidden = true)
	}
}


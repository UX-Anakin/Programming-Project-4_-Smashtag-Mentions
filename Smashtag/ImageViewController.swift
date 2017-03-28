//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 27/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

	
	@IBOutlet weak var scrollView: UIScrollView! {
		didSet {
			scrollView.delegate = self
		}
	}
	
	weak var image: UIImage? {
		didSet {
			imageView = UIImageView(image: image)
			imageView?.contentMode = .scaleAspectFit
		}
	}
	
	private var imageView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		scrollView.contentSize = imageView.bounds.size
		scrollView.addSubview(imageView)
		setPopToRootButton()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		zoomScaleToAspectFit()
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}

	private var autoZoom = true
	
	func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
		autoZoom = false
	}
	
	private func zoomScaleToAspectFit() {
		let zoomScaleForHeight = scrollView.bounds.height / imageView.bounds.height
		let zoomScaleForWidth = scrollView.bounds.width / imageView.bounds.width
		
		scrollView.minimumZoomScale = min(zoomScaleForHeight, zoomScaleForWidth)
		scrollView.maximumZoomScale = max(max(zoomScaleForHeight, zoomScaleForWidth), 5)
		if autoZoom {
			scrollView.setZoomScale(max(zoomScaleForHeight, zoomScaleForWidth), animated: true)
		}
		let contentOffSetX = (scrollView.contentSize.width - scrollView.bounds.width) / 2
		let contentOffSetY = (scrollView.contentSize.height - scrollView.bounds.height) / 2
		scrollView.contentOffset = CGPoint(x: contentOffSetX, y: contentOffSetY)
	}
	
	@IBAction func onTapping(_ sender: UITapGestureRecognizer)
	{	autoZoom = true
		zoomScaleToAspectFit()
	}

	
}

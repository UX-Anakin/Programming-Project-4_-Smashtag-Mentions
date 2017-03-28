//
//  extensions.swift
//  Smashtag
//
//  Created by Michel Deiman on 27/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//
import UIKit

extension UIViewController
{
	var contentViewController: UIViewController? {
		if let navcon = self as? UINavigationController {
			return navcon.visibleViewController
		} else {
			return self
		}
	}
	
	func setPopToRootButton(from level: Int = popToRootViewControllerStackDepth)
	{
		if let controllers = navigationController?.viewControllers, controllers.count > level {
			let toRootButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(toRootViewController))
			let rightBarButtons = [toRootButton] + (navigationItem.rightBarButtonItems ?? [])
			navigationItem.setRightBarButtonItems(rightBarButtons, animated: true)
		}
	}
	
	func toRootViewController() {
		_ = navigationController?.popToRootViewController(animated: true)
	}
	
	static let popToRootViewControllerStackDepth = 2
}

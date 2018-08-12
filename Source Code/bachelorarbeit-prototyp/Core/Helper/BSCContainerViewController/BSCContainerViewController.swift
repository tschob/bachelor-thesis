//
//  BSCContainerViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 07.12.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

class BSCContainerViewController: UIViewController {

	var defaultSegueIdentifier					: String?
	
	private var isPerformingTransition			= false
	
	private var embedViewControllers			= [String : UIViewController]()

	private var currentSegueIdentifier			: String?
	
	var currentViewController					: UIViewController? {
		get {
			if let _currentSegueIdentifier = self.currentSegueIdentifier {
				return self.embedViewControllers[_currentSegueIdentifier]
			} else {
				return nil
			}
		}
	}
	
	// MARK: View lifecycle

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		// Show the default view controller if the the container view is empty and a default view controller set.
		if (self.currentSegueIdentifier == nil),
			let _defaultSegueIdentifier = self.defaultSegueIdentifier {
			self.swapWithSegueIdentifier(_defaultSegueIdentifier)
		}
	}
	
	// MARK : Public methods
	
	func swapWithSegueIdentifier(segueIdentifier: String) {
		BSCLog(Verbose.BSCContainerViewController, segueIdentifier)
		
		guard self.isPerformingTransition == false && self.currentSegueIdentifier != segueIdentifier else {
			// Don't perform the swap if we are currently performing a transition or if the target view controller is already is shown.
			return
		}
		
		self.isPerformingTransition = true
		var didSwapViewController = false
		
		// Check if the view controller was presented before, we have saved in the embedViewController dictionary then.
		for (savedIdentifier, viewController) in self.embedViewControllers {
			if (savedIdentifier == segueIdentifier),
				let _currentViewController = self.currentViewController {
				self.swapToViewController(_currentViewController, toViewController: viewController)
				didSwapViewController = true
				self.currentSegueIdentifier = segueIdentifier
				break
			}
		}
		
		// If the target view controller was initiated once, we have to create it by performing the segue.
		if (didSwapViewController == false) {
			self.performSegueWithIdentifier(segueIdentifier, sender: nil)
		}
	}
	
	// MARK: Private helper

	private func swapToViewController(fromViewController: UIViewController, toViewController: UIViewController) {
		BSCLog(Verbose.BSCContainerViewController, "\(Verbose.BSCContainerViewController), \(fromViewController, toViewController)")
		// Set the toViewControllers layout
		toViewController.view.frame = self.view.bounds
		// Prepare the transition
		fromViewController.willMoveToParentViewController(nil)
		self.addChildViewController(toViewController)
		// Perform the transition
		self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.3, options: .TransitionCrossDissolve, animations: nil) { (finished: Bool) -> Void in
			fromViewController.removeFromParentViewController()
			toViewController.didMoveToParentViewController(self)
			self.isPerformingTransition = false
		}
	}
	
	// MARK: Segue
	
	/*
		The default segue behavior will be overriden by this method. Instead of performing the segue, the destination view controllers view will replace the current view.
	*/
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		BSCLog(Verbose.BSCContainerViewController, segue.identifier ?? "")
		if let _segueIdentifier = segue.identifier {
			self.embedViewControllers[_segueIdentifier] = segue.destinationViewController

			if let _currentViewController = self.currentViewController {
				// If there is no current view controller, we have to
				self.swapToViewController(_currentViewController, toViewController: segue.destinationViewController)
			} else {
				self.addChildViewController(segue.destinationViewController)
				// Replace the current with the target view controllers view
				let destinationView = segue.destinationViewController.view
				destinationView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
				destinationView.frame = self.view.bounds
				self.view.addSubview(destinationView)
				segue.destinationViewController.didMoveToParentViewController(self)
				self.isPerformingTransition = false
			}
			self.currentSegueIdentifier = _segueIdentifier
		} else {
			assertionFailure("Error: BSCContainerViewController: The segue has to contain an identifier!")
		}
	}
}

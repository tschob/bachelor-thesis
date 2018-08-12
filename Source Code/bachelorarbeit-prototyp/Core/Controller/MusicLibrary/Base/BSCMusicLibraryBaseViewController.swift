//
//  BSCMusicLibraryBaseViewController.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 23.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit
import MediaPlayer

class BSCMusicLibraryBaseViewController : BSCViewController {
	
	// MARK: - Public -

	// MARK: Variables
	
	var isFirstLevelController					= true

	var sectionsData							: [(title: String, sectionData: [MPMediaEntity])] = []
	var filteredData							: [MPMediaEntity] = []

	@IBOutlet weak var tableView				: UITableView!
	
	@IBOutlet weak var emptyLibraryView			: UIView?
	
	@IBOutlet var activityIndicator				: UIActivityIndicatorView?
	
	private var	resultSearchController			: UISearchController?
	var searchTerm								: String?
	
	private var didInitializeInsets				= false
	private var originalTopLayoutGuideLength	= CGFloat(0)
	
	var	colorScheme								: LEColorScheme?

	private var isSearchActive : Bool {
		get {
			if let _resultSearchController = self.resultSearchController {
				return _resultSearchController.active
			} else {
				return false
			}
		}
	}
	
	// MARK: View Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if (self.shouldEnableSeachController() == true) {
			self.initResultSearchController()
		}
		
		self.addTableViewCellNibs()
		self.initFooterView()
		self.initColorScheme()
		
		self.showEmptyLibraryView(false)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.applyColorScheme()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if (self.didInitializeInsets == false) {
			self.originalTopLayoutGuideLength = self.topLayoutGuide.length
			self.updateTableViewInsets(true)
			// Scroll the table view to the top
			self.tableView.scrollRectToVisible(CGRectMake(0, self.resultSearchController?.searchBar.frameHeight ?? 0, 1, 1), animated: false)
		} else {
			BSCHelper.fixTableViewInset(self, tableView: self.tableView)
		}
	}

	override func shouldAddDefaultNavigationBarBackground() -> Bool {
		return self.parentViewController?.isKindOfClass(BSCContainerViewController.self) == false
	}
	
	// MARK: Abstract Methods
	
	func titleForFooter() -> (singular: String, plural: String) {
		fatalError("This is an abstract method and should be overridden")
	}
	
	func shouldEnableSeachController() -> Bool {
		return false
	}
	
	func shouldShowFooter() -> Bool {
		return true
	}
	
	func shouldUseColorScheme() -> Bool {
		return false
	}
	
	func shouldUpdateTableViewInsets() -> Bool {
		return true
	}
	
	func filteredArrayForSearchTerm(searchTerm: String) -> [MPMediaEntity]? {
		// Implement this method if you use the search controller
		return nil
	}
	
	// MARK: Data fetching
	
	func loadDataInBackground(backgroundTask: (() -> [(title: String, sectionData: [MPMediaEntity])]?)) {
		self.showEmptyLibraryView(false)
		self.showDataLoadigView()
		self.performBlockInBackground { [weak self] () -> Void in
			if let
				_self = self,
				_sections = backgroundTask() {
					_self.sectionsData = _sections
					_self.performBlockInMainThread({ () -> Void in
						if (_sections.count > 0) {
							_self.showEmptyLibraryView(false)
						} else {
							_self.showEmptyLibraryView(true)
						}
						_self.hideDataLoadingView()
						_self.tableView.reloadData()
						_self.initFooterView()
					})
			} else {
				self?.performBlockInMainThread({ () -> Void in
					self?.showEmptyLibraryView(true)
					self?.initFooterView()
				})
			}
		}
	}
	
	// MARK: Helper
	
	func itemForIndexPath(indexPath: NSIndexPath) -> MPMediaItem? {
		if let _item = self.mediaEntityForIndexPath(indexPath) as? MPMediaItem {
			return _item
		} else {
			return nil
		}
	}
	
	func itemCollectionForIndexPath(indexPath: NSIndexPath) -> MPMediaItemCollection? {
		if let _itemCollection = self.mediaEntityForIndexPath(indexPath) as? MPMediaItemCollection {
			return _itemCollection
		} else {
			return nil
		}
	}
	
	func arrayWithAllItems() -> [MPMediaItem] {
		if let _items = self.arrayWithAllMediaEntities() as? [MPMediaItem] {
			return _items
		} else {
			return []
		}
	}
	
	// MARK: - Private -
	
	// MARK: Initialization
	
	private func updateTableViewInsets(useOriginalLayoutGuide: Bool) {
		// Adjust the table views content inset to avoid it to lay behind the transculent navigation bars during the opening of the view controller
		if (self.shouldUpdateTableViewInsets() == true) {
			if (self.parentViewController?.isKindOfClass(BSCContainerViewController.self) == true) {
				// Set the insets
				var topLayoutGuideLength = self.topLayoutGuide.length
				if (useOriginalLayoutGuide == true) {
					topLayoutGuideLength = self.originalTopLayoutGuideLength
				}
				let newInsets = UIEdgeInsetsMake(topLayoutGuideLength, 0, self.bottomLayoutGuide.length, 0)
				self.tableView.contentInset = newInsets
				self.tableView.scrollIndicatorInsets = newInsets
				self.didInitializeInsets = true
			} else {
				let bottomLayoutGuideLength = self.bottomLayoutGuide.length + (self.popupBar?.frameHeight ?? 0)
				let newInsets = UIEdgeInsetsMake(self.topLayoutGuide.length
					, 0, bottomLayoutGuideLength, 0)
				self.tableView.contentInset = newInsets
				self.tableView.scrollIndicatorInsets = newInsets
			}
		}
	}
	
	private func addTableViewCellNibs() {
		self.tableView.registerNib(UINib(nibName: "BSCMediaItemTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.MediaItemCell)
		self.tableView.registerNib(UINib(nibName: "BSCMediaItemCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.MediaCollectionCell)
	}
	
	private func initFooterView() {
		if (self.shouldShowFooter() == true) {
			if let view = BSCTableViewFooterView.loadFromNib(BSCTableViewFooterView.nibName()) {
				var totalItemsCount = 0
				if (self.isSearchActive == true) {
					totalItemsCount = self.filteredData.count
				} else {
					totalItemsCount = self.numberOfItems()
				}
				
				view.titleLabel.text = "\(totalItemsCount) \((totalItemsCount == 1 ? self.titleForFooter().singular: self.titleForFooter().plural))"
				self.tableView.tableFooterView = view
			}
		} else {
			// Show an empty view to prevent the table view from showing empty cells if there is not enough content to fill the screen
			self.tableView.tableFooterView = UIView(frame: CGRectZero)
		}
	}
	
	private func showDataLoadigView() {
		self.activityIndicator?.hidden = false
		self.tableView.hidden = true
	}
	
	private func hideDataLoadingView() {
		self.activityIndicator?.hidden = true
		self.tableView.hidden = false
	}
	
	private func initResultSearchController() {
		self.resultSearchController = UISearchController(searchResultsController: nil)
		self.resultSearchController?.searchResultsUpdater = self
		self.resultSearchController?.delegate = self
		self.resultSearchController?.searchBar.delegate = self
		self.resultSearchController?.searchBar.sizeToFit()
		self.resultSearchController?.dimsBackgroundDuringPresentation = false
		
		if let _resultSearchController = self.resultSearchController {
			self.tableView.tableHeaderView = _resultSearchController.searchBar
		}
	}
	
	private func initColorScheme() {
		let sectionsCount = self.numberOfSectionsInTableView(self.tableView)
		for section in (0..<sectionsCount).reverse() {
			if let _item = self.itemForIndexPath(NSIndexPath(forRow: 0, inSection: section)) {
				self.colorScheme = _item.colorScheme()
				break
			}
		}
	}
	
	// MARK: Helper

	private func showEmptyLibraryView(show: Bool) {
		self.emptyLibraryView?.hidden = (show == false)
		self.tableView.hidden = show
		if (show == true) {
			self.hideDataLoadingView()
		}
	}
	
	private func mediaEntityForIndexPath(indexPath: NSIndexPath) -> MPMediaEntity? {
		// Check if the indexPath is valid and return the corresponding MPMediaItem
		if (self.isSearchActive == true) {
			if (indexPath.row < self.filteredData.count) {
				return self.filteredData[indexPath.row]
			} else {
				return nil
			}
		} else {
			if (indexPath.section < self.sectionsData.count
				&& indexPath.row < self.sectionsData[indexPath.section].sectionData.count) {
					return self.sectionsData[indexPath.section].sectionData[indexPath.row]
			} else {
				return nil
			}
		}
	}
	
	private func arrayWithAllMediaEntities() -> [MPMediaEntity] {
		var mediaEntities = [MPMediaEntity]()
		for section in self.sectionsData {
			mediaEntities.appendContentsOf(section.sectionData)
		}
		return mediaEntities
	}
	
	private func numberOfItems() -> Int {
		var totalItemsCount = 0
		for _section in self.sectionsData {
			totalItemsCount += _section.sectionData.count
		}
		return totalItemsCount
	}
	
	private func showSearchbar(animated: Bool) {
		self.tableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: animated)
	}
	
	private func applyColorScheme() {
		if (self.shouldUseColorScheme() == true) {
			if let _colorScheme = self.colorScheme {
				self.tableView.backgroundColor = _colorScheme.backgroundColor
				self.tableView.separatorColor = _colorScheme.primaryTextColor
				self.addNavigationBarWithColorScheme(self.colorScheme)
			}
		} else {
			// Reset the navigation bar theme
			self.navigationController?.navigationBar.tintColor = self.view.tintColor
			self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
		}
	}
}

// MARK: UITableView Delegate

extension BSCMusicLibraryBaseViewController : UITableViewDataSource, UITableViewDelegate {
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		fatalError("This is an abstract method and should be overridden")
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if (self.isSearchActive == false &&	self.sectionsData.count > 1) {
			return self.sectionsData[section].title			
		} else {
			return nil
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (self.isSearchActive == true) {
			return self.filteredData.count
		} else {
			return self.sectionsData[section].sectionData.count ?? 0
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if (self.isSearchActive == true) {
			return 1
		} else {
			return self.sectionsData.count
		}
	}
	
	func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
		if (self.isSearchActive == false && self.sectionsData.count > 1) {
			var sectionTitles = [String]()
			if (self.shouldEnableSeachController() == true) {
				sectionTitles.append(UITableViewIndexSearch)
			}
			for (_, section) in self.sectionsData.enumerate() {
				sectionTitles.append(section.title)
			}
			return sectionTitles
		} else {
			return nil
		}
	}
	
	func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
		if (self.shouldEnableSeachController() == true) {
			if (index == 0) {
				// Show the search bar as first index.
				self.showSearchbar(false)
				return -1
			} else {
				// We have to add 1 to the index as our first data item is the second in the index titles as the search bar takes the first index.
				return index - 1
			}
		}
		return index
	}
}

// MARK: UISearchResultsUpdating Delegate

extension BSCMusicLibraryBaseViewController : UISearchResultsUpdating, UISearchControllerDelegate {
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		self.filteredData.removeAll()
		if let _filteredData = self.filteredArrayForSearchTerm(searchController.searchBar.text ?? "") {
			self.filteredData = _filteredData
		} else {
			self.filteredData = []
		}
		self.initFooterView()
		self.tableView.reloadData()
	}
	
	func didPresentSearchController(searchController: UISearchController) {
		self.updateTableViewInsets(false)
	}
	
	func willDismissSearchController(searchController: UISearchController) {
		self.updateTableViewInsets(true)
	}

	func didDismissSearchController(searchController: UISearchController) {
		// Scroll to the first cell, this hides the search bar.
		if (self.numberOfItems() > 0) {
			self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
		}
	}
}

// MARK: UIScrollView Delegate

extension BSCMusicLibraryBaseViewController : UIScrollViewDelegate {
	
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		if (self.isSearchActive == true) {
			// Hide the keyboard if the user scrolls through the search results
			self.resultSearchController?.searchBar.resignFirstResponder()
		}
	}
}

// MARK: UISearchBar Delegate

extension BSCMusicLibraryBaseViewController : UISearchBarDelegate {
	
	func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		// Calculate the new search term and save it in the search term variable
		let oldSearchTerm = (searchBar.text ?? "") as NSString
		self.searchTerm = oldSearchTerm.stringByReplacingCharactersInRange(range, withString: text)
		return true
	}
}

//
//  RecentsTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 08/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class RecentsTableViewController: UITableViewController {
	
	private struct Constants {
		static let MaxSearchKeys = 100
		static let KeyForRecentSearches = "RecentSearchKeys"
		static let cellReuseIdentifier = "Recents"
		static let SegueToMainTweetTableView = "ToMainTweetTableView"
		static let SegueToPopularMentions = "toPopularMentions"
	}
	
	var recentSearchKeys = RecentSearchKeys(keyForData: Constants.KeyForRecentSearches, maxNoOfSearchKeys: Constants.MaxSearchKeys)
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		self.navigationItem.rightBarButtonItem = self.editButtonItem
		setPopToRootButton()
    }
	
	override func viewWillAppear(_ animated: Bool)
	{	super.viewWillAppear(true)
		tableView.reloadData()
	}

//    // MARK: - Table view data source
	override func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return recentSearchKeys.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath)
		cell.textLabel?.text = recentSearchKeys[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
	{
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
	{
		if editingStyle == .delete {
			recentSearchKeys.removeAtIndex(index: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		recentSearchKeys.moveToTop(key: recentSearchKeys[indexPath.row])
		performSegue(withIdentifier: Constants.SegueToMainTweetTableView, sender: self)

	}
	
	override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
	{
		performSegue(withIdentifier: Constants.SegueToPopularMentions, sender: indexPath)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Constants.SegueToPopularMentions {
			if let tweetersTVC = segue.destination as? SmashTweetersTableViewController, let indexPath = sender as? IndexPath
			{
				tweetersTVC.mention = recentSearchKeys[indexPath.row]
			}
		}
	}
	
}

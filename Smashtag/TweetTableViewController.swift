//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 16/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UISearchBarDelegate {

	private struct Constants {
		static let KeyForRecentSearches = "RecentSearchKeys"
		static let SegueIdentifierToMentions = "ToMentions"
		static let SegueIdentifierToCollectionView = "toCollectionViewOfImages"
		static let TweetCellIdentifier = "Tweet"
	}
	
	
    // MARK: - Model
    private var tweets: [[Twitter.Tweet]] = [[]] 
    
    var searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder() // keyboard out of the way.
            lastTwitterRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
        }
    }

	private var recentSearchKeys = RecentSearchKeys(keyForData: Constants.KeyForRecentSearches)
	
    internal func insertTweets(_ newTweets: [Twitter.Tweet])    // implicitly all functions are internal,
    {                                                           // in contrast to 'private'  and 'fileprivate'
        self.tweets.insert(newTweets, at: 0)
        self.tableView.insertSections([0], with: .fade)
    }
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: "\(query) -filter:safe -filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] (newTweets) in
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest {
                        self?.insertTweets(newTweets)
                    }
                    self?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl)
    {   searchForTweets()
    }
    
    // for testing...
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        searchText = recentSearchKeys.last
    }
	
	// MARK: Replaced searchTextField with UISearchBar
    @IBOutlet weak var searchTextField: UISearchBar! {
        didSet {
            searchTextField.delegate = self
			let cancelButton = searchTextField.value(forKey: "cancelButton") as! UIButton
			cancelButton.setTitle("Search", for: .normal)
        }
    }
	
	// MARK: Delegate method from UISearchBarDelegate
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchText = searchBar.text
		recentSearchKeys.addSearchKey(searchText!)
	}
	
	// MARK: UISearchBarDelegate method !!!!!!!
	// Not "Cancel, but 'Search' function !!!!!
	// twitter keyboard has no 'direct' enter/Search key
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBarSearchButtonClicked(searchBar)
	}
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TweetCellIdentifier, for: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count-section)"
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		let segueToVC = segue.destination.contentViewController
		if let identifier = segue.identifier {
			switch identifier {
			case Constants.SegueIdentifierToMentions:
				(segueToVC as? TweetMentionsTableViewController)?.tweet = (sender as? TweetTableViewCell)?.tweet
			case Constants.SegueIdentifierToCollectionView:
				if let vc = segueToVC as? ImagesCollectionViewController {
					vc.tweets = tweets
				}
			default: break
			}
		}
	}
	

}

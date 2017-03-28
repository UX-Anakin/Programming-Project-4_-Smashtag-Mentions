//
//  ImagesCollectionViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 27/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter

// Subscripting makes working with NSCache more convenient
class Cache: NSCache<NSURL, UIImage> {
	subscript(key: URL) -> UIImage? {
		get {
			return object(forKey: key as NSURL)
		}
		set {
			if let value: UIImage = newValue {
				setObject(value, forKey: key as NSURL)
			} else {
				removeObject(forKey: key as NSURL)
			}
		}
	}
}

class ImagesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
	private struct Constants {
		static let ReuseIdentifier = "imageCollectionViewCell"
		static let SegueToMainTweetTableView = "ToMainTweetTableView"
		
		static let MaxColumnCount: CGFloat = 4
		static let MaxRowCount: CGFloat = 6
		
		static let minimumColumnSpacing:CGFloat = 2
		static let minimumInteritemSpacing:CGFloat = 0
		static let minimumLineSpacing: CGFloat = 2
		static let sectionInset = UIEdgeInsets.zero
	}
	
	var tweets: [[Twitter.Tweet]]? {
		didSet {
			for allTweets in tweets! {
				for tweet in allTweets {
					for media in tweet.media {
						tweetsWithMedia.append(TweetWithMedia(tweet: tweet, mediaItem: media))
					}
				}
			}
		}
	}
	
	private struct TweetWithMedia {
		let tweet: Twitter.Tweet
		let mediaItem: MediaItem
	}
	
	private var tweetsWithMedia: [TweetWithMedia] = []
	private var cache = Cache()
	
	deinit {
		cache.removeAllObjects()
	}
	
	override func viewDidLoad() {
		collectionView?.collectionViewLayout = collectionViewFlowLayout
		setPopToRootButton()
	}
	
	// MARK: Datasource methods
	override func numberOfSections(in collectionView: UICollectionView) -> Int
	{	return 1
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{	return tweetsWithMedia.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{	let dequed = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.ReuseIdentifier,
	 	                                                for: indexPath)
		let cell = dequed as! TweetMediaCollectionViewCell
		cell.tweet = tweetsWithMedia[indexPath.row].tweet
		cell.mediaItem = tweetsWithMedia[indexPath.row].mediaItem
		cell.cache = cache
		return cell
	}
	
	// MARK: UICollectionViewDelegateFlowLayout
	// an altertenative would be delegate methods for these properties...
	private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.minimumLineSpacing = Constants.minimumLineSpacing
		flowLayout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
		flowLayout.sectionInset = Constants.sectionInset
		return flowLayout
	}()
	
	private var columnCount: CGFloat = 2 {
		didSet {
			columnCount = min(max(columnCount, 1), Constants.MaxColumnCount)
			collectionView?.isPagingEnabled = columnCount == 1 && rowCount == 1
		}
	}
	
	private var rowCount: CGFloat = 3 {
		didSet {
			rowCount = min(max(rowCount, 1), Constants.MaxRowCount)
			collectionView?.isPagingEnabled = columnCount == 1 && rowCount == 1
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize
	{
		let width = (collectionView.bounds.width - (columnCount - 1) * 2) / columnCount
		let height = (collectionView.bounds.height - (rowCount - 1) * 2) / rowCount
		return CGSize(width: width, height: height)
	}
	
	func collectionView(_ collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                    insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets.zero
	}

	// MARK: Segue to TweetMentionsTableViewController
	private let SegueIdentifierToMentions = "ToTweetMentionsTableView"
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if let identifier = segue.identifier, identifier == SegueIdentifierToMentions, let segueToVC = segue.destination.contentViewController as? TweetMentionsTableViewController
		{
			let cell = sender as! TweetMediaCollectionViewCell
			segueToVC.tweet = cell.tweet
		}
	}
	
}



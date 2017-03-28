//
//  TweetMentionsTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 27/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter


protocol BridgeMentionAndUser {
	var keywordOrScreenName: String { get }
}

extension Mention: BridgeMentionAndUser {
	var keywordOrScreenName: String {
		return keyword
	}
}

extension User: BridgeMentionAndUser {
	var keywordOrScreenName: String {
		return "@" + screenName
	}
}

class TweetMentionsTableViewController: UITableViewController {
	
	private struct Constants {
		static let KeyForRecentSearches = "RecentSearchKeys"
		static let cellReuseIdentifierForImages = "TweetMediaCell"
		static let cellReuseIdentifierStandard = "TweetMentionsTableViewCell"
		static let SegueToMainTweetTableView = "ToMainTweetTableView"
		static let SegueToImageView = "ToImageView"
	}
	
	var tweet: Twitter.Tweet? {
		didSet {
			tweetMentions = []
			guard let tweet = tweet else { return }
			if !tweet.media.isEmpty		{ tweetMentions.append(.media(tweet.media)) }
			if !tweet.hashtags.isEmpty	{ tweetMentions.append(.hashtags(tweet.hashtags)) }
			if !tweet.urls.isEmpty		{ tweetMentions.append(.urls(tweet.urls)) }
			
			var mentionsAndUser: [BridgeMentionAndUser] = tweet.userMentions
			mentionsAndUser = [tweet.user] + mentionsAndUser
			tweetMentions.append(.userMentions(mentionsAndUser))
		}
	}
	
	private enum TweetMention: CustomStringConvertible {
		case media([MediaItem])
		case hashtags([BridgeMentionAndUser])
		case urls([BridgeMentionAndUser])
		case userMentions([BridgeMentionAndUser])
		
		var count: Int {
			switch self {
			case .media(let items): return items.count
			case .hashtags(let items): return items.count
			case .urls(let items): return items.count
			case .userMentions(let items): return items.count
			}
		}
		
		var mentions: [BridgeMentionAndUser] {
			switch self {
			case .hashtags(let items): return items
			case .urls(let items): return items
			case .userMentions(let items): return items
			default: return []
			}
		}
		
		var description: String {
			switch self {
			case .media: return "Media"
			case .hashtags: return "Hashtags"
			case .urls: return "URLs"
			case .userMentions: return "User + UserMentions"
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setPopToRootButton()
	}
	
	private var tweetMentions: [TweetMention] = []

    // MARK: - Table view data source methods
    override func numberOfSections(in tableView: UITableView) -> Int
	{	return tweetMentions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{	return tweetMentions[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{	let tweetMention = tweetMentions[indexPath.section]
		switch tweetMention {
		case .media(let items):
			let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifierForImages, for: indexPath)
			if let cell = dequeuedCell as? TweetMediaTableViewCell {
				cell.mediaItem = items[indexPath.row]
			}
			return dequeuedCell
		default:
			let mention = tweetMention.mentions[indexPath.row]
			let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifierStandard, for: indexPath)
			cell.textLabel?.text = mention.keywordOrScreenName
			return cell
		}
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{	return tweetMentions[section].description
	}
	
	// MARK: - Table view delegate methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{	let tweetMention = tweetMentions[indexPath.section]
		let recentSearchKeys = RecentSearchKeys(keyForData: Constants.KeyForRecentSearches)
		switch tweetMention {
		case .hashtags, .userMentions:
			var keyword = tweetMention.mentions[indexPath.row].keywordOrScreenName
			if case .userMentions = tweetMention {
				keyword = keyword + " OR from:" + keyword
			}
			recentSearchKeys.addSearchKey(keyword)
			performSegue(withIdentifier: Constants.SegueToMainTweetTableView, sender: self)
		case .urls(let mentions):
			let urlString = mentions[indexPath.row].keywordOrScreenName
			if let url = URL(string: urlString) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		default: break
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{	let tweetMention = tweetMentions[indexPath.section]
		switch tweetMention {
		case .media(let mediaItems):
			let mediaItem = mediaItems[indexPath.row]
			return tableView.bounds.size.width / CGFloat(mediaItem.aspectRatio)
		default:
			return UITableViewAutomaticDimension
		}
	}
	
	
	
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{	guard let identifier = segue.identifier else { return }
		switch identifier {
		case Constants.SegueToImageView:
			if let segueVC = segue.destination.contentViewController as? ImageViewController,
				let content = (sender as? TweetMediaTableViewCell)?.imageContent
			{	segueVC.image = content
			}
		case Constants.SegueToMainTweetTableView:
			break
		default: break
		}
	}

}

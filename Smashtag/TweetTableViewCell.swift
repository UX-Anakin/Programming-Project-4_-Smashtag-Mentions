//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Michel Deiman on 16/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    private func updateUI() {
        tweetTextLabel?.text = tweet?.text
		tweetTextLabel?.attributedText = attributedTextFor(tweet: tweet!, mentionTypes: [.hashTag, .url, .user])
        tweetUserLabel?.text = tweet?.user.description
        if let profileImageURL = tweet?.user.profileImageURL {
            // MARK: Fetch data off the main queue
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let imageData = try? Data(contentsOf: profileImageURL) {
                    // MARK: UI -> Back to main queue
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
        
    }
	
	private func attributedTextFor(tweet: Twitter.Tweet, mentionTypes: [MentionType]) -> NSAttributedString {
		var tweetText = tweet.text
		for _ in tweet.media {
			tweetText += " 📷"
		}
		let attributedText = NSMutableAttributedString(string: tweetText)
		
		
		for mentionType in mentionTypes {
			var color: UIColor
			var mentions: [Mention]
			switch mentionType {
			case .hashTag:
				color = Palette.hashtagColor
				mentions = tweet.hashtags
			case .url:
				color = Palette.urlColor
				mentions = tweet.urls
			case .user:
				color = Palette.userColor
				mentions = tweet.userMentions
			}
			for mention in mentions {
				attributedText.addAttribute(NSForegroundColorAttributeName, value: color, range: mention.nsrange)
			}
		}
		return attributedText
	}
}

private struct Palette {
	static let hashtagColor = UIColor.purple
	static let urlColor = UIColor.blue
	static let userColor = UIColor.orange
}

private enum MentionType {
	case hashTag, url, user
}

    


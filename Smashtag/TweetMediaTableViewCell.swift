//
//  TweetMediaTableViewCell.swift
//  Smashtag
//
//  Created by Michel Deiman on 27/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter

class TweetMediaTableViewCell: UITableViewCell {

	@IBOutlet private weak var tweetImageView: UIImageView!
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
	
	var imageContent: UIImage? {
		set { tweetImageView.image = newValue }
		get { return tweetImageView.image }
	}
	
	var mediaItem: MediaItem? {
		didSet {
			guard let url = mediaItem?.url else { return }
			spinner?.startAnimating()
			
			DispatchQueue.global(qos: .userInitiated).async { [weak self] in
				if let imageData = try? Data(contentsOf: url) {
					DispatchQueue.main.async {
						self?.tweetImageView?.image = UIImage(data: imageData)
						self?.spinner.stopAnimating()
					}
				}
			}
		}
	}

	override func setSelected(_ selected: Bool, animated: Bool)
	{	super.setSelected(selected, animated: animated)
	}
}

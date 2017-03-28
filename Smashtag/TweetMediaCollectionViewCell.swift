//
//  TweetMediaCollectionViewCell.swift
//  Smashtag
//
//  Created by Michel Deiman on 28/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter

class TweetMediaCollectionViewCell: UICollectionViewCell
{
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
	
	var tweet: Twitter.Tweet?
	var mediaItem: MediaItem? {
		didSet {
			guard let url = mediaItem?.url else { return }
			spinner?.startAnimating()
			if let image = cache?[url] {	// cached?
				spinner?.stopAnimating()
				imageView.image = image
				return
			}
			
			DispatchQueue.global(qos: .userInitiated).async { [weak self] in
				if let imageData = try? Data(contentsOf: url) {
					DispatchQueue.main.async {
						self?.imageView.image = UIImage(data: imageData)
						self?.cache?[url] = self?.imageView.image
						self?.spinner.stopAnimating()
					}
				}
			}
		}
	}

	var cache: Cache?
}

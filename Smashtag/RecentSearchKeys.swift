//
//  RecentSearchKeys.swift
//  Smashtag
//
//  Created by Michel Deiman on 27/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import Foundation

private struct Constants {
	static let MaxSearchKeys = 100
}

class RecentSearchKeys {
	subscript(index: Int) -> String {
		get { return searchKeys[index] }
	}
	
	static var defaultSearchKey: String = "#stanford"
	
	var last: String {
		if isEmpty { addSearchKey(RecentSearchKeys.defaultSearchKey) }
		return self[0]
	}
	
	var count: Int {
		return searchKeys.count
	}
	
	var isEmpty: Bool {
		return self.count == 0
	}
	
	func addSearchKey(_ key: String) {
		for index in 0..<searchKeys.count
		{	if key.lowercased() == searchKeys[index].lowercased() {
			searchKeys.remove(at: index)
			break
			}
		}
		searchKeys.insert(key, at: 0)
		if searchKeys.count >= maxNoOfSearchKeys {
			searchKeys.removeLast()
		}
	}
	
	func moveToTop(key: String) {
		addSearchKey(key)
	}
	
	func removeAtIndex(index: Int) {
		if count > index {
			searchKeys.remove(at: index)
		}
	}
	
	func remove(key: String) {
		for index in 0..<searchKeys.count
		{	if key.lowercased() == searchKeys[index].lowercased() {
			searchKeys.remove(at: index)
			return
			}
		}
	}
	
	private let defaults = UserDefaults.standard
	private let keyForData: String
	private let maxNoOfSearchKeys: Int
	
	private var searchKeys: [String] {
		get {	return defaults.object(forKey: keyForData) as? [String] ?? []	}
		set {	defaults.set(newValue, forKey: keyForData)	}
	}
	
	init(keyForData: String, maxNoOfSearchKeys: Int = Constants.MaxSearchKeys) {
		self.keyForData = keyForData
		self.maxNoOfSearchKeys = maxNoOfSearchKeys
	}
}

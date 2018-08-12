//
//  BSCRecommendationsCollectionViewDataSource.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 28.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation

class BSCRecommendationsCollectionViewDataSource: NSObject {
	
	var recommendation			: BSCRecommendation?
	
	private func songInfo(indexPath: NSIndexPath) -> BSCSongInfo? {
		if (indexPath.row < self.recommendation?.allPlaylogSongs.count) {
			return self.recommendation?.allPlaylogSongs[indexPath.row].songInfo
		}
		return nil
	}
}

// MARK: - UICollectionViewDelegate

extension BSCRecommendationsCollectionViewDataSource: UICollectionViewDataSource, UICollectionViewDelegate {
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.CellIdentifier.RecommendationCollectionViewCell, forIndexPath: indexPath)
		
		if let
			_cell = cell as? BSCRecommendationCollectionViewCell,
			_persistentID = self.songInfo(indexPath)?.persistentID,
			_songItem = BSCMusicLibraryManager.songWithPersitentID(_persistentID),
			_recommendation = self.recommendation {
				_cell.setMediaItem(_songItem)
				_cell.playButtonPressed = {
					if let _position = _recommendation.mediaItemPosition(_songItem) {
						BSCMusicPlayer.sharedInstance.play(mediaItems: _recommendation.allMediaItems, startPosition: _position)
					}
				}
		} else if let
			_sessions = self.recommendation?.allSessionContexts,
			_cell = cell as? BSCRecommendationCollectionViewCell {
				if (self.recommendation?.allPlaylogSongs.count == 0) {
					_cell.setSessionContext(_sessions[indexPath.row])
				}
		}
		cell.backgroundColor = UIColor.greenColor()
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if (self.recommendation?.allPlaylogSongs.count == 0) {
			return self.recommendation?.allSessionContexts.count ?? 0
		}
		return self.recommendation?.allPlaylogSongs.count ?? 0
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		if (self.recommendation?.allPlaylogSongs.count == 0) {
			return CGSizeMake(120.0, 80.0)
		}
		return CGSizeMake(60.0, 80.0)
	}
}

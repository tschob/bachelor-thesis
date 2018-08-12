//
//  BSCConstants.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 21.11.15.
//  Copyright © 2015 Hans Seiffert. All rights reserved.
//

import UIKit

struct Verbose {
	static let Error								= true
	static let BSCContainerViewController			= false
	static let BSCMusicPLayer						= false
	static let BSCPLaylogManager					= false
	static let BSCContextManager					= false
	static let BSCLocationManager					= false
	static let BSCMotionActivityManager				= false
	static let BSCWeatherManager					= false
	static let BSCContextComparisonHelper			= false

	struct Database {
		static let Manager							= true
		static let PlaylogSession					= false
		static let PlaylogSong						= false
		static let SongInfo							= false
	}
}

struct Constants {
	
	struct InfoPlistKeys {
		static let HockeyAppID						= "HockeyAppId"
	}
	
	struct CellIdentifier {
		static let MediaCollectionCell				= "mediaCollectionCell"
		static let MediaItemCell					= "mediaItemCell"
		static let ArtistAlbumHeaderView			= "artistAlbumHeaderView"
		static let PlaylogSessionsDebugCell			= "playlogSessionsDebugCell"
		static let PlaylogSongsDebugCell			= "playlogSongsDebugCell"
		static let CurrentContextDebugCell			= "currentContextDebugCell"
		static let MapTableViewCell					= "mapTableViewCell"
		static let ContextsDebugCell				= "singleContextsDebugCell"
		static let ContextComparisonCell			= "contextComparisonCell"
		static let SimilarContextsCell				= "similarContextsCell"
		static let RecommendationsCell				= "recommendationsCell"
		static let RecommendationCollectionViewCell	= "recommendationCollectionViewCell"
		static let RecommendationHeaderCell			= "recommendationHeaderCell"
	}
	
	struct CellHeights {
		static let MusicLibraryAlbumSong			= CGFloat(40)
		static let MusicLibrarySong					= CGFloat(50)
		static let MusicLibraryCollection			= CGFloat(70)
	}
	
	struct Segue {
		static let PushAlbum						= "pushAlbum"
		static let PushArtist						= "pushArtist"
		static let PushPlaylist						= "pushPlaylist"
		static let PushGenre						= "pushGenre"
		static let EmbedContainerView				= "embedContainerView"
		static let EmbedArtists						= "embedArtists"
		static let EmbedAlbums						= "embedAlbums"
		static let EmbedSongs						= "embedSongs"
		static let EmbedGenres						= "embedGenres"
		static let EmbedPlaylists					= "embedPlaylists"
		static let PushPlaylogSongsDebug			= "pushPlaylogSongsDebug"
		static let PushContext						= "showContext"
		static let PushSessionContext				= "showSessionContext"
		static let ModalContextPicker				= "modalContextPicker"
		static let ShowContextComparison			= "showContextComparison"
		static let ShowContextComparisonsList		= "showContextComparisonsList"
		static let PushRecommendation				= "pushRecommendation"
		static let ModalChooseContext				= "modalChooseContext"
	}
	
	struct UserDefaultsKeys {
		static let ActiveMusicLibraryType			= "activeMusicLibraryType"
		static let MinRecommendationsSimilarity		= "minRecommendationsSimilarity"
	}
	
	static let normalStatusBarHeight				= CGFloat(20)
}

enum MusicLibraryType: String {
	
	case Artist										= "artist"
	case Album										= "album"
	case Song										= "song"
	case Genre										= "genre"
	case Playlist									= "playlist"
	
	var singularTitle: String {
		switch self {
		case Artist:								return L("word.artist")
		case Album:									return L("word.album")
		case Song:									return L("word.song")
		case Genre:									return L("word.genre")
		case Playlist:								return L("word.playlist")
		}
	}
	
	var pluralTitle: String {
		switch self {
		case Artist:								return L("word.artists")
		case Album:									return L("word.albums")
		case Song:									return L("word.songs")
		case Genre:									return L("word.genres")
		case Playlist:								return L("word.playlists")
		}
	}
	
	var embedSegueIdentfier: String {
		switch self {
		case .Artist:								return Constants.Segue.EmbedArtists
		case .Album:								return Constants.Segue.EmbedAlbums
		case .Song:									return Constants.Segue.EmbedSongs
		case .Genre:								return Constants.Segue.EmbedGenres
		case .Playlist:								return Constants.Segue.EmbedPlaylists
		}
	}
}

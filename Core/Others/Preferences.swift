//
//  Preferences.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/19/26.
//

import SwiftUI
import Observation

/// A singleton that manages persisted user selections.
/// External Dependencies: PreferencesKey
@Observable final class Preferences {
	
	/// An Interface that lists all `persisted selections` with UserDefault.
	private enum Key: String {
		
		// Color
		case globalColor
		
		// Tab
		case tabBar
		
		// Session
		case sessionOrder
		
		// Languages
		case recentLanguages
		
		// In New Card
		case frontLanguage
		case backLanguage
		case exactMatch
		case selectDeck
		
		// In Trial
		case trialTimeInterval
		case trialDeck
		case trialNumberOfCards
		case trialOrder
		case trialMode
		case trialRefreshTimer
		case trialSwipeThreshold
		case trialSide
		
		// In Settings
		case lastCleanup
		case audioQuality
		case profileImage
		case profileName
		case profileUUID
		
		// Decks
		case visibleDecks
		case sortDecks
		
		// Cards
		case invertCards
		case visibleCards
		case sortCards
		case languageFilterCards
		
		// In Deck
		case gradientBackground
		case animationBackground
	}
	
	static let unique: Preferences = Preferences()
	
	private let userDefaults: UserDefaults = UserDefaults.standard
	private var globalColorRaw: String = ""
	private var tabBarRaw: String = ""
	private var sessionOrderRaw: [String] = []
	private var recentLanguagesRaw: [String] = []
	private var frontLanguageRaw: String = ""
	private var backLanguageRaw: String = ""
	private var exactMatchRaw: String = ""
	private var selectDeckRaw: String = ""
	private var trialTimeIntervalRaw: TimeInterval = 0
	private var trialDeckRaw: String = ""
	private var trialNumberOfCardsRaw: Int = 0
	private var trialOrderRaw: Int = 0
	private var trialModeRaw: Int = 0
	private var trialRefreshTimerRaw: Double = 0
	private var trialSwipeThresholdRaw: Double = 0
	private var trialSideRaw: Int = 0
	private var lastCleanupRaw: Double = 0
	private var audioQualityRaw: String = ""
	private var profileImageRaw: String = ""
	private var profileNameRaw: String = ""
	private var profileUUIDRaw: String = ""
	private var visibleDecksRaw: Bool = false
	private var sortDecksRaw: [String] = []
	private var invertCardsRaw: Bool = false
	private var visibleCardsRaw: Bool = false
	private var sortCardsRaw: [String] = []
	private var languageFilterCardsRaw: Int = 0
	private var gradientBackgroundRaw: Bool = false
	private var animationBackgroundRaw: Bool = false
	
	private init() {
		
		let defaultLanguage: String = Language.en_US.rawValue
		
		userDefaults.register(defaults: [
			Key.trialTimeInterval.rawValue: 5.0,
			Key.trialRefreshTimer.rawValue: (2.0 / 60.0),
			Key.trialSwipeThreshold.rawValue: 50.0,
			Key.gradientBackground.rawValue: true,
			Key.animationBackground.rawValue: false
		])
		
		globalColorRaw = userDefaults.string(forKey: Key.globalColor.rawValue) ?? AccentColor.firGreen.rawValue
		tabBarRaw = userDefaults.string(forKey: Key.tabBar.rawValue) ?? TabBar.new.rawValue
		sessionOrderRaw = userDefaults.stringArray(forKey: Key.sessionOrder.rawValue) ?? SessionKind.allCases.map(\.rawValue)
		recentLanguagesRaw = userDefaults.stringArray(forKey: Key.recentLanguages.rawValue) ?? []
		frontLanguageRaw = userDefaults.string(forKey: Key.frontLanguage.rawValue) ?? defaultLanguage
		backLanguageRaw = userDefaults.string(forKey: Key.backLanguage.rawValue) ?? defaultLanguage
		exactMatchRaw = userDefaults.string(forKey: Key.exactMatch.rawValue) ?? defaultLanguage
		selectDeckRaw = userDefaults.string(forKey: Key.selectDeck.rawValue) ?? ""
		trialTimeIntervalRaw = userDefaults.double(forKey: Key.trialTimeInterval.rawValue)
		trialDeckRaw = userDefaults.string(forKey: Key.trialDeck.rawValue) ?? ""
		trialNumberOfCardsRaw = userDefaults.integer(forKey: Key.trialNumberOfCards.rawValue)
		trialOrderRaw = userDefaults.integer(forKey: Key.trialOrder.rawValue)
		trialModeRaw = userDefaults.integer(forKey: Key.trialMode.rawValue)
		trialRefreshTimerRaw = userDefaults.double(forKey: Key.trialRefreshTimer.rawValue)
		trialSwipeThresholdRaw = userDefaults.double(forKey: Key.trialSwipeThreshold.rawValue)
		trialSideRaw = userDefaults.integer(forKey: Key.trialSide.rawValue)
		lastCleanupRaw = userDefaults.double(forKey: Key.lastCleanup.rawValue)
		audioQualityRaw = userDefaults.string(forKey: Key.audioQuality.rawValue) ?? AudioQuality.high.rawValue
		profileImageRaw = userDefaults.string(forKey: Key.profileImage.rawValue) ?? Constants.defaultProfileImage
		profileNameRaw = userDefaults.string(forKey: Key.profileName.rawValue) ?? Constants.noAuthor
		profileUUIDRaw = (UUID(uuidString: userDefaults.string(forKey: Key.profileUUID.rawValue) ?? "") ?? UUID()).uuidString
		userDefaults.set(profileUUIDRaw, forKey: Key.profileUUID.rawValue)
		visibleDecksRaw = userDefaults.bool(forKey: Key.visibleDecks.rawValue)
		sortDecksRaw = userDefaults.stringArray(forKey: Key.sortDecks.rawValue) ?? [SortDeck.newestToOldest.rawValue]
		invertCardsRaw = userDefaults.bool(forKey: Key.invertCards.rawValue)
		visibleCardsRaw = userDefaults.bool(forKey: Key.visibleCards.rawValue)
		sortCardsRaw = userDefaults.stringArray(forKey: Key.sortCards.rawValue) ?? [SortCard.newestToOldest.rawValue]
		languageFilterCardsRaw = userDefaults.integer(forKey: Key.languageFilterCards.rawValue)
		gradientBackgroundRaw = userDefaults.bool(forKey: Key.gradientBackground.rawValue)
		animationBackgroundRaw = userDefaults.bool(forKey: Key.animationBackground.rawValue)
	}
	
	var globalColor: AccentColor {
		get { AccentColor(rawValue: globalColorRaw) ?? .firGreen }
		set {
			globalColorRaw = newValue.rawValue
			userDefaults.set(globalColorRaw, forKey: Key.globalColor.rawValue)
		}
	}
	
	var tabBar: TabBar {
		get { TabBar(rawValue: tabBarRaw) ?? .new }
		set {
			tabBarRaw = newValue.rawValue
			userDefaults.set(tabBarRaw, forKey: Key.tabBar.rawValue)
		}
	}
	
	var sessionOrder: [SessionKind] {
		get { sessionOrderRaw.compactMap(SessionKind.init(rawValue:)) }
		set {
			sessionOrderRaw = newValue.map(\.rawValue)
			userDefaults.set(sessionOrderRaw, forKey: Key.sessionOrder.rawValue)
		}
	}
	
	var recentLanguages: [Language] {
		get { recentLanguagesRaw.compactMap(Language.init(rawValue:)) }
		set {
			recentLanguagesRaw = newValue.map(\.rawValue)
			userDefaults.set(recentLanguagesRaw, forKey: Key.recentLanguages.rawValue)
		}
	}
	
	var frontLanguage: Language {
		get { Language(rawValue: frontLanguageRaw) ?? .en_US }
		set {
			frontLanguageRaw = newValue.rawValue
			userDefaults.set(frontLanguageRaw, forKey: Key.frontLanguage.rawValue)
		}
	}
	
	var backLanguage: Language {
		get { Language(rawValue: backLanguageRaw) ?? .en_US }
		set {
			backLanguageRaw = newValue.rawValue
			userDefaults.set(backLanguageRaw, forKey: Key.backLanguage.rawValue)
		}
	}
	
	var exactMatch: Language {
		get { Language(rawValue: exactMatchRaw) ?? .en_US }
		set {
			exactMatchRaw = newValue.rawValue
			userDefaults.set(exactMatchRaw, forKey: Key.exactMatch.rawValue)
		}
	}
	
	var selectDeck: UUID? {
		get { UUID(uuidString: selectDeckRaw) }
		set {
			selectDeckRaw = newValue?.uuidString ?? ""
			userDefaults.set(selectDeckRaw, forKey: Key.selectDeck.rawValue)
		}
	}
	
	var trialTimeInterval: TimeInterval {
		get { trialTimeIntervalRaw }
		set {
			trialTimeIntervalRaw = newValue
			userDefaults.set(trialTimeIntervalRaw, forKey: Key.trialTimeInterval.rawValue)
		}
	}
	
	var trialDeck: UUID? {
		get { UUID(uuidString: trialDeckRaw) }
		set {
			trialDeckRaw = newValue?.uuidString ?? ""
			userDefaults.set(trialDeckRaw, forKey: Key.trialDeck.rawValue)
		}
	}
	
	var trialNumberOfCards: Int {
		get { trialNumberOfCardsRaw }
		set {
			trialNumberOfCardsRaw = newValue
			userDefaults.set(trialNumberOfCardsRaw, forKey: Key.trialNumberOfCards.rawValue)
		}
	}
	
	var trialOrder: SortTrial {
		get { SortTrial(rawValue: trialOrderRaw) ?? .random }
		set {
			trialOrderRaw = newValue.rawValue
			userDefaults.set(trialOrderRaw, forKey: Key.trialOrder.rawValue)
		}
	}
	
	var trialMode: Mode {
		get { Mode(rawValue: trialModeRaw) ?? .standard }
		set {
			trialModeRaw = newValue.rawValue
			userDefaults.set(trialModeRaw, forKey: Key.trialMode.rawValue)
		}
	}
	
	var trialRefreshTimer: Double {
		get { trialRefreshTimerRaw }
		set {
			trialRefreshTimerRaw = newValue
			userDefaults.set(trialRefreshTimerRaw, forKey: Key.trialRefreshTimer.rawValue)
		}
	}
	
	var trialSwipeThreshold: CGFloat {
		get { CGFloat(trialSwipeThresholdRaw) }
		set {
			trialSwipeThresholdRaw = Double(newValue)
			userDefaults.set(trialSwipeThresholdRaw, forKey: Key.trialSwipeThreshold.rawValue)
		}
	}
	
	var trialSide: Side {
		get { Side(rawValue: trialSideRaw) ?? .front }
		set {
			trialSideRaw = newValue.rawValue
			userDefaults.set(trialSideRaw, forKey: Key.trialSide.rawValue)
		}
	}
	
	var lastCleanup: Date? {
		get { lastCleanupRaw == 0 ? nil : Date(timeIntervalSince1970: lastCleanupRaw) }
		set {
			lastCleanupRaw = newValue?.timeIntervalSince1970 ?? 0
			userDefaults.set(lastCleanupRaw, forKey: Key.lastCleanup.rawValue) }
	}
	
	var audioQuality: AudioQuality {
		get { AudioQuality(rawValue: audioQualityRaw) ?? .high }
		set {
			audioQualityRaw = newValue.rawValue
			userDefaults.set(audioQualityRaw, forKey: Key.audioQuality.rawValue)
		}
	}
	
	var profileImage: String {
		get { profileImageRaw }
		set {
			profileImageRaw = newValue
			userDefaults.set(profileImageRaw, forKey: Key.profileImage.rawValue)
		}
	}
	
	var profileName: String {
		get { profileNameRaw }
		set {
			profileNameRaw = newValue
			userDefaults.set(profileNameRaw, forKey: Key.profileName.rawValue)
		}
	}
	
	var profileUUID: UUID {
		get { UUID(uuidString: profileUUIDRaw)! }
		set {
			profileUUIDRaw = newValue.uuidString
			userDefaults.set(profileUUIDRaw, forKey: Key.profileUUID.rawValue)
		}
	}
	
	var visibleDecks: Bool {
		get { visibleDecksRaw }
		set {
			visibleDecksRaw = newValue
			userDefaults.set(visibleDecksRaw, forKey: Key.visibleDecks.rawValue)
		}
	}
	
	var sortDecks: [SortDeck] {
		get { sortDecksRaw.compactMap(SortDeck.init(rawValue:)) }
		set {
			sortDecksRaw = newValue.map(\.rawValue)
			userDefaults.set(sortDecksRaw, forKey: Key.sortDecks.rawValue)
		}
	}
	
	var invertCards: Bool {
		get { invertCardsRaw }
		set {
			invertCardsRaw = newValue
			userDefaults.set(invertCardsRaw, forKey: Key.invertCards.rawValue)
		}
	}
	
	var visibleCards: Bool {
		get { visibleCardsRaw }
		set {
			visibleCardsRaw = newValue
			userDefaults.set(visibleCardsRaw, forKey: Key.visibleCards.rawValue)
		}
	}
	
	var sortCards: [SortCard] {
		get { sortCardsRaw.compactMap(SortCard.init(rawValue:)) }
		set {
			sortCardsRaw = newValue.map(\.rawValue)
			userDefaults.set(sortCardsRaw, forKey: Key.sortCards.rawValue)
		}
	}
	
	var languageFilter: LanguageFilter {
		get { LanguageFilter(rawValue: languageFilterCardsRaw) ?? .atLeastOne }
		set {
			languageFilterCardsRaw = newValue.rawValue
			userDefaults.set(languageFilterCardsRaw, forKey: Key.languageFilterCards.rawValue)
		}
	}
	
	// In Deck
	
	var gradientBackground: Bool {
		get { gradientBackgroundRaw }
		set {
			gradientBackgroundRaw = newValue
			userDefaults.set(gradientBackgroundRaw, forKey: Key.gradientBackground.rawValue)
		}
	}
	
	var animationBackground: Bool {
		get { animationBackgroundRaw }
		set {
			animationBackgroundRaw = newValue
			userDefaults.set(animationBackgroundRaw, forKey: Key.animationBackground.rawValue)
		}
	}
}

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
		
		// In New Card
		case frontLanguage
		case backLanguage
		case exactMatch
		
		// In Trial
		case trialTimeInterval
		case trialDeck
		case trialNumberOfCards
		case trialOrder
		case trialMode
		
		// In Settings
		case lastCleanDuplicate
		case trialRefreshTimer
	}
	
	static let unique: Preferences = Preferences()
	
	private let userDefaults: UserDefaults = UserDefaults.standard
	private var frontLanguageRaw: String = ""
	private var backLanguageRaw: String = ""
	private var exactMatchRaw: String = ""
	private var trialTimeIntervalRaw: TimeInterval = 4.0
	private var trialDeckRaw: String = ""
	private var trialNumberOfCardsRaw: Int = 0
	private var trialOrderRaw: Int = 0
	private var trialModeRaw: Int = 0
	private var lastCleanDuplicateRaw: Double = 0
	private var trialRefreshTimerRaw: Double = 1.0/60.0
	
	private init() {
		
		let defaultLanguage: String = Language.en_US.rawValue
		
		frontLanguageRaw = userDefaults.string(forKey: Key.frontLanguage.rawValue) ?? defaultLanguage
		backLanguageRaw = userDefaults.string(forKey: Key.backLanguage.rawValue) ?? defaultLanguage
		exactMatchRaw = userDefaults.string(forKey: Key.exactMatch.rawValue) ?? defaultLanguage
		trialTimeIntervalRaw = userDefaults.object(forKey: Key.trialTimeInterval.rawValue) as? Double ?? 4.0
		trialDeckRaw = userDefaults.string(forKey: Key.trialDeck.rawValue) ?? ""
		trialNumberOfCardsRaw = userDefaults.integer(forKey: Key.trialNumberOfCards.rawValue)
		trialOrderRaw = userDefaults.integer(forKey: Key.trialOrder.rawValue)
		trialModeRaw = userDefaults.integer(forKey: Key.trialMode.rawValue)
		lastCleanDuplicateRaw = userDefaults.double(forKey: Key.lastCleanDuplicate.rawValue)
		trialRefreshTimerRaw = userDefaults.object(forKey: Key.trialRefreshTimer.rawValue) as? Double ?? (1.0 / 60.0)
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
			userDefaults.set(newValue, forKey: Key.trialNumberOfCards.rawValue)
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
	
	var lastCleanDuplicate: Date? {
		get { lastCleanDuplicateRaw == 0 ? nil : Date(timeIntervalSince1970: lastCleanDuplicateRaw) }
		set {
			lastCleanDuplicateRaw = newValue?.timeIntervalSince1970 ?? 0
			userDefaults.set(lastCleanDuplicateRaw, forKey: Key.lastCleanDuplicate.rawValue) }
	}
	
	var trialRefreshTimer: Double {
		get { trialRefreshTimerRaw }
		set {
			trialRefreshTimerRaw = newValue
			userDefaults.set(newValue, forKey: Key.trialRefreshTimer.rawValue)
		}
	}
}

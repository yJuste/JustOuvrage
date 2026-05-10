//
//  Preferences.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/19/26.
//

import SwiftUI
import Observation

/// An Interface that lists all `persisted selections` with UserDefault.
enum PreferencesKey: String {
	
	case frontLanguage	/// for NewCardView
	case backLanguage	///
	case exactMatch		/// for SearchView match
	case lastCleanDuplicate
}

/// A singleton that manages persisted user selections.
/// External Dependencies: PreferencesKey
@Observable final class Preferences {
	
	static let unique = Preferences()
	
	private var frontLanguageRaw: String = ""
	private var backLanguageRaw: String = ""
	private var exactMatchRaw: String = ""
	private var lastCleanDuplicateRaw: Double = 0
	
	private init() {
		frontLanguageRaw = UserDefaults.standard.string(forKey: PreferencesKey.frontLanguage.rawValue) ?? Language.en_US.rawValue
		backLanguageRaw = UserDefaults.standard.string(forKey: PreferencesKey.backLanguage.rawValue) ?? Language.en_US.rawValue
		exactMatchRaw = UserDefaults.standard.string(forKey: PreferencesKey.exactMatch.rawValue) ?? Language.en_US.rawValue
		lastCleanDuplicateRaw = UserDefaults.standard.double(forKey: PreferencesKey.lastCleanDuplicate.rawValue)
	}
}

extension Preferences {
	
	var frontLanguage: Language {
		get { Language(rawValue: frontLanguageRaw) ?? .en_US }
		set {
			frontLanguageRaw = newValue.rawValue
			UserDefaults.standard.set(newValue.rawValue, forKey: PreferencesKey.frontLanguage.rawValue)
		}
	}
	
	var backLanguage: Language {
		get { Language(rawValue: backLanguageRaw) ?? .en_US }
		set {
			backLanguageRaw = newValue.rawValue
			UserDefaults.standard.set(newValue.rawValue, forKey: PreferencesKey.backLanguage.rawValue)
		}
	}
	
	var exactMatch: Language {
		get { Language(rawValue: exactMatchRaw) ?? .en_US }
		set {
			exactMatchRaw = newValue.rawValue
			UserDefaults.standard.set(newValue.rawValue, forKey: PreferencesKey.exactMatch.rawValue)
		}
	}
	
	var lastCleanDuplicate: Date? {
		get { lastCleanDuplicateRaw == 0 ? nil : Date(timeIntervalSince1970: lastCleanDuplicateRaw) }
		set {
			lastCleanDuplicateRaw = newValue?.timeIntervalSince1970 ?? 0
			UserDefaults.standard.set(lastCleanDuplicateRaw, forKey: PreferencesKey.lastCleanDuplicate.rawValue)
		}
	}
}

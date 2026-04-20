//
//  Preferences.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/19/26.
//

import SwiftUI
import Observation

//	--- ESSENTIAL --------------------------------------------------------------

/// An interface that lists all preference values.
enum PreferencesKey: String {
	
	/// for NewCardView
	case frontLanguage
	case backLanguage
}

//	----------------------------------------------------------------------------

/// A singleton interface that stores user preferences.
/// External Dependencies: PreferencesKey
@Observable final class Preferences {
	
	static let unique = Preferences()
	
	private var frontLanguageRaw: String = ""
	private var backLanguageRaw: String = ""
	
	private init() {
		frontLanguageRaw = UserDefaults.standard.string(forKey: PreferencesKey.frontLanguage.rawValue) ?? Language.en_US.rawValue
		backLanguageRaw = UserDefaults.standard.string(forKey: PreferencesKey.backLanguage.rawValue) ?? Language.en_US.rawValue
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
}

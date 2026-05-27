//
//  JustOuvrageApp.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftUI
import SwiftData

// MARK: 

/// Main of the JustOuvrage App.
@main
struct JustOuvrageApp: App {
	
	init() {
		Appearance.configurePicker()
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(FileImageStorage())
				.environment(Recording())
				.environment(Navigation())
				//.tint(Preferences.unique.globalColor.color)
		}
		.modelContainer(for: [Card.self, Deck.self, Draft.self, TimeTrial.self])
	}
}

//
//  JustOuvrageApp.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftUI
import SwiftData

/// Main of the JustOuvrage App.
@main
struct JustOuvrageApp: App {
	
	init() {
		PickerView.configure()
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(FileImageStorage())
		}
		.modelContainer(for: [Card.self, Deck.self])
	}
}

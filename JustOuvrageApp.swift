//
//  JustOuvrageApp.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftUI
import SwiftData

/// Main of the App JustOuvrage.
@main
struct JustOuvrageApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.modelContainer(for: Card.self)
	}
}

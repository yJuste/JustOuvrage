//
//  JustOuvrageApp.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//
// Main

import SwiftUI
import SwiftData

@main
struct JustOuvrageApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.modelContainer(for: Card.self)
	}
}

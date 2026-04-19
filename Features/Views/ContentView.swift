//
//  ContentView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftUI
import SwiftData

/// The main View where everything comes through.
/// External Dependencies: Card, HomeView, SafariExtensionView, SettingsView
struct ContentView: View {
	
	@Environment(\.modelContext) private var context
	@Query(sort: \Card.createdAt, order: .reverse) var cards: [Card]
	
#if DEBUG
	@State private var showSafariExtension: Bool = false
#endif
	
	var body: some View {
		NavigationStack {
			List {
				NavigationLink {
					HomeView()
				} label: {
					Label("Every Card", systemImage: "menucard.fill")
				}
				NavigationLink {
					SafariExtensionView(showSafariExtension: $showSafariExtension)
				} label: {
					Label("Safari Extension", systemImage: "safari.fill")
				}
				Section {
					NavigationLink {
						SettingsView()
					} label: {
						Label("Settings", systemImage: "gearshape.fill")
					}
				}
			}
			.navigationTitle("JustOuvrage")
		}
	}
}

#Preview {
	let container = try! ModelContainer(for: Card.self)
    ContentView()
		.modelContainer(container)
}

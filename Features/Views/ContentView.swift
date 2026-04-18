//
//  ContentView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftUI
import SwiftData

/// The main View where everything comes in.
struct ContentView: View {
	
	@Environment(\.modelContext) private var context
	@State private var showSafariExtension: Bool = false
	
#if DEBUG
	var cards: [Card] {
		return (1...20).map { i in
			Card(frontEntry: "Front \(i)", backEntry: "Back \(i)", frontLanguageCode: .en_US, backLanguageCode: .en_US)
		}
	}
#else
	//@Query(sort: \Card.creationDate, order: .reverse) var cards: [Card]
#endif
	
	var body: some View {
		NavigationStack {
			List {
				NavigationLink {
					HomeView(cards: cards)
				} label: {
					Label("Every Cards", systemImage: "menucard.fill")
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

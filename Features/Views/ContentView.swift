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

	@State private var search: String = ""
	@State private var showSafariExtension: Bool = false
	@State private var showExpand: Bool = false
	
#if DEBUG
	var cards: [Card] {
		let languages: [Language] = [.en_US, .en_GB, .fr_FR, .es_ES]
		
		return (1...20).map { i in
			Card(name: "Words \(i)", definition: "Definition \(i)", language: languages[i % languages.count])
		}
	}
#else
	@Query(sort: \Card.creationDate, order: .reverse) var cards: [Card]
#endif
	
	var filteredCards: [Card] {
		if search.isEmpty {
			return cards
		} else {
			return cards.filter {
				$0.name.localizedCaseInsensitiveContains(search)
				|| $0.definition.localizedCaseInsensitiveContains(search)
			}
		}
	}
	
	var body: some View {
		NavigationView {
			List {
				NavigationLink {
					HomeView(filteredCards: filteredCards, showExpand: $showExpand, search: $search)
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

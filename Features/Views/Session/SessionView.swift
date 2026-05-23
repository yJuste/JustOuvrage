//
//  SessionView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/20/26.
//

import SwiftUI
import SwiftData

// MARK: In future updates, add Session for creating record audio, site session, language session, trial mode session

struct SessionView: View {
	
	enum SessionRoute: Hashable {
		
		case audio(UUID)
	}
	
	@Namespace private var namespace
	
	@State private var selectedSession: SessionRoute?
	
	private let audio = UUID()
	
	var body: some View {
		NavigationStack {
			ScrollView {
				Section {
					LazyVStack(spacing: 10) {
						SessionBanner(id: audio, namespace: namespace, title: "Audio Recording", image: .audioRecording) {
							selectedSession = .audio(audio)
						}
					}
					.padding()
				}
			}
			.navigationDestination(item: $selectedSession) { session in
				switch session {
				case .audio(let id):
					SessionRecordingView(id: id, namespace: namespace)
				}
			}
			.navigationTitle("Session")
			.toolbarTitleDisplayMode(.inlineLarge)
			.listStyle(.plain)
		}
	}
}

#Preview {
	
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: Deck.self, TimeTrial.self, configurations: config)
	let context = container.mainContext
	let cards: [Card] = [Card(frontEntry: "FrontEntry", backEntry: "BackEntry", frontLanguage: .fr_CA, backLanguage: .en_GB)]
	let deck1 = Deck(name: "Hello", image: "deck")
	let deck2 = Deck(name: "Lucas", image: "deck")
	let deck3 = Deck(name: "All", image: "deck")
	
	let argument = Trial.make(cards: cards, deck: deck1, mode: .chill, order: .alphabeticalAscending, numberOfCards: 30, interval: 5.0)
	context.insert(deck1)
	context.insert(deck2)
	context.insert(deck3)
	context.insert(TimeTrial(argument: argument, with: 0.8))
	context.insert(TimeTrial(argument: argument, with: 0.8))
	context.insert(TimeTrial(argument: argument, with: 0.8))
	
	return SessionView()
		.modelContainer(container)
		.environment(FileImageStorage())
}

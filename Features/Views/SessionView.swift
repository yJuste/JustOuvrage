//
//  SessionView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/20/26.
//

import SwiftUI
import SwiftData

// MARK: In future updates, add Session for creating record audio, site session, language session, trial mode session

enum SessionRoute: Hashable {
	
	case audio(UUID)
}

struct SessionView: View {
	
	@Namespace private var namespace
	
	@Query(sort: \TimeTrial.createdAt, order: .reverse) private var sessions: [TimeTrial]
	
	@State private var selectedSession: SessionRoute?
	
	private let audio = UUID()
	
	var body: some View {
		NavigationStack {
			ScrollView {
				Section {
					LazyVStack(spacing: 10) {
						SessionBanner(id: audio, namespace: namespace, title: "Audio Recording", image: .yellowflower) {
							selectedSession = .audio(audio)
						}
					}
					.padding()
				}
			}
			.navigationDestination(item: $selectedSession) { session in
				switch session {
				case .audio(let id):
					AudioRecordingSession(id: id, namespace: namespace)
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
	let deck1 = Deck(name: "Hello", image: "deck")
	let deck2 = Deck(name: "Lucas", image: "deck")
	let deck3 = Deck(name: "All", image: "deck")
	context.insert(deck1)
	context.insert(deck2)
	context.insert(deck3)
	context.insert(TimeTrial(in: deck1, using: .standard, with: 0.8))
	context.insert(TimeTrial(in: deck1, using: .standard, with: 0.4))
	context.insert(TimeTrial(in: deck2, using: .standard, with: 0.9))
	return SessionView()
		.modelContainer(container)
		.environment(FileImageStorage())
}

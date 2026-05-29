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
	
	@Namespace private var namespace
	
	@State private var showAudioRecording: Bool = false
	@State private var showTimeTrial: Bool = false
	@State private var showLeitner: Bool = false
	
	private var audioRecording: RecordingSession = Session.unique.audioRecording
	private var timeTrial: TimeTrialSession = Session.unique.timeTrial
	private var leitner: LeitnerSession = Session.unique.leitner
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 10) {
					SessionBanner(id: audioRecording.id, namespace: namespace, title: audioRecording.title, image: audioRecording.banner) {
						showAudioRecording.toggle()
					}
					SessionBanner(id: timeTrial.id, namespace: namespace, title: timeTrial.title, image: timeTrial.banner) {
						showTimeTrial.toggle()
					}
					SessionBanner(id: leitner.id, namespace: namespace, title: leitner.title, image: leitner.banner) {
						showLeitner.toggle()
					}
				}
				.padding()
			}
			.navigationDestination(isPresented: $showAudioRecording) {
				SessionRecordingView(id: audioRecording.id, namespace: namespace)
			}
			.navigationDestination(isPresented: $showTimeTrial) {
				SessionTimeTrialView(id: timeTrial.id, namespace: namespace)
			}
			.navigationDestination(isPresented: $showLeitner) {
				SessionLeitnerView(id: leitner.id, namespace: namespace)
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
	
	let argument = Argument.make(deck: deck1, cards: cards, side: .front, mode: .chill, directions: [.left], timeInterval: 4.0, order: .alphabeticalAscending, numberOfCards: 30)
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

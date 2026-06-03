//
//  SessionView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/20/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: In future updates, add Session for creating record audio, site session, language session, trial mode session

struct SessionView: View {
	
	@Namespace private var namespace
	
	@State private var showAudioRecording: Bool = false
	@State private var showTimeTrial: Bool = false
	@State private var showLeitner: Bool = false
	@State private var showAchievements: Bool = false
	@State private var order: [SessionKind] = Preferences.unique.sessionOrder
	@State private var isReordering: Bool = false
	
	private var achievements: AchievementsSession = Session.unique.achievements
	private var audioRecording: RecordingSession = Session.unique.audioRecording
	private var timeTrial: TimeTrialSession = Session.unique.timeTrial
	private var leitner: LeitnerSession = Session.unique.leitner
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 10) {
					ForEach(order) { kind in
						banner(for: kind)
							.scaleEffect(isReordering ? 1.02 : 1)
							.opacity(isReordering ? 0.95 : 1)
							.animation(.easeInOut, value: isReordering)
							.draggable(kind)
							.dropDestination(for: SessionKind.self) { items, _ in
								guard let from = items.first, let fromIndex = order.firstIndex(of: from), let toIndex = order.firstIndex(of: kind) else { return false }
								withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
									let moved = order.remove(at: fromIndex)
									order.insert(moved, at: toIndex)
									Preferences.unique.sessionOrder = order
								}
								return true
							}
					}
				}
				.padding()
			}
			.navigationTitle("Session")
			.toolbarTitleDisplayMode(.inlineLarge)
			.navigationDestination(isPresented: $showAchievements) {
				SessionAchievementsView(id: achievements.id, namespace: namespace)
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
		}
	}
	
	@ViewBuilder private func banner(for kind: SessionKind) -> some View {
		switch kind {
		case .achievements: SessionBanner(id: achievements.id, namespace: namespace, title: achievements.title, image: achievements.banner) {
			showAchievements.toggle()
		}
		case .audioRecording: SessionBanner(id: audioRecording.id, namespace: namespace, title: audioRecording.title, image: audioRecording.banner) {
			showAudioRecording.toggle()
		}
		case .timeTrial: SessionBanner(id: timeTrial.id, namespace: namespace, title: timeTrial.title, image: timeTrial.banner) {
			showTimeTrial.toggle()
		}
		case .leitner: SessionBanner(id: leitner.id, namespace: namespace, title: leitner.title, image: leitner.banner) {
			showLeitner.toggle()
		}
		}
	}
}

enum SessionKind: String, CaseIterable, Identifiable, Transferable {
	
	case achievements
	case audioRecording
	case timeTrial
	case leitner
	
	var id: String { rawValue }
	
	static var transferRepresentation: some TransferRepresentation {
		ProxyRepresentation { kind in
			kind.rawValue
		} importing: { rawValue in
			guard let kind = SessionKind(rawValue: rawValue) else { throw Errors.Transfer }
			return kind
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

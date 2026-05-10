//
//  DraftView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/3/26.
//

import SwiftUI
import SwiftData

/// A view that displays a draft card.
struct DraftView: View {
	
	let draft: Draft
	let site: Site.Sites = Site.unique
	
	@Environment(\.modelContext) private var context
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@Bindable private var preferences: Preferences = Preferences.unique
	@State private var destination: Destination?
	@State private var showLanguage: Bool = false
	@State private var showNewCard: Bool = false
	@State private var showAddedBanner: Bool = false
	@State private var card: Card?
	
	var cleanEntry: [String] { cleanWords(expression: draft.entry) }
	var selectedLanguage: Language {
		get { preferences.exactMatch }
		set { preferences.exactMatch = newValue }
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					Section {
						LabelTrailing(title: "\(selectedLanguage.language)") {
							Text("\(draft.entry)")
						}
						WordsLinkingToSite(title: "Forvo", item: cleanEntry) { entry in
							destination = site.forvo.link(for: entry, in: (selectedLanguage, selectedLanguage))
						}
						WordsLinkingToSite(title: "WordReference", item: cleanEntry) { entry in
							destination = site.wordReference.link(for: entry, in: selectedLanguage)
						}
						WordsLinkingToSite(title: "Google", item: cleanEntry) { entry in
							destination = site.google.link(for: entry, in: selectedLanguage)
						}
					} /// ``Entry``
					Section {
						VStack(alignment: .leading) {
							Text(draft.createdAt, format: .dateTime.year().month().day())
						}
						.foregroundStyle(.secondary)
						.padding(.vertical)
					} /// ``Metadata``
				}
				.buttonStyle(.plain)
				.padding(.horizontal)
			}
			.sheet(item: $card) { card in
				EditCardView(card: card)
					.presentationDetents([.fraction(Constants.heightOfANewCard), .large])
					.presentationDragIndicator(.visible)
					.onDisappear {
						Task { await showAdded() }
					}
			}
			.fullScreenCover(item: $destination) { destination in
				SFSafariViewWrapper(url: destination.url)
			}
			.toolbar { toolbar }
			.overlay(alignment: .top) {
				if showAddedBanner {
					HStack(spacing: 6) {
						Text("Added")
						Image(systemName: "checkmark.circle.fill")
					}
					.font(.subheadline.weight(.medium))
					.padding(.horizontal, 14)
					.padding(.vertical, 10)
					.background(.regularMaterial)
					.clipShape(Capsule())
					.offset(y: -55)
					.transition(.move(edge: .top).combined(with: .opacity))
				}
			}
			.scrollIndicators(.hidden)
		}
	}
}

/// Toolbar.
fileprivate extension DraftView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				Button {
					card = openCard(entry: draft.entry)
				} label: {
					Label("Add to Library", systemImage: "slider.horizontal.3")
				}
				Button {
					Task { await showAdded() }
					_ = openCard(entry: draft.entry)
				} label: {
					Label("Quick Add", systemImage: "plus.square.fill")
				}
			} label: {
				Image(systemName: "ellipsis")
			}
		}
		ToolbarItem(placement: .topBarLeading) {
			Button {
				showLanguage.toggle()
			} label: {
				Image(selectedLanguage.flagAsset)
					.resizable()
					.frame(width: 36, height: 36)
					.clipShape(Circle())
			}
			.popover(isPresented: $showLanguage) {
				FlagPicker(selected: $preferences.exactMatch)
					.padding(25)
					.presentationCompactAdaptation(.none)
			}
		}
		ToolbarItem(placement: .principal) {
			Text("Recent searches")
				.font(.caption)
		}
	}
}

/// Methods of CardView.
fileprivate extension DraftView {
	
	private func cleanWords(expression: String) -> [String] {
		return expression
			.components(separatedBy: ",")
			.map {
				$0.unicodeScalars.filter { !($0.properties.isEmoji && $0.properties.isEmojiPresentation) }.map { String($0) }.joined()
					.trimmingCharacters(in: .whitespacesAndNewlines)
			}
			.filter { !$0.isEmpty }
	}
	
	private func openCard(entry: String) -> Card {
		let newCard = Card(frontEntry: entry, backEntry: entry, frontLanguage: selectedLanguage, backLanguage: selectedLanguage)
		context.insert(newCard)
		return newCard
	}
	
	@MainActor private func showAdded() async {
		withAnimation(.snappy) {
			showAddedBanner.toggle()
		}
		try? await Task.sleep(for: .seconds(1.5))
		withAnimation(.snappy) {
			showAddedBanner.toggle()
		}
	}
}

#Preview {
	
	@Previewable @State var draft = Draft(entry: "I want you.", language: .en_US)
	
	DraftView(draft: draft)
}

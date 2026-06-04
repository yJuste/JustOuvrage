//
//  DraftView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/3/26.
//

import SwiftUI
import SwiftData
import SafariServices

/// A view that displays a draft card.
struct DraftView: View {
	
	let draft: Draft
	let site: Site.Sites = Site.unique
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.openURL) var openURL
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@Bindable private var preferences: Preferences = .unique
	@State private var card: Card?
	@State private var showLanguage: Bool = false
	@State private var showNewCard: Bool = false
	@State private var showAddedBanner: Bool = false
	
	var cleanEntry: [String] {
		cleanWords(expression: draft.entry)
	}
	
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
						WordsLinkingToSite(title: "Google", item: cleanEntry) { entry in
							openURL(site.google.link(for: entry, in: selectedLanguage))
						}
						WordsLinkingToSite(title: "Forvo", item: cleanEntry) { entry in
							openURL(site.forvo.link(for: entry, in: selectedLanguage))
						}
						WordsLinkingToSite(title: "WordReference", item: cleanEntry) { entry in
							openURL(site.wordReference.link(for: entry, in: (selectedLanguage, preferences.backLanguage)))
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
			.overlay(alignment: .top) {
				if showAddedBanner {
					Label("Added", systemImage: "checkmark.circle.fill")
						.environment(\.layoutDirection, .rightToLeft)
						.font(.subheadline.weight(.medium))
						.padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
						.background(.regularMaterial)
						.clipShape(Capsule())
						.transition(.move(edge: .top).combined(with: .opacity))
				}
			}
			.toolbar { toolbar }
			.navigationTitle("Recent Searches")
			.navigationBarTitleDisplayMode(.inline)
			.sheet(item: $card) { card in
				EditCardView(title: "Add Card To Library", card: card, onSave: { card in Task { await showAdded() }; modelContext.insert(card)})
					.presentationDetents([
						.fraction(Constants.heightOfANewCard),
						.large
					])
					.presentationDragIndicator(.visible)
			}
			.scrollIndicators(.hidden)
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

/// Toolbar.
fileprivate extension DraftView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		let entry = draft.entry
		let profileName = preferences.profileName
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				Button {
					card = Card(frontEntry: entry, backEntry: "", frontLanguage: selectedLanguage, backLanguage: selectedLanguage, author: profileName)
				} label: {
					Label("Add to Library", systemImage: "slider.horizontal.3")
				}
				Button {
					modelContext.insert(Card(frontEntry: entry, backEntry: entry, frontLanguage: selectedLanguage, backLanguage: selectedLanguage, author: profileName))
					Task { await showAdded() }
				} label: {
					Label("Quick Add", systemImage: "plus.square.fill")
				}
			} label: {
				Image(systemName: "ellipsis")
			}
			.tint(nil)
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
	}
}

#Preview {
	
	@Previewable @State var draft = Draft(entry: "I want you.", language: .en_US)
	
	DraftView(draft: draft)
}

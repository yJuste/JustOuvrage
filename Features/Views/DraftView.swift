//
//  DraftView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/3/26.
//

import SwiftUI

/// A view that displays a draft card.
struct DraftView: View {
	
	let draft: Draft
	let site: Site.Sites = Site.unique
	
	@Bindable private var preferences: Preferences = Preferences.unique
	@State private var destination: Destination?
	@State private var showLanguage: Bool = false
	
	var cleanEntry: [String] { cleanWords(expression: draft.entry) }
	var selectedLanguage: Language {
		get { preferences.exactMatch }
		set { preferences.exactMatch = newValue }
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					Section { /// ``Entry``
						LabelTrailing(title: "\(selectedLanguage.language)") {
							Text("\(draft.entry)")
						}
						WordsLinkingToSite("Forvo", item: cleanEntry) { entry in
							destination = site.forvo.link(for: entry, in: (selectedLanguage, selectedLanguage))
						}
						WordsLinkingToSite("WordReference", item: cleanEntry) { entry in
							destination = site.wordReference.link(for: entry, in: selectedLanguage)
						}
						WordsLinkingToSite("Google", item: cleanEntry) { entry in
							destination = site.google.link(for: entry, in: selectedLanguage)
						}
					}
				}
				.buttonStyle(.plain)
				.padding(.horizontal)
			}
			.toolbar { toolbar }
			.scrollIndicators(.hidden)
			.fullScreenCover(item: $destination) { destination in
				SFSafariViewWrapper(url: destination.url)
			}
		}
	}
}

/// Toolbar.
fileprivate extension DraftView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				Button {
					//
				} label: {
					Label("Add to Library", systemImage: "slider.horizontal.3")
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
			Text("\(selectedLanguage.language)")
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
}

#Preview {
	
	@Previewable @State var draft = Draft(entry: "I want you.", language: .en_US)
	
	DraftView(draft: draft)
}

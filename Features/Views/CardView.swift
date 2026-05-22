//
//  CardView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/27/26.
//

import SwiftUI
import SwiftData
import AVFoundation

// MARK: Have to create an Audio Player for not repetiting yourself.

/// A view that displays a Card.
/// External Dependencies: Card, SFSafariViewWrapper, LabelTrailing, WordsLinkingToSite, ForvoSite
struct CardView: View {
	
	let card: Card
	let site: Site.Sites = Site.unique
	
	@Environment(Recording.self) private var storage
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@State private var destination: Destination?
	@State private var showEditCard: Bool = false
	@State private var showDeleteCard: Bool = false
	@State private var showDecksToCard: Bool = false
	@State private var player: AVAudioPlayer?
	@State private var activePlaying: String?
	@State private var playerDelegate = PlayerDelegate()
	
	private var cleanFrontEntry: [String] { cleanWords(expression: card.frontEntry) }
	private var cleanBackEntry: [String] { cleanWords(expression: card.backEntry) }
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					Section {
						LabelTrailing(title: "\(card.frontLanguage.language)") {
							Text("\(card.frontEntry)")
						}
						WordsLinkingToSite(title: "Forvo", item: cleanFrontEntry) { entry in
							destination = site.forvo.link(for: entry, in: card.frontLanguage)
						}
						WordsLinkingToSite(title: "WordReference", item: cleanFrontEntry) { entry in
							destination = site.wordReference.link(for: entry, in: (card.frontLanguage, card.backLanguage))
						}
						WordsLinkingToSite(title: "Google", item: cleanFrontEntry) { entry in
							destination = site.google.link(for: entry, in: card.frontLanguage)
						}
					} /// ``First Entry``
					Section {
						LabelTrailing(title: "\(card.backLanguage.language)") {
							Text("\(card.backEntry)")
						}
						WordsLinkingToSite(title: "Forvo", item: cleanBackEntry) { entry in
							destination = site.forvo.link(for: entry, in: card.backLanguage)
						}
						WordsLinkingToSite(title: "WordReference", item: cleanBackEntry) { entry in
							destination = site.wordReference.link(for: entry, in: (card.backLanguage, card.frontLanguage))
						}
						WordsLinkingToSite(title: "Google", item: cleanBackEntry) { entry in
							destination = site.google.link(for: entry, in: card.backLanguage)
						}
					} /// ``Second Entry``
					Section {
						LabelTrailing(title: "Leitner Score") {
							Picker("Leitner Score",
								   selection: Binding(
									get: { card.leitnerScore },
									set: { card.leitnerScore = $0 })
							) {
								ForEach(1...7, id: \.self) { value in
									Text("\(value)")
										.tag(value)
								}
							}
							.pickerStyle(.segmented)
						}
					} /// ``Leitner Score``
					Section {
						VStack(alignment: .leading) {
							Text(card.createdAt, format: .dateTime.year().month().day())
							Text("\(card.author)")
							let names = Set(card.decks.map { $0.name }).sorted()
							Text(names.isEmpty ? "Not in any deck" : "In decks: " + names.joined(separator: " ⋅ "))
								.font(.caption)
						}
						.foregroundStyle(.secondary)
						.padding(.vertical)
					} /// ``Metadata``
				}
				.buttonStyle(.plain)
				.padding(.horizontal)
			}
			.onDisappear {
				stopPlaying()
			}
			.toolbar { toolbar }
			.scrollIndicators(.hidden)
			.sheet(isPresented: $showEditCard) {
				EditCardView(title: "Edit Card", card: card)
			}
			.sheet(isPresented: $showDecksToCard) {
				DecksToCard(card: card)
			}
			.fullScreenCover(item: $destination) {
				SFSafariViewWrapper(url: $0.url)
			}
			.alert("Delete Card", isPresented: $showDeleteCard) {
				Button("Remove", role: .destructive) {
					modelContext.delete(card)
					dismiss()
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Are you sure you want to delete this card from your library?")
			}
			// other fullScreenCovers
		}
	}
}

/// Methods of CardView.
private extension CardView {
	
	func stopPlaying() {
		player?.stop()
		player = nil
		activePlaying = nil
	}
	
	func play(_ filename: String?) {
		
		stopPlaying()
		guard let filename else { return }
		let url = storage.url(for: filename)
		do {
			let player = try AVAudioPlayer(contentsOf: url)
			playerDelegate.onFinish = {
				Task { @MainActor in
					self.activePlaying = nil
					self.player = nil
				}
			}
			player.delegate = playerDelegate
			self.player = player
			self.activePlaying = filename
			player.play()
		} catch {
			activePlaying = nil
		}
	}
	
	final class PlayerDelegate: NSObject, AVAudioPlayerDelegate {
		
		var onFinish: (() -> Void)?
		
		func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
			onFinish?()
		}
	}
}

/// Toolbar.
fileprivate extension CardView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				Button(role: .destructive) {
					showDeleteCard.toggle()
				} label: {
					Label("Delete from Library", systemImage: "trash")
				}
				Button {
					showDecksToCard.toggle()
				} label: {
					Label("Add decks", systemImage: "rectangle.stack.badge.plus")
				}
				Button {
					showEditCard.toggle()
				} label: {
					Label("Edit Card", systemImage: "slider.horizontal.3")
				}
			} label: {
				Image(systemName: "ellipsis")
			}
		}
		ToolbarItem(placement: .topBarLeading) {
			Image(card.frontLanguage.flagAsset)
				.resizable()
				.frame(width: 36, height: 36)
				.clipShape(Circle())
				.onTapGesture {
					play(card.frontRecording)
				}
		}
		ToolbarSpacer(placement: .topBarLeading)
		ToolbarItem(placement: .topBarLeading) {
			Image(card.backLanguage.flagAsset)
				.resizable()
				.frame(width: 36, height: 36)
				.clipShape(Circle())
				.onTapGesture {
					play(card.backRecording)
				}
		}
	}
}

/// Methods of CardView.
fileprivate extension CardView {
	
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
	
	CardView(
		card: Card(
			frontEntry: "hello my na🇺🇸m on, l, l,",
			backEntry: ",,,bonjour,,,,",
			frontLanguage: .en_US,
			backLanguage: .fr_CA
		)
	)
}


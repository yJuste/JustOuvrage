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
	
	@Bindable private var preferences: Preferences = .unique
	@State private var destination: Destination?
	@State private var player: AVAudioPlayer?
	@State private var activePlaying: String?
	@State private var playerDelegate = PlayerDelegate()
	@State private var showEditCard: Bool = false
	@State private var showDeleteCard: Bool = false
	@State private var showDecksToCard: Bool = false
	@State private var showRecording: Bool = false
	@State private var showMetaData: Bool = false
	@State private var showGradientBackground: Bool = Preferences.unique.gradientBackground
	
	private var cleanFrontEntry: [String] {
		cleanWords(expression: card.frontEntry)
	}
	private var cleanBackEntry: [String] {
		cleanWords(expression: card.backEntry)
	}
	
	private var dismissItems: [Binding<Bool>] {
		[$showEditCard, $showDecksToCard, $showRecording, $showMetaData]
	}
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					
					let frontEntry = card.frontEntry
					let backEntry = card.backEntry
					let frontLanguage = card.frontLanguage
					let backLanguage = card.backLanguage
					
					Section {
						LabelTrailing(title: "\(frontLanguage.language)") {
							Text(frontEntry)
						}
						WordsLinkingToSite(title: "Forvo", item: cleanFrontEntry) { entry in
							destination = site.forvo.link(for: entry, in: frontLanguage)
						}
						WordsLinkingToSite(title: "WordReference", item: cleanFrontEntry) { entry in
							destination = site.wordReference.link(for: entry, in: (frontLanguage, backLanguage))
						}
						WordsLinkingToSite(title: "Google", item: cleanFrontEntry) { entry in
							destination = site.google.link(for: entry, in: frontLanguage)
						}
						LabelTrailing(title: "\(backLanguage.language)") {
							Text(backEntry)
						}
						WordsLinkingToSite(title: "Forvo", item: cleanBackEntry) { entry in
							destination = site.forvo.link(for: entry, in: backLanguage)
						}
						WordsLinkingToSite(title: "WordReference", item: cleanBackEntry) { entry in
							destination = site.wordReference.link(for: entry, in: (backLanguage, frontLanguage))
						}
						WordsLinkingToSite(title: "Google", item: cleanBackEntry) { entry in
							destination = site.google.link(for: entry, in: backLanguage)
						}
					} /// ``Entries``
					.buttonStyle(.plain)
					Section {
						LabelTrailing(title: "Leitner Score") {
							Picker("Leitner Score",
								   selection: Binding(
									get: { card.leitnerScore },
									set: { Leitner.update(for: card, score: $0) })
							) {
								ForEach(1...7, id: \.self) { value in
									Text(value, format: .number)
										.tag(value)
								}
							}
							.id(preferences.globalColor)
							.pickerStyle(.segmented)
						}
					} /// ``Leitner Score``
					Section {
						VStack(alignment: .leading) {
							Text(card.createdAt, format: .dateTime.year().month().day())
							Text(card.author)
							let names = Set(card.decks.map { $0.name }).sorted()
							Text(names.isEmpty ? "Not in any deck" : "In decks: " + names.joined(separator: " ⋅ "))
								.font(.caption)
						}
						.foregroundStyle(.secondary)
						.padding(.vertical)
					} /// ``Metadata``
				}
				.padding(.horizontal)
			}
			.onAppear {
				Appearance.configurePicker()
			}
			.onDisappear {
				stopPlaying()
			}
			.toolbar { toolbar }
			.tint(nil)
			.scrollIndicators(.hidden)
			.fullScreenCover(item: $destination) {
				SFSafariViewWrapper(url: $0.url)
			}
			.sheet(isPresented: $showEditCard) {
				EditCardView(title: "Edit Card", card: card)
			}
			.sheet(isPresented: $showDecksToCard) {
				DecksToCard(card: card)
			}
			.sheet(isPresented: $showRecording) {
				RecordingView(card: card)
					.presentationDetents([
						.fraction(Constants.heightOfARecording[0]),
						.fraction(Constants.heightOfARecording[1])
					])
					.presentationBackgroundInteraction(.enabled)
			}
			.sheet(isPresented: $showMetaData) {
				CardMetaDataView(card: card)
					.presentationDetents([
						.fraction(Constants.heightOfAMetaData[0]),
						.fraction(Constants.heightOfAMetaData[1])
					])
					.presentationBackgroundInteraction(.enabled)
			}
			.alert("Delete Card", isPresented: $showDeleteCard) {
				Button("Delete", role: .destructive) {
					modelContext.delete(card)
					dismiss()
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Are you sure you want to delete this card from your library?")
			}
		}
	}
}

/// Methods of CardView.
fileprivate extension CardView {
	
	private func stopPlaying() {
		player?.stop()
		player = nil
		activePlaying = nil
	}
	
	private func play(_ filename: String?) {
		stopPlaying()
		guard let filename else { return }
		do {
			let player = try AVAudioPlayer(contentsOf: storage.url(for: filename))
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
	
	private final class PlayerDelegate: NSObject, AVAudioPlayerDelegate {
		var onFinish: (() -> Void)?
		func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
			onFinish?()
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

/// Toolbar.
fileprivate extension CardView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				Section {
					Button(role: .destructive) {
						showDeleteCard.toggle()
					} label: {
						Label("Delete from Library", systemImage: "trash")
					}
				}
				Section {
					Button {
						dismissItems.showOnly($showMetaData)
					} label: {
						Label("View Metadata", systemImage: "info.circle")
					}
				}
				Button {
					dismissItems.showOnly($showRecording)
				} label: {
					Label("Record audio", systemImage: "microphone.fill")
				}
				Button {
					dismissItems.showOnly($showDecksToCard)
				} label: {
					Label("Add decks", systemImage: "rectangle.stack.badge.plus")
				}
				Button {
					dismissItems.showOnly($showEditCard)
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


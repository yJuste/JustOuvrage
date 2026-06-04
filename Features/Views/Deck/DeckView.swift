//
//  DeckView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/28/26.
//

import SwiftUI
import SwiftData

/// A view that displays a Deck.
/// External Dependencies: Card, Deck, FileImageStorage, CardView, CardsToDeck
struct DeckView: View {
	
	let deck: Deck
	var namespace: Namespace.ID?
	
	@Environment(FileImageStorage.self) private var storage
	@Environment(Recording.self) private var recording
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@Query private var timeTrials: [TimeTrial]
	
	@Bindable private var preferences: Preferences = .unique
	@State private var globalColor: Color = Preferences.unique.globalColor.color
	@State private var selectedCard: Card?
	@State private var argument: Argument?
	@State private var colors: [Color]?
	@State private var exportURL: URL?
	@State private var isDownloaded = false
	@State private var showCard: Bool = false
	@State private var showDepiction: Bool = false
	@State private var showCardsToDeck: Bool = false
	@State private var showDeleteDeck: Bool = false
	@State private var showDeleteCard: Bool = false
	@State private var showEditDeck: Bool = false
	@State private var showTimeTrial: Bool = false
	@State private var showNoCards: Bool = false
	@State private var showDownload: Bool = false
	@State private var showMetaDataCard: Bool = false
	@State private var showMetaData: Bool = false
	@State private var showRecording: Bool = false
	@State private var showDecksToCard: Bool = false
	@State private var showEditCard: Bool = false
	@State private var showAddedBanner: Bool = false
	@State private var showExporting: Bool = false
	@State private var showGradientBackground: Bool = Preferences.unique.gradientBackground
	@State private var showAnimationBackground: Bool = Preferences.unique.animationBackground
	
	private var cardsFromDeck: [Card] {
		deck.cards.sorted { $0.createdAt > $1.createdAt }
	}
	
	private var averageSuccess: Double {
		let trials = timeTrials.filter { $0.deck?.id == deck.id }
		guard !trials.isEmpty else { return 0 }
		return trials.reduce(0) { $0 + $1.success } / Double(trials.count)
	}
	
	private var dismissItems: [Binding<Bool>] {
		[$showCard, $showCardsToDeck, $showEditDeck, $showDepiction, $showMetaDataCard, $showMetaData, $showTimeTrial, $showRecording, $showDecksToCard, $showEditCard, $showExporting]
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				if showGradientBackground {
					if let colors {
						AmazingBackground(colors: colors, active: showAnimationBackground ? true : false)
							.opacity(0.5)
							.ignoresSafeArea()
					}
				}
				ScrollView {
					VStack {
						Section {
							Image(image: deck.image, storage: storage)
								.resizable()
								.scaledToFill()
								.frame(width: 235, height: 235)
								.aspectRatio(1, contentMode: .fit)
								.clipShape(RoundedRectangle(cornerRadius: 8))
								.shadow(color: .black.opacity(0.2), radius: 5)
								.navigationTransition(id: deck.id, namespace: namespace)
							VStack(alignment: .center, spacing: 6) {
								VStack {
									Text(deck.name)
										.font(.system(size: 25, weight: .bold))
										.multilineTextAlignment(.center)
									Text(deck.author)
										.font(.title3)
									Text({let langs = Set(deck.cards.flatMap { [$0.frontLanguage, $0.backLanguage] }).map { $0.rawValue }.sorted()
										let year = deck.createdAt.formatted(.dateTime.year())
										return langs.isEmpty ? year : year + " ⋅ " + langs.joined(separator: " ⋅ ")}())
									.font(.system(size: 12, weight: .semibold))
									.foregroundStyle(.secondary)
									.padding(.top, 5)
								}
								.padding(.horizontal)
								GlassEffectContainer {
									HStack(alignment: .center, spacing: 15) {
										Button {
											let arg = Argument.make(deck: deck, cards: cards, side: .both, mode: .standard, directions: [], timeInterval: 5.0, order: .random, numberOfCards: 0)
											guard !arg.cards.isEmpty else { return showNoCards.toggle() }
											argument = arg
											dismissItems.toggleOnly($showTimeTrial)
										} label: {
											Image(systemName: "shuffle")
												.frame(width: 50, height: 50)
												.glassEffect(.clear.interactive())
										}
										Button {
											let arg = Argument.make(deck: deck, cards: cards, side: .front, mode: .chill, directions: [], timeInterval: Constants.infinityYear, order: .random, numberOfCards: 0)
											guard !arg.cards.isEmpty else { return showNoCards.toggle() }
											argument = arg
											dismissItems.toggleOnly($showTimeTrial)
										} label: {
											Label("Play", systemImage: "arrowtriangle.forward.fill")
												.frame(width: 160, height: 50)
												.glassEffect(.regular.tint(globalColor).interactive())
										}
										Button {
											showDownload.toggle()
										} label: {
											Image(systemName: "arrow.down")
												.frame(width: 50, height: 50)
												.glassEffect(.clear.interactive())
										}
									}
									.font(.system(size: 20, weight: .semibold))
								}
								.tint(.primary)
								.padding(.top, 10)
								let depiction = deck.depiction
								Text(depiction)
									.foregroundStyle(.secondary)
									.lineLimit(2)
									.multilineTextAlignment(.leading)
									.onTapGesture {
										dismissItems.showOnly($showDepiction)
									}
									.sheet(isPresented: $showDepiction) {
										ScrollView {
											Text(depiction)
												.padding(20)
										}
									}
							}
							.padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
						} /// ``header``
						Section {
							separator
							LazyVStack(alignment: .leading) {
								ForEach(Array(cardsFromDeck.enumerated()), id: \.element.id) { index, card in
									Button {
										selectedCard = card
										dismissItems.showOnly($showCard)
									} label: {
										HStack(spacing: 10) {
											Text(index + 1, format: .number)
												.font(.callout)
												.foregroundStyle(.secondary)
												.frame(width: 30, alignment: .center)
											VStack(alignment: .leading, spacing: 5) {
												Text(card.frontEntry)
												Text(card.backEntry)
													.foregroundStyle(.secondary)
											}
											.font(.subheadline)
											.frame(maxWidth: .infinity, alignment: .leading)
											Menu {
												Button {
													selectedCard = card
													dismissItems.showOnly($showEditCard)
												} label: {
													Label("Edit Card", systemImage: "slider.horizontal.3")
												}
												Button {
													selectedCard = card
													dismissItems.showOnly($showDecksToCard)
												} label: {
													Label("Add decks", systemImage: "rectangle.stack.badge.plus")
												}
												Button {
													selectedCard = card
													dismissItems.showOnly($showRecording)
												} label: {
													Label("Record audio", systemImage: "microphone.fill")
												}
												Section {
													Button {
														selectedCard = card
														dismissItems.showOnly($showMetaDataCard)
													} label: {
														Label("View Metadata", systemImage: "info.circle")
													}
												}
												Section {
													Button(role: .destructive) {
														selectedCard = card
														showDeleteCard.toggle()
													} label: {
														Label("Remove from the Deck", systemImage: "trash")
													}
												}
											} label: {
												Image(systemName: "ellipsis")
													.font(.system(size: 20, weight: .bold))
													.frame(width: 41, height: 41)
													.background (Circle().fill(.clear))
											}
											.padding(.trailing, 10)
											.buttonStyle(.plain)
											.tint(nil)
										}
										.padding(EdgeInsets(top: 3, leading: 15, bottom: 3, trailing: 15))
										.contentShape(Rectangle())
									}
									.contextMenu {
										Button(role: .destructive) {
											selectedCard = card
											showDeleteCard.toggle()
										} label: {
											Label("Remove from Deck", systemImage: "trash")
										}
										.tint(nil)
									}
									.buttonStyle(.plain)
									separator
								}
								.sheet(isPresented: $showCard) {
									if let card = selectedCard {
										CardView(card: card)
											.presentationDetents([
												.fraction(Constants.heightOfACard[0]),
												.fraction(Constants.heightOfACard[1])
											])
											.presentationBackgroundInteraction(.enabled)
									}
								}
								.sheet(isPresented: $showEditCard) {
									if let card = selectedCard {
										EditCardView(title: "Edit Card", card: card)
									}
								}
								.sheet(isPresented: $showDecksToCard) {
									if let card = selectedCard {
										DecksToCardView(card: card)
									}
								}
								.sheet(isPresented: $showRecording) {
									if let card = selectedCard {
										RecordingView(card: card)
											.presentationDetents([
												.fraction(Constants.heightOfARecording[0]),
												.fraction(Constants.heightOfARecording[1])
											])
											.presentationBackgroundInteraction(.enabled)
									}
								}
								.sheet(isPresented: $showMetaDataCard) {
									if let card = selectedCard {
										CardMetaDataView(card: card)
											.presentationDetents([
												.fraction(Constants.heightOfAMetaData[0]),
												.fraction(Constants.heightOfAMetaData[1])
											])
											.presentationBackgroundInteraction(.enabled)
									}
								}
								.alert("Are you sure you want to remove this card from this deck?", isPresented: $showDeleteCard) {
									Button("Remove", role: .destructive) {
										removeTheCard()
									}
									Button("Cancel", role: .cancel) { }
								}
							}
							Section { /// ``metadata``
								VStack(alignment: .leading) {
									Text(deck.createdAt, format: .dateTime.year().month().day())
									Text("\(deck.cards.count) cards")
									Text(deck.author)
									Text("Success \(averageSuccess.formatted(.percent.precision(.fractionLength(1))))")
									Text(Set(deck.cards.flatMap {[$0.frontLanguage, $0.backLanguage]}).sorted { $0.language < $1.language }.map { $0.language }.joined(separator: " ⋅ "))
										.font(.caption)
								}
								.foregroundStyle(.secondary)
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding()
							}
						} /// ``items``
					}
					.frame(maxWidth: .infinity)
					.padding(.top, 17)
				}
			}
			.onAppear {
				loadImageForBackground()
			}
			.onChange(of: deck.image) {
				loadImageForBackground()
			}
			.toolbar { toolbar }
			.navigationDestination(isPresented: $showTimeTrial) {
				if let argument = argument {
					TimeTrialView(argument: argument)
						.navigationBarBackButtonHidden(true)
						.navigationAllowDismissalGestures(.none)
				}
			}
			.sheet(isPresented: $showMetaData) {
				DeckMetaDataView(deck: deck)
					.presentationDetents([
						.fraction(Constants.heightOfAMetaData[0]),
						.fraction(Constants.heightOfAMetaData[1])
					])
					.presentationBackgroundInteraction(.enabled)
			}
			.sheet(isPresented: $showEditDeck) {
				EditDeckView(title: "Edit Deck", deck: deck)
			}
			.sheet(isPresented: $showCardsToDeck) {
				CardsToDeckView(deck: deck)
			}
			.sheet(isPresented: $showExporting) {
				if let exportURL {
					ShareSheet(items: [exportURL])
						.presentationDetents([
							.fraction(Constants.heightOfAShare[0]),
							.fraction(Constants.heightOfAShare[1])
						])
						.presentationBackgroundInteraction(.enabled)
				}
			}
			.overlay(alignment: .top) {
				if showAddedBanner {
					Label("Exportation", systemImage: "checkmark.circle.fill")
						.environment(\.layoutDirection, .rightToLeft)
						.font(.subheadline.weight(.medium))
						.padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
						.background((colors?.first ?? globalColor).opacity(0.8))
						.clipShape(Capsule())
						.transition(.move(edge: .top).combined(with: .opacity))
				}
			}
			.alert("Delete Deck", isPresented: $showDeleteDeck) {
				Button("Delete", role: .destructive) {
					modelContext.delete(deck)
					dismiss()
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Are you sure you want to delete this deck from your library?")
			}
			.alert("No cards", isPresented: $showNoCards) {
				Button("OK", role: .cancel) { }
			} message: {
				Text("You can't start the Time Trial because there are no cards in the deck.")
			}
			.alert("Download Deck", isPresented: $showDownload) {
				Button("Cancel", role: .cancel) { }
				Button("Download") {
					download(deck)
				}
			} message: {
				if let date = deck.lastDownloadAt {
					Text("Last download: \(date.formatted(date: .abbreviated, time: .shortened))")
				} else {
					Text("This deck has never been downloaded.")
				}
			}
			.navigationBarBackButtonHidden(true)
		}
	}
}

/// Methods of DeckView.
fileprivate extension DeckView {
	
	@MainActor private func showAdded() async {
		withAnimation(.snappy) {
			showAddedBanner.toggle()
		}
		try? await Task.sleep(for: .seconds(1.5))
		withAnimation(.snappy) {
			showAddedBanner.toggle()
		}
	}
	
	private func download(_ deck: Deck) {
		do {
			Task { await showAdded() }
			exportURL = try DataTransferObject.export(deck: deck, cards: deck.cards, recording: recording)
			deck.lastDownloadAt = .now
			dismissItems.showOnly($showExporting)
		} catch {
			print(Errors.DataTransfer)
		}
	}
	
	private func removeTheCard() {
		if let card = selectedCard {
			deck.cards.removeAll { $0.id == card.id }
		}
	}
	
	private func loadImageForBackground() {
		if let uiImage = try? storage.load(image: deck.image, size: 512) {
			if showGradientBackground {
				colors = Theme.gradientColors(from: uiImage)
			}
		} else {
			colors = nil
		}
	}
	
	private var separator: some View {
		Divider()
			.overlay {
				if let color = colors?.last {
					color.mix(with: colorScheme == .dark ? .white : .black, amount: 0.4)
				}
			}
			.opacity(colors?.last != nil ? 0.5 : 1.0)
			.padding(.horizontal)
	}
}

/// Toolbar.
fileprivate extension DeckView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				dismiss()
			} label: {
				Image(systemName: "chevron.backward")
			}
			.tint(nil)
		}
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				Button {
					dismissItems.showOnly($showEditDeck)
				} label: {
					Label("Edit Deck", systemImage: "slider.horizontal.3")
				}
				Button {
					dismissItems.showOnly($showCardsToDeck)
				} label: {
					Label("Add cards", systemImage: "plus.square.fill.on.square.fill")
				}
				Section {
					Button {
						dismissItems.showOnly($showMetaData)
					} label: {
						Label("View Metadata", systemImage: "info.circle")
					}
				}
				Section {
					Button(role: .destructive) {
						showDeleteDeck.toggle()
					} label: {
						Label("Delete from Library", systemImage: "trash")
					}
				}
			} label: {
				Image(systemName: "ellipsis")
			}
			.tint(nil)
		}
	}
}

#Preview {
	
	@Previewable @State var deck = Deck(name: "Hello", image: "deck", author: "yJuste")
	@Previewable @Namespace var namespace
	
	DeckView(deck: deck, namespace: namespace)
		.environment(FileImageStorage())
}

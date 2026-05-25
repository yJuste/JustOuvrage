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
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@Bindable private var preferences: Preferences = .unique
	@State private var selectedCard: Card?
	@State private var argument: Argument?
	@State private var colors: [Color]?
	@State private var showCard: Bool = false
	@State private var showToolbar: Bool = false
	@State private var showDepiction: Bool = false
	@State private var showCardsToDeck: Bool = false
	@State private var showDeleteDeck: Bool = false
	@State private var showEditDeck: Bool = false
	@State private var showTimeTrial: Bool = false
	@State private var showNoCards: Bool = false
	@State private var showDownload: Bool = false
	@State private var showGradientBackground: Bool = Preferences.unique.gradientBackground
	@State private var showAnimationBackground: Bool = Preferences.unique.animationBackground
	
	private var cardsFromDeck: [Card] {
		deck.cards.sorted { $0.createdAt > $1.createdAt }
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
											showCard = false
											let arg = Argument.make(deck: deck, cards: cards, mode: .standard, directions: [], timeInterval: 4.0, order: .random, numberOfCards: 0)
											guard !arg.cards.isEmpty else { return showNoCards.toggle() }
											argument = arg
											showTimeTrial.toggle()
										} label: {
											Image(systemName: "shuffle")
												.frame(width: 50, height: 50)
												.glassEffect(.clear.interactive())
										}
										Button {
											showCard = false
											let arg = Argument.make(deck: deck, cards: cards, mode: .chill, directions: [], timeInterval: Constants.infinityYear, order: .random, numberOfCards: 0)
											guard !arg.cards.isEmpty else { return showNoCards.toggle() }
											argument = arg
											showTimeTrial.toggle()
										} label: {
											Label("Play", systemImage: "arrowtriangle.forward.fill")
												.frame(width: 160, height: 50)
												.glassEffect(.regular.tint(.accentColor).interactive())
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
										showDepiction.toggle()
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
										showCard = true
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
										}
										.padding(EdgeInsets(top: 3, leading: 15, bottom: 3, trailing: 15))
										.contentShape(Rectangle())
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
							}
							Section { /// ``metadata``
								VStack(alignment: .leading) {
									Text(deck.createdAt, format: .dateTime.year().month().day())
									Text("\(deck.cards.count) cards")
									Text(deck.author)
									Text(Set(deck.cards.flatMap {[$0.frontLanguage, $0.backLanguage]}).sorted { $0.language < $1.language }.map { $0.language }.joined(separator: " ⋅ "))
										.font(.caption)
								}
								.foregroundStyle(.secondary)
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding()
							}
						} /// ``items``
					}
					.foregroundStyle(showGradientBackground && colors?.last != nil ? .white : .primary)
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
			.sheet(isPresented: $showEditDeck) {
				EditDeckView(title: "Edit Deck", deck: deck)
			}
			.sheet(isPresented: $showCardsToDeck) {
				CardsToDeck(deck: deck)
			}
			.alert("Delete Deck", isPresented: $showDeleteDeck) {
				Button("Remove", role: .destructive) {
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
			.alert("Downloading is not implemented yet.", isPresented: $showDownload) {
				Button("OK", role: .cancel) { }
			}
			.navigationBarBackButtonHidden(true)
		}
	}
}

/// Methods of DeckView.
fileprivate extension DeckView {
	
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
				if showGradientBackground, let color = colors?.last {
					color.mix(with: .white, amount: 0.4)
				}
			}
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
		}
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				Button {
					showEditDeck.toggle()
				} label: {
					Label("Edit Deck", systemImage: "slider.horizontal.3")
				}
				Button {
					showCardsToDeck.toggle()
				} label: {
					Label("Add cards", systemImage: "plus.square.fill.on.square.fill")
				}
				Button(role: .destructive) {
					showDeleteDeck.toggle()
				} label: {
					Label("Delete from Library", systemImage: "trash")
				}
			} label: {
				Image(systemName: "ellipsis")
			}
		}
	}
}

#Preview {
	
	@Previewable @State var deck = Deck(name: "Hello", image: "deck")
	@Previewable @Namespace var namespace
	
	DeckView(deck: deck, namespace: namespace)
		.environment(FileImageStorage())
}

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
	var namespace: Namespace.ID
	
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.dismiss) private var dismiss
	
	@State private var selectedCard: Card?
	@State private var showCard: Bool = false
	
	@State private var showToolbar: Bool = false
	@State private var showDepiction: Bool = false
	@State private var showCardsToDeck: Bool = false
	
	var body: some View {
		NavigationStack {
			ScrollViewReader { proxy in
				ScrollView {
					VStack {
						Image(image: deck.image, storage: storage)
							.resizable()
							.scaledToFill()
							.frame(width: 235, height: 235)
							.aspectRatio(1, contentMode: .fit)
							.clipShape(RoundedRectangle(cornerRadius: 8))
							.shadow(color: .black.opacity(0.3), radius: 15)
							.navigationTransition(.zoom(sourceID: deck.id, in: namespace))
						VStack(alignment: .center, spacing: 6) {
							Text(deck.name)
								.font(.system(size: 25, weight: .bold))
								.multilineTextAlignment(.center)
							Text(deck.author)
								.font(.title3)
								.foregroundStyle(.secondary)
						}
						.padding(.top, 18)
						.padding(.horizontal, 50)
						VStack(alignment: .center) {
							Text("\(deck.createdAt.formatted(.dateTime.year())) ⋅ " + Set(deck.cards.flatMap {[$0.frontLanguage, $0.backLanguage]}).sorted { $0.rawValue < $1.rawValue }.map { $0.rawValue }.joined(separator: " ⋅ "))
								.font(.system(size: 12, weight: .semibold))
								.foregroundStyle(.secondary)
						}
						.padding(.top, 1)
						Spacer()
						GlassEffectContainer {
							HStack(alignment: .center) {
								Button {
									//
								} label: {
									Image(systemName: "shuffle")
										.font(.system(size: 20, weight: .semibold))
										.frame(width: 50, height: 50)
										.glassEffect(.regular.tint(.secondary.opacity(0.2)).interactive())
								}
								Button {
									//
								} label: {
									Label("Play", systemImage: "arrowtriangle.forward.fill")
										.font(.system(size: 20, weight: .semibold))
										.frame(width: 150, height: 50)
										.glassEffect(.regular.tint(.accentColor).interactive())
								}
								Button {
									//
								} label: {
									Image(systemName: "arrow.down")
										.font(.system(size: 20, weight: .semibold))
										.frame(width: 50, height: 50)
										.glassEffect(.regular.tint(.secondary.opacity(0.2)).interactive())
								}
							}
						}
						.tint(.primary)
						.padding(.top, 10)
						VStack {
							Text(deck.depiction)
								.foregroundStyle(.secondary)
								.lineLimit(2)
								.multilineTextAlignment(.leading)
								.onTapGesture {
									showDepiction.toggle()
								}
								.sheet(isPresented: $showDepiction) {
									ScrollView {
										Text(deck.depiction)
											.padding(.vertical, 20)
											.padding(.horizontal, 20)
									}
								}
						}
						.padding(.horizontal)
						.padding(.top, 10)
						Divider()
							.padding(.horizontal)
						LazyVStack(alignment: .leading) {
							ForEach(deck.cards.indices, id: \.self) { index in
								let card = deck.cards[index]
								Button {
									selectedCard = card
									showCard = true
								} label: {
									HStack(spacing: 10) {
										Text("\(index + 1)")
											.font(.callout)
											.foregroundStyle(.secondary)
											.frame(width: 30, alignment: .center)
										VStack(alignment: .leading, spacing: 5) {
											Text(card.frontEntry)
												.font(.subheadline)
											Text(card.backEntry)
												.font(.subheadline)
												.foregroundStyle(.gray)
										}
										.frame(maxWidth: .infinity, alignment: .leading)
									}
									.padding(.vertical, 3)
									.padding(.horizontal, 15)
									.contentShape(Rectangle())
								}
								.buttonStyle(.plain)
								Divider()
									.padding(.horizontal)
							}
							.sheet(isPresented: $showCard) {
								if let card = selectedCard {
									CardView(card: card)
										.presentationDetents([.height(180)])
										.presentationBackgroundInteraction(.enabled)
								}
							}
						}
						VStack(alignment: .leading) {
							Text(deck.createdAt, format: .dateTime.year().month().day())
								.foregroundStyle(.secondary)
							Text("\(deck.cards.count) cards")
								.foregroundStyle(.secondary)
							Text("\(deck.author)")
								.foregroundStyle(.secondary)
							Text(Set(deck.cards.flatMap {[$0.frontLanguage, $0.backLanguage]}).sorted { $0.language < $1.language }.map { $0.language }.joined(separator: " ⋅ "))
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding()
					}
					.frame(maxWidth: .infinity)
					.padding(.top, 17)
				}
				.scrollIndicators(.hidden)
			}
			.toolbar { toolbar }
			.sheet(isPresented: $showCardsToDeck) {
				CardsToDeck(deck: deck)
			}
		}
	}
}

/// Toolbar.
private extension DeckView {
	
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
					showCardsToDeck.toggle()
				} label: {
					Label("Add cards", systemImage: "plus.square.fill.on.square.fill")
				}
			} label: {
				Image(systemName: "ellipsis")
			}
		}
	}
}

#Preview {
	DeckViewWrapper()
}

struct DeckViewWrapper: View {
	
	@State private var deck = Deck(name: "Hello", image: "deck")
	@Namespace private var namespace
	
	var body: some View {
		DeckView(deck: deck, namespace: namespace)
			.environment(FileImageStorage())
	}
}

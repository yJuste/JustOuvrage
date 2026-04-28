//
//  DeckView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/28/26.
//

import SwiftUI
import SwiftData

struct DeckView: View {
	
	@Binding var deck: Deck
	var namespace: Namespace.ID
	
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.dismiss) private var dismiss
	
	@State private var showToolbar: Bool = false
	@State private var showSheet: Bool = false
	@State private var showAddCards = false
	
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
							Text("Jules Longin")
								.font(.title3)
								.foregroundStyle(.secondary)
						}
						.padding(.top, 18)
						.padding(.horizontal, 50)
						VStack(alignment: .center) {
							Text("2024⋅en_US ↔ fr_FR")
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
									showSheet.toggle()
								}
						}
						.padding(.horizontal)
						.padding(.top, 10)
						if !deck.cards.isEmpty {
							Divider()
								.padding(.horizontal)
						}
						LazyVStack(alignment: .leading) {
							ForEach(deck.cards) { card in
								Button {
									//
								} label: {
									VStack(alignment: .leading, spacing: 5) {
										Text(card.frontEntry)
											.font(.subheadline)
										Text(card.backEntry)
											.font(.subheadline)
											.foregroundStyle(.gray)
									}
									.frame(maxWidth: .infinity, alignment: .leading)
									.padding(.vertical, 3)
									.padding(.horizontal, 15)
								}
								.buttonStyle(.plain)
								Divider()
									.padding(.horizontal)
							}
						}
					}
					.frame(maxWidth: .infinity)
					.padding(.top, 17)
				}
			}
			.toolbar { toolbar }
			.sheet(isPresented: $showSheet) {
				ScrollView {
					Text(deck.depiction)
						.padding(.vertical, 20)
						.padding(.horizontal, 20)
				}
			}
			.sheet(isPresented: $showAddCards) {
				CardsToDeck(deck: $deck)
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
					showAddCards.toggle()
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
		DeckView(deck: $deck, namespace: namespace)
			.environment(FileImageStorage())
	}
}

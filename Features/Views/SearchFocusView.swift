//
//  SearchFocusView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/20/26.
//

import SwiftUI
import SwiftData
import os // MARK: debug

/// A view that shows the focus state of the SearchView.
/// External Dependencies: Card, DisplayConfig
struct SearchFocusView: View {
	
	@Environment(\.isSearching) private var isSearching
	
	@Query(
		filter: #Predicate<Card> { $0.lastViewedAt != nil },
		sort: \Card.lastViewedAt,
		order: .reverse
	) private var recents: [Card]
	
	@Binding var search: String
	@State private var showClearAllAlert = false
	
	var body: some View {
		
		if isSearching && search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			Section {
				ForEach(recents.prefix(DisplayConfig.maxRecents)) { card in
					Button {
						Debug.print(level: .info, card: card)
					} label: {
						VStack(alignment: .leading, spacing: 5) {
							Text(card.frontEntry)
								.font(.subheadline)
							Text(card.backEntry)
								.font(.subheadline)
								.foregroundStyle(.gray)
						}
					}
					.swipeActions {
						Button {
							card.lastViewedAt = nil
						} label: {
							Label("Clear", systemImage: "xmark.circle.fill")
						}
					}
				}
			} header: {
				HStack {
					Text("Recently Searched")
					Spacer()
					Button {
						showClearAllAlert.toggle()
					} label: {
						Text("Clear All")
					}
					.disabled(recents.isEmpty)
				}
			}
			.alert("Clear recent searches?", isPresented: $showClearAllAlert) {
				Button("Clear All", role: .destructive) {
					recents.forEach {
						$0.lastViewedAt = nil
					}
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("This will clear all recent searches.")
			}
		}
	}
}

#Preview {
	NavigationStack {
		SearchFocusView(search: .constant(""))
			.searchable(text: .constant(""))
	}
}

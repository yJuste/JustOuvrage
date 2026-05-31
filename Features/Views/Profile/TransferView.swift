//
//  TransferView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/30/26.
//

import SwiftUI
import SwiftData

struct TransferView: View {
	
	@Environment(\.modelContext) private var context
	@Environment(Recording.self) private var recording
	@Environment(\.dismiss) private var dismiss
	
	@Query private var cards: [Card]
	
	@State private var exportURL: URL?
	@State private var selectedDeck: Deck?
	@State private var showDeckSelection = false
	@State private var showExporting = false
	@State private var showImporting = false
	@State private var showAddedBanner: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					Button {
						showDeckSelection = true
					} label: {
						HStack {
							Text("From Deck")
							Spacer()
							Text(selectedDeck?.name ?? "Every Card")
								.foregroundStyle(.secondary)
						}
					}
				}
				Section {
					Button("Export") {
						let exportedCards: [Card]
						if let deck = selectedDeck {
							exportedCards = deck.cards
						} else {
							exportedCards = cards
						}
						do {
							exportURL = try DataTransferObject.export(deck: selectedDeck, cards: exportedCards, recording: recording)
							showExporting = true
							//print("Export URL:", exportURL!)
						} catch {
							//print("Export error:", error)
						}
					}
					Button("Import") {
						showImporting = true
					}
				}
			}
			.overlay(alignment: .top) {
				if showAddedBanner {
					Label("Downloaded", systemImage: "checkmark.circle.fill")
						.environment(\.layoutDirection, .rightToLeft)
						.font(.subheadline.weight(.medium))
						.padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
						.background(Color.accentColor.opacity(0.8))
						.clipShape(Capsule())
						.transition(.move(edge: .top).combined(with: .opacity))
				}
			}
			.toolbar { toolbar }
			.navigationTitle("Transfer")
			.navigationBarTitleDisplayMode(.inline)
			.sheet(isPresented: $showDeckSelection) {
				DeckSelectionView(selectedDeck: $selectedDeck)
			}
			.sheet(isPresented: $showExporting) {
				if let exportURL {
					ShareSheet(items: [exportURL])
				}
			}
			.fileImporter(isPresented: $showImporting, allowedContentTypes: [.jtouvrage]) { result in
				
				guard let url = try? result.get() else { return }
				
				defer { if url.startAccessingSecurityScopedResource() { url.stopAccessingSecurityScopedResource() } }
				
				do {
					try DataTransferObject.import(from: url, context: context)
					Task { await showAdded() }
					print("Added")
				} catch {
					print("Import error:", error)
				}
			}
		}
	}
}

fileprivate extension TransferView {
	
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
fileprivate extension TransferView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				dismiss()
			} label: {
				Label("Close", systemImage: "xmark")
			}
			.tint(nil)
		}
	}
}

#Preview {
	TransferView()
}

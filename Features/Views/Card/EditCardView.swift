//
//  EditCardView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/2/26.
//

import SwiftUI
import SwiftData

struct EditCardView: View {
	
	let title: String
	let card: Card
	let onSave: (Card) -> Void
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@Bindable private var preferences: Preferences = .unique
	@FocusState private var focusField: FocusField?
	@State private var frontEntry: String = ""
	@State private var backEntry: String = ""
	@State private var frontLanguage: Language = Language.en_US
	@State private var backLanguage: Language = Language.en_US
	@State private var leitnerScore: Int = 1
	@State private var showFrontLanguage: Bool = false
	@State private var showBackLanguage: Bool = false
	@State private var showCancelAlert: Bool = false
	
	init(title: String, card: Card, onSave: @escaping (Card) -> Void = { _ in }) {
		self.title = title
		self.card = card
		self.onSave = onSave
		_frontEntry = State(initialValue: card.frontEntry)
		_backEntry = State(initialValue: card.backEntry)
		_frontLanguage = State(initialValue: card.frontLanguage)
		_backLanguage = State(initialValue: card.backLanguage)
		_leitnerScore = State(initialValue: card.leitnerScore)
	}
	
	private var selectedDeck: Binding<Deck?> {
		Binding {
			guard let id = preferences.selectDeck else { return nil }
			return decks.first(where: { $0.id == id })
		} set: { newDeck in
			preferences.selectDeck = newDeck?.id
		}
	}
	
	private var deckName: String {
		guard let id = preferences.selectDeck, let deck = decks.first(where: { $0.id == id }) else { return "Every Card" }
		return deck.name
	}
	
	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				ScrollViewReader { proxy in
					ScrollView {
						VStack {
							if title.localizedCaseInsensitiveContains("Add") {
								VStack {
									NavigationLink {
										DeckSelectionView(selectedDeck: selectedDeck)
									} label: {
										HStack {
											Text("Deck")
											Spacer()
											Text(deckName)
												.font(.footnote)
												.foregroundStyle(.secondary)
										}
										.padding()
									}
									.buttonStyle(.plain)
								}
								.background(.thinMaterial)
								.clipShape(RoundedRectangle(cornerRadius: 16))
								.padding(.horizontal, 25)
							}
							VStack(spacing: 40) {
								HStack(spacing: 40) {
									Button {
										showFrontLanguage.toggle()
									} label: {
										Image(frontLanguage.flagAsset)
											.resizable()
											.scaledToFill()
											.frame(width: 60, height: 60)
											.clipShape(Circle())
									}
									.popover(isPresented: $showFrontLanguage) {
										FlagPicker(selected: $frontLanguage)
											.padding(25)
											.presentationCompactAdaptation(.none)
									}
									Button {
										withAnimation(.spring(response: 0.3)) {
											(frontLanguage, backLanguage) = (backLanguage, frontLanguage)
										}
									} label: {
										Image(systemName: "arrow.left.arrow.right")
									}
									.buttonStyle(.plain)
									.padding()
									.glassEffect(.regular.interactive())
									Button {
										showBackLanguage.toggle()
									} label: {
										Image(backLanguage.flagAsset)
											.resizable()
											.scaledToFill()
											.frame(width: 60, height: 60)
											.clipShape(Circle())
									}
									.popover(isPresented: $showBackLanguage) {
										FlagPicker(selected: $backLanguage)
											.padding(20)
											.presentationCompactAdaptation(.none)
									}
								}
								VStack(spacing: 50) {
									SplendidField(title: "Front Entry", text: $frontEntry)
										.id(FocusField.front)
										.focused($focusField, equals: .front)
									SplendidField(title: "Back Entry", text: $backEntry)
										.id(FocusField.back)
										.focused($focusField, equals: .back)
								}
								if title.localizedCaseInsensitiveContains("Edit") {
									LabelTrailing(title: "Leitner Score") {
										Picker("Leitner Score", selection: $leitnerScore) {
											ForEach(1...7, id: \.self) { value in
												Text(value, format: .number)
													.tag(value)
											}
										}
										.pickerStyle(.navigationLink)
									}
								}
							}
							.padding(30)
						}
						.frame(maxWidth: .infinity, minHeight: geo.size.height * 0.95, alignment: .center)
					}
					.scrollDismissesKeyboard(.interactively)
					.scrollIndicators(.hidden)
					.onChange(of: focusField) {
						guard let field = focusField else { return }
						Task { @MainActor in
							try? await Task.sleep(for: .milliseconds(250))
							withAnimation {
								proxy.scrollTo(field, anchor: .top)
							}
						}
					}
				}
			}
			.onSubmit {
				if focusField == .front {
					focusField = .back
				}
			}
			.onTapGesture {
				focusField = nil
			}
			.toolbar { toolbar }
			.alert("Edit Card", isPresented: $showCancelAlert) {
				Button("Discard Changes", role: .destructive) {
					frontEntry = ""
					backEntry = ""
					leitnerScore = 1
					focusField = nil
					dismiss()
				}
				Button("Keep Editing", role: .cancel) { }
			} message: {
				Text("Are you sure you want to discard changes to this card?")
			}
		}
	}
}

/// Methods of EditCardView.
fileprivate extension EditCardView {
	
	private func editCard(front: String, back: String) {
		
		guard !front.isEmpty, !back.isEmpty else { return }
		
		card.frontEntry = front
		card.backEntry = back
		card.frontLanguage = frontLanguage
		card.backLanguage = backLanguage
		if leitnerScore != card.leitnerScore {
			Leitner.update(for: card, score: leitnerScore)
		}
		do {
			onSave(card)
			try modelContext.save()
		} catch {
			print(Errors.ModelContextError)
		}
	}
}

/// Toolbar.
fileprivate extension EditCardView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		let frontEntry = frontEntry.trimmingCharacters(in: .whitespacesAndNewlines)
		let backEntry = backEntry.trimmingCharacters(in: .whitespacesAndNewlines)
		ToolbarItem(placement: .topBarLeading) {
			Button {
				if frontEntry == card.frontEntry
					&& backEntry == card.backEntry {
					dismiss()
				} else {
					showCancelAlert.toggle()
				}
			} label: {
				Text("Cancel")
			}
			.tint(nil)
		}
		ToolbarItem(placement: .principal) {
			Text(title)
				.font(.headline)
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				editCard(front: frontEntry, back: backEntry)
				dismiss()
			} label: {
				Label("Done", systemImage: "checkmark")
			}
			.buttonStyle(.borderedProminent)
			.disabled(frontEntry.isEmpty || backEntry.isEmpty
			)
		}
	}
}

#Preview {
	
	EditCardView(
		title: "Add Card To Library",
		card: Card(
			frontEntry: "hello my na🇺🇸m on, l, l,",
			backEntry: ",,,bonjour,,,,",
			frontLanguage: .en_US,
			backLanguage: .fr_CA
		),
		onSave: { _ in }
	)
}

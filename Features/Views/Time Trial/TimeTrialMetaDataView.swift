//
//  TimeTrialMetaDataView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/24/26.
//

import SwiftUI

struct TimeTrialMetaDataView: View {
	
	let timeTrial: TimeTrial
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					HStack {
						Text("Date")
							.foregroundStyle(.secondary)
						Spacer()
						Text("\(timeTrial.createdAt, format: .dateTime.year().month().day().hour().minute())")
					}
					HStack {
						Text("On Deck")
							.foregroundStyle(.secondary)
						Spacer()
						Text("\(timeTrial.deck?.name ?? "Every Card")")
					}
					HStack {
						Text("Mode")
							.foregroundStyle(.secondary)
						Spacer()
						Text(timeTrial.mode.mode)
					}
					HStack {
						Text("Success")
							.foregroundStyle(.secondary)
						Spacer()
						Text("\((timeTrial.success), format: .percent.precision(.fractionLength(0...2)))")
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()
			}
			.toolbar { toolbar }
			.navigationTitle("Metadata")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

/// Toolbar.
fileprivate extension TimeTrialMetaDataView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				dismiss()
			} label: {
				Label("Close", systemImage: "xmark")
			}
		}
	}
}

#Preview {
	
	let cards: [Card] = [Card(frontEntry: "FrontEntry", backEntry: "BackEntry", frontLanguage: .fr_CA, backLanguage: .en_GB)]
	
	let deck = Deck(name: "Title deck", image: "deck")
	let res: [SwipeDirection] = [.left, .right, .right]
	
	let argument = Argument.make(deck: deck, cards: cards, mode: .chill, directions: res, timeInterval: 4.0, order: .alphabeticalAscending, numberOfCards: 30)
	
	TimeTrialMetaDataView(timeTrial: TimeTrial(argument: argument, with: 0.348))
}

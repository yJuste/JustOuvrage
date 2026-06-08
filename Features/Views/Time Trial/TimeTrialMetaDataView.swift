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
					LeadingLabel(title: "Date") {
						Text(timeTrial.createdAt, format: .dateTime.year().month().day().hour().minute())
					}
					LeadingLabel(title: "On Deck") {
						Text(timeTrial.deck?.name ?? "Every Card")
					}
					LeadingLabel(title: "Mode") {
						Text(timeTrial.mode.mode)
					}
					LeadingLabel(title: "Success") {
						Text(timeTrial.success, format: .percent.precision(.fractionLength(0...2)))
					}
					LeadingLabel(title: "Language") {
						Text(
							Set(timeTrial.cards.flatMap { [$0.frontLanguage, $0.backLanguage] }).sorted().map(\.language).joined(separator: " ⋅ ")
						)
						.font(.caption)
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
			.tint(nil)
		}
	}
}

#Preview {
	
	let cards: [Card] = [Card(frontEntry: "FrontEntry", backEntry: "BackEntry", frontLanguage: .fr_CA, backLanguage: .en_GB, author: "yJuste")]
	
	let res: [SwipeDirection] = [.left, .right, .right]
	
	let argument = Argument.make(deck: nil, cards: cards, side: .front, mode: .chill, directions: res, timeInterval: 4.0, order: .alphabeticalAscending, numberOfCards: 30, languages: Language.allCases, languageFilter: .atLeastOne)
	
	TimeTrialMetaDataView(timeTrial: TimeTrial(argument: argument, with: 0.348))
}

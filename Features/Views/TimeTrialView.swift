//
//  TimeTrialView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/7/26.
//

import SwiftUI

struct TimeTrialView: View {
	
	let cards: [Card]
	
	var body: some View {
		List(cards) { card in
			Text(card.frontEntry)
		}
	}
}

//
//  CardView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/27/26.
//

import SwiftUI

struct CardView: View {
	
	@Binding var card: Card
	@State private var showSafariExtension: Bool = false
	
	var body: some View {
		NavigationStack {
			ScrollViewReader { proxy in
				ScrollView {
					VStack(alignment: .leading) {
						HStack {
							Spacer()
							Text("\(card.frontLanguage.language)")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						Text("\(card.frontEntry)")
						HStack {
							Spacer()
							Text("\(card.backLanguage.language)")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						Text("\(card.backEntry)")
						HStack {
							Spacer()
							Text("Leitner Score")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						Picker("Leitner Score", selection: $card.leitnerScore) {
							ForEach(1...7, id: \.self) { value in
								Text("\(value)")
									.tag(value)
							}
						}
						.pickerStyle(.segmented)
						HStack {
							Button {
								showSafariExtension.toggle()
							} label: {
								Text("Forvo")
									.font(.system(size: 15, weight: .medium))
									.padding(.vertical, 10)
									.padding(.horizontal, 10)
									.glassEffect(.regular.interactive())
							}
							Button {
								showSafariExtension.toggle()
							} label: {
								Text("Word Reference")
									.font(.system(size: 15, weight: .medium))
									.padding(.vertical, 10)
									.padding(.horizontal, 10)
									.glassEffect(.regular.interactive())
							}
							Button {
								showSafariExtension.toggle()
							} label: {
								Text("Google")
									.font(.system(size: 15, weight: .medium))
									.padding(.vertical, 10)
									.padding(.horizontal, 10)
									.glassEffect(.regular.interactive())
							}
						}
						.buttonStyle(.plain)
					}
					.padding()
				}
			}
			.fullScreenCover(isPresented: $showSafariExtension) {
				SFSafariViewWrapper(url: URL(string: "https://www.google.com/search?q=drip+definition&hl=en&gl=us")!)
			}
		}
	}
}

#Preview {
	CardPreviewWrapper()
}

struct CardPreviewWrapper: View {
	
	@State private var card = Card(
		frontEntry: "hello",
		backEntry: "bonjour",
		frontLanguage: .en_US,
		backLanguage: .fr_CA
	)
	
	var body: some View {
		CardView(card: $card)
	}
}

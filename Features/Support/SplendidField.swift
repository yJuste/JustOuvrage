//
//  SplendidField.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

import SwiftUI

/// A nice-looking custom TextField.
struct SplendidField: View {
	
	let title: String
	@Binding var text: String
	
	@Bindable private var preferences: Preferences = .unique
	@FocusState var isTyping: Bool
	
	private let rectangle: RoundedRectangle = RoundedRectangle(cornerRadius: 14, style: .continuous)
	
	var body: some View {
		ZStack(alignment: .leading) {
			let color = preferences.globalColor.color
			TextField("", text: $text)
				.padding(.horizontal, 14)
				.frame(height: 55)
				.focused($isTyping)
				.background(isTyping ? color : Color.primary, in: rectangle.stroke(lineWidth: 2))
			Text(title)
				.padding(EdgeInsets(top: -3, leading: 5, bottom: -3, trailing: 5))
				.background(rectangle.fill(Color(.systemBackground).opacity(isTyping || !text.isEmpty ? 1 : 0)))
				.foregroundStyle(isTyping ? color : Color.secondary)
				.padding(.leading)
				.offset(y: isTyping || !text.isEmpty ? -27 : 0)
		}
		.animation(.easeOut(duration: 0.15), value: isTyping)
		.onTapGesture {
			isTyping.toggle()
		}
	}
}

#Preview {
	
	@Previewable @State var name: String = ""
	SplendidField(title: "Name", text: $name)
}

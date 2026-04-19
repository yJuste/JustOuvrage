//
//  SplendidField.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

import SwiftUI

/// A nice looking custom TextField.
struct SplendidField: View {
	
	let title: String
	@Binding var text: String
	@FocusState private var isTyping: Bool
	let shape = RoundedRectangle(cornerRadius: 14)
	
	var body: some View {
		ZStack(alignment: .leading) {
			TextField("", text: $text)
				.padding(.horizontal, 14)
				.frame(height: 55)
				.focused($isTyping)
				.background(
					isTyping ? Color.accentColor : Color.primary, in: shape.stroke(lineWidth: 2)
				)
			Text(title)
				.padding(.horizontal, 5)
				.padding(.vertical, -3)
				.background(
					shape.fill(Color(.systemBackground).opacity(isTyping || !text.isEmpty ? 1 : 0))
				)
				.foregroundStyle(isTyping ? Color.accentColor : Color.primary)
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

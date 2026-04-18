//
//  Entry.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

import SwiftUI

/// A view that represents a custom TextField
struct Entry: View {
	
	let title: String
	@Binding var text: String
	@FocusState var isTyping: Bool
	
	var body: some View {
		ZStack(alignment: .leading) {
			TextField("", text: $text).padding(.leading)
				.frame(height: 55).focused($isTyping)
				.background(
					isTyping
					? Color.accentColor
					: Color.primary, in: RoundedRectangle(cornerRadius: 14).stroke(lineWidth: 2)
				)
			Text(title).padding(.horizontal, 5)
				.background(Color(.systemBackground).opacity(isTyping || !text.isEmpty ? 1 : 0))
				.foregroundStyle(isTyping ? Color.accentColor : Color.primary)
				.padding(.leading).offset(y: isTyping || !text.isEmpty ? -27 : 0)
				.onTapGesture {
					isTyping.toggle()
				}
		}
		.animation(.linear(duration: 0.2), value: isTyping)
	}
}

#Preview {
	@Previewable @State var name: String = ""
	Entry(title: "Name", text: $name)
}

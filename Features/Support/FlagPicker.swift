//
//  FlagPicker.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/19/26.
//

import SwiftUI

/// A custom button to select languages.
/// External Dependencies: Language
struct FlagPicker: View {
	
	@Binding var selected: Language
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		ScrollView {
			VStack(spacing: 12) {
				ForEach(Language.allCases, id: \.self) { language in
					Button {
						selected = language
						dismiss()
					} label: {
						HStack(spacing: 10) {
							Image(language.flagAsset)
								.resizable()
								.scaledToFit()
								.frame(width: 28, height: 24)
							Text(language.language)
								.foregroundStyle(.primary)
							Spacer()
						}
					}
					.buttonStyle(.plain)
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#Preview {
	
	struct FlagPickerWrapper: View {
		
		@State private var language: Language = .es_ES
		
		var body: some View {
			FlagPicker(selected: $language)
		}
	}
	return FlagPickerWrapper()
}

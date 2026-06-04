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
	
	@State private var recentLanguages = Array(Preferences.unique.recentLanguages.prefix(10))
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				if !recentLanguages.isEmpty {
					Text("Recently Used")
						.foregroundStyle(.secondary)
					ForEach(recentLanguages, id: \.self) { language in
						Button {
							registerLanguageSelection(language)
							selected = language
							dismiss()
						} label: {
							HStack(spacing: 10) {
								Image(language.flagAsset)
									.resizable()
									.scaledToFill()
									.frame(width: 28, height: 24)
								Text(language.language)
									.foregroundStyle(.primary)
								Spacer()
							}
						}
						.buttonStyle(.plain)
					}
					Divider()
				}
				Text("All")
					.foregroundStyle(.secondary)
				ForEach(Language.allCases, id: \.self) { language in
					Button {
						registerLanguageSelection(language)
						selected = language
						dismiss()
					} label: {
						HStack(spacing: 10) {
							Image(language.flagAsset)
								.resizable()
								.scaledToFill()
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

fileprivate extension FlagPicker {
	
	func registerLanguageSelection(_ language: Language) {
		var updated = recentLanguages.filter { $0 != language }
		updated.insert(language, at: 0)
		let recent = Array(updated.prefix(10))
		Preferences.unique.recentLanguages = recent
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

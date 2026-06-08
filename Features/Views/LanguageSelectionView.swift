//
//  LanguageSelectionView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/8/26.
//

import SwiftUI

struct LanguageSelectionView: View {
	
	@Binding var selectedLanguages: [Language]
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var searchText = ""
	
	private var filteredLanguages: [Language] {
		Language.allCases.sorted().filter { searchText.isEmpty || $0.language.localizedCaseInsensitiveContains(searchText) }
	}
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(filteredLanguages, id: \.self) { language in
					Button {
						toggle(language)
					} label: {
						HStack {
							Text(language.language)
								.foregroundStyle(Color(.label))
							Spacer()
							if selectedLanguages.contains(language) {
								Image(systemName: "checkmark")
							}
						}
					}
				}
			}
			.navigationTitle("Languages")
			.searchable(text: $searchText, prompt: "Search a language")
		}
	}
}

fileprivate extension LanguageSelectionView {
	
	private func toggle(_ language: Language) {
		if selectedLanguages.contains(language) {
			selectedLanguages.removeAll { $0 == language }
		} else {
			selectedLanguages.append(language)
		}
	}
}

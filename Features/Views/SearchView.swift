//
//  SearchView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/20/26.
//

import SwiftUI

/// A view that shows the search scene.
struct SearchView: View {
	
	@Binding var search: String
	
	var body: some View {
		NavigationStack {
			List {
				//
			}
			.navigationTitle("Search")
			.searchable(text: $search, placement: .toolbar)
		}
	}
}

#Preview {
	
	struct SearchPreview: View {
		@State var search: String = ""
		var body: some View {
			SearchView(search: $search)
		}
	}
	return SearchPreview()
}

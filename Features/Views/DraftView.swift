//
//  DraftView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/3/26.
//

import SwiftUI

/// A view that displays a draft card.
struct DraftView: View {
	
	let draft: Draft
	
	var body: some View {
		Text("Entry for draft: \(draft.entry)")
	}
}

#Preview {
	
	@Previewable @State var draft = Draft(entry: "I want you.", language: .en_US)
	
	DraftView(draft: draft)
}

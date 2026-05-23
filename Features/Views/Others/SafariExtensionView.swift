//
//  SafariExtensionView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/16/26.
//

import SwiftUI

/// A view that can browse in Safari.
/// External Dependencies: SFSafariViewWrapper
struct SafariExtensionView: View {
	
	@State private var showSafariExtension: Bool = false
	
	var body: some View {
		Text("Open Design+Code in Safari")
			.padding()
			.onTapGesture {
				showSafariExtension.toggle()
			}
			.fullScreenCover(isPresented: $showSafariExtension, content: {
				//SFSafariViewWrapper(url: URL(string: "https://www.google.com/search?q=tabarnak+pronunciation&hl=fr&gl=CA")!)
				//SFSafariViewWrapper(url: URL(string: "https://forvo.com/word/teen/#en_usa")!)
				SFSafariViewWrapper(url: URL(string: "https://www.google.com/search?q=drip+definition&hl=en&gl=us")!)
				//SFSafariViewWrapper(url: URL(string: "https://www.wordreference.com/enfr/get%20off")!)
			})
	}
}

#Preview {
	
	struct SafariExtensionPreview: View {
		
		@State var showSafariExtension: Bool = false
		
		var body: some View {
			SafariExtensionView()
		}
	}
	return SafariExtensionPreview()
}

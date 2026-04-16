//
//  SFSafariViewWrapper.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/16/26.
//

import SwiftUI
import SafariServices

/// A built-in Safari browser.
struct SFSafariViewWrapper: UIViewControllerRepresentable {
	
	let url: URL
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
		SFSafariViewController(url: url)
	}

	func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {}
}

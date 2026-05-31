//
//  ShareSheet.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/30/26.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
	
	let items: [Any]
	
	func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: items, applicationActivities: nil) }
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

//
//  MoreInformationsView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/27/26.
//

import SwiftUI

struct MoreInformationsView: View {
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					Label("Downloading / Data Export", systemImage: "1.circle")
				} footer: {
					Text("Since downloading and data export are not implemented yet, all data, without any exception, will be permanently deleted if or when the app is removed.")
				}
				Section {
					Label("Sessions", systemImage: "2.circle")
				} footer: {
					Text("Future updates will include sessions to create your own website links as well as your own languages.")
				}
				Section {
					Label("Optimization", systemImage: "3.circle")
				} footer: {
					Text("Optimizations are regularly included in patches. If you experience stability or performance issues, lower the settings to the minimum.")
				}
				Section {
					Label("Bugs", systemImage: "4.circle")
				} footer: {
					Text("If you encounter any bugs in the application, feel free to report them to the provided email address.")
				}
				Section {
					Label("About Me", systemImage: "5.circle")
				} footer: {
					Text("""
First of all, it’s a great honor that you are using this flashcard/dictionary application.

This app was originally designed for my personal needs because I felt it was important to have an app like this for language learning, allowing me to store every learned word and track progress in real time.

That’s also why the application is completely free. If you enjoy it, feel free to leave your feedback.
""")
				}
				Text("For more information, feel free to contact: [No mail yet]")
			}
			//.toolbar { toolbar }
			.navigationTitle("More Informations")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

/// Toolbar.
fileprivate extension MoreInformationsView {
	
//	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
//		//
//	}
}

#Preview {
	MoreInformationsView()
}

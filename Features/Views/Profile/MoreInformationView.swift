//
//  MoreInformationView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/4/26.
//

import SwiftUI

struct MoreInformationView: View {
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					Label("Data", systemImage: "1.circle")
				} footer: {
					Text("""
All data will be permanently deleted when the app is uninstalled.

You can export your cards and decks at any time; this will generate a .jtouvrage bundle.
""")
				}
				Section {
					Label("Session", systemImage: "2.circle")
				} footer: {
					Text("""
Upcoming updates will introduce sessions for creating your own website links and custom languages.
""")
				}
				Section {
					Label("Optimization", systemImage: "3.circle")
				} footer: {
					Text("Optimizations are regularly included in patches. If you experience performance issues, lower the settings to the minimum.")
				}
				Section {
					Label("Bug", systemImage: "4.circle")
				} footer: {
					Text("If you encounter any bugs in the application, feel free to report them to the provided email address.")
				}
				Section {
					Label("About Me", systemImage: "5.circle")
				} footer: {
					Text("""
This app was originally designed for my personal needs because I felt it was important to have an app like this, allowing me to store every learned word and track progress in real time.

That's also why the application is completely free. If you enjoy it, feel free to leave your feedback.
""")
				}
				Text("For more information, contact: [jules.longin1@gmail.com]")
			}
			.navigationTitle("More Information")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	MoreInformationView()
}

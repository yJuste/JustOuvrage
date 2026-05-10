//
//  ProfileView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/6/26.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var showLogOut: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					NavigationLink {
						//
					} label: {
						HStack(spacing: 12) {
							Image(.anna)
								.resizable()
								.scaledToFill()
								.frame(width: 58, height: 58)
								.clipShape(Circle())
							VStack(alignment: .leading, spacing: 2) {
								Text("Hello")
									.font(.system(size: 15, weight: .regular, design: .default))
								Text("My friend")
									.font(.system(size: 15, weight: .regular, design: .default))
									.foregroundStyle(.secondary)
							}
							Spacer()
						}
					}
				} footer: {
					Text("Your Just Account provides a unique identifier that connects you across all Just Anthology productions.")
				}
				Section {
					NavigationLink {
						SettingsView()
					} label: {
						Label("Settings", systemImage: "gear")
					}
				} footer: {
					Text("Manage your app preferences, maintenance tools, and data-related settings.")
				}
				Section {
					Button {
						showLogOut.toggle()
					} label: {
						Text("Log out")
					}
				}
			}
			.toolbar { toolbar }
			.alert("Log out", isPresented: $showLogOut) {
				Button("Log out", role: .destructive) { dismiss() }
				Button("Cancel", role: .cancel) {}
			} message: {
				Text("Are you sure you want to log out to your account?")
			}
		}
	}
}

/// Toolbar.
fileprivate extension ProfileView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				dismiss()
			} label: {
				Label("Close", systemImage: "xmark")
			}
		}
		ToolbarItem(placement: .principal) {
			Text("Just Account")
				.font(.headline)
				.foregroundStyle(.secondary)
		}
	}
}

#Preview {
	ProfileView()
}

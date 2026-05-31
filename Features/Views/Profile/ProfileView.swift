//
//  ProfileView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/6/26.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
	
	let profile: ImageResource
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var color: Color = Preferences.unique.globalColor.color
	@State private var showLogOut: Bool = false
	@State private var showTransfer: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					NavigationLink {
						AccountView()
					} label: {
						HStack(spacing: 12) {
							Image(profile)
								.resizable()
								.scaledToFill()
								.frame(width: 58, height: 58)
								.clipShape(Circle())
							VStack(alignment: .leading, spacing: 2) {
								Text("Hello")
								Text("My friend")
									.foregroundStyle(.secondary)
							}
							.font(.system(size: 15))
							Spacer()
						}
					}
				} footer: {
					Text("Your Just Account provides a unique identifier that connects you across all Just Anthology productions.")
				}
				Section {
					Button {
						showTransfer = true
					} label: {
						Label {
							Text("Share or Receive")
						} icon: {
							Image(systemName: "square.and.arrow.up.on.square")
								.foregroundStyle(color)
						}
					}
				} footer: {
					Text("Import or export decks and cards to share them or transfer them between devices.")
				}
				Section {
					NavigationLink {
						SettingsView()
					} label: {
						Label {
							Text("Settings")
						} icon: {
							Image(systemName: "gear")
								.foregroundStyle(color)
						}
					}
				} footer: {
					Text("Manage your app preferences, maintenance tools, and data-related settings.")
				}
				Section {
					NavigationLink {
						MoreInformationsView()
					} label: {
						Text("More informations")
					}
				} footer: {
					Text("")
				}
				Section {
					Button {
						showLogOut.toggle()
					} label: {
						Text("Log out")
					}
				}
			}
			.onAppear {
				Appearance.configurePicker()
			}
			.sheet(isPresented: $showTransfer) {
				TransferView()
					.presentationDetents([
						.fraction(Constants.heightOfATransfer[0]),
						.fraction(Constants.heightOfATransfer[1])
					])
					.presentationBackgroundInteraction(.enabled)
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
			.tint(nil)
		}
		ToolbarItem(placement: .principal) {
			Text("Just Account")
				.font(.headline)
		}
	}
}

#Preview {
	ProfileView(profile: .wall)
}

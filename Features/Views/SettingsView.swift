//
//  SettingsView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/16/26.
//

import SwiftUI

/// A view that shows all the settings.
struct SettingsView: View {
	
	@State private var preferences = Preferences.unique
	
	var body: some View {
		VStack {
			Text("Test UserDefaults")
			Text(preferences.frontLanguage.rawValue)
			Button("Switch to FR") {
				preferences.frontLanguage = .fr_FR
			}
			Button("Switch to ES") {
				preferences.frontLanguage = .es_ES
			}
		}
	}
}

#Preview {
	SettingsView()
}

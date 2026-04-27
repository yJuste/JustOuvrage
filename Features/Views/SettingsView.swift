//
//  SettingsView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/16/26.
//

import SwiftUI

/// A view that shows all the settings.
struct SettingsView: View {
	
	var body: some View {
		NavigationStack {
			ScrollViewReader { proxy in
				ScrollView {
					VStack {
						Text("Settings")
					}
				}
			}
		}
	}
}

#Preview {
	SettingsView()
}

//
//  ContentView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftUI
import SwiftData

/// The main View where everything comes through.
/// External Dependencies: Card, HomeView, SafariExtensionView, SettingsView
struct ContentView: View {
	
	var body: some View {
		
		if #available(iOS 26, *) {
			NativeTabView()
				//.tabViewBottomAccessory { EmptyView() }
		} else {
			NativeTabView()
		}
	}
}

/// An extension that creates the native tab view nowadays. (iOS 26.4.1)
extension ContentView {
	
	@ViewBuilder func NativeTabView() -> some View {
		
		TabView {
			Tab("New", systemImage: "plus.rectangle.portrait") {
				NewCardView()
			}
			Tab("Trial", systemImage: "flag.pattern.checkered.2.crossed") {
				EmptyView()
			}
			Tab("Record", systemImage: "rectangle.dashed.badge.record") {
				EmptyView()
			}
			Tab("Library", systemImage: "rectangle.stack.fill") {
				LibraryView()
			}
			Tab(role: .search) {
				SearchView()
			}
		}
		//.tabBarMinimizeBehavior(.onScrollDown)
	}
}

#Preview {
    ContentView()
}

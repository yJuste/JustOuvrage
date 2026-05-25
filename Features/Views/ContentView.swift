//
//  ContentView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftUI
import SwiftData

/// The main View where everything comes through.
/// External Dependencies: NewCardView, LibraryView, SearchView
struct ContentView: View {
	
	@Environment(Navigation.self) private var navigation
	
	@Bindable private var preferences: Preferences = .unique
	
	var body: some View {
		if #available(iOS 26, *) {
			NativeTabView()
			//.tabViewBottomAccessory { EmptyView() }
		} else {
			NativeTabView()
		}
	}
}

/// An extension that creates the native tab view nowadays. (iOS 26.5)
fileprivate extension ContentView {
	
	@ViewBuilder private func NativeTabView() -> some View {
		TabView(selection: Bindable(navigation).selectedTab) {
			Tab("New", systemImage: "plus.rectangle.portrait", value: .new) {
				NewCardView()
			}
			Tab("Trial", systemImage: "flag.pattern.checkered.2.crossed", value: .trial) {
				TimeTrialSetupView()
			}
			Tab("Session", systemImage: "rectangle.dashed.badge.record", value: .session) {
				SessionView()
			}
			Tab("Library", systemImage: "rectangle.stack.fill", value: .library) {
				LibraryView()
			}
			Tab(value: .search, role: .search) {
				SearchView()
			}
		}
		.onChange(of: navigation.selectedTab) { _, newValue in
			preferences.tabBar = newValue
		}
		.onAppear {
			navigation.selectedTab = preferences.tabBar
		}
		//.tabBarMinimizeBehavior(.onScrollDown)
	}
}

@Observable final class Navigation {
	
	var selectedTab: TabBar = .new
}

#Preview {
	ContentView()
		.environment(FileImageStorage())
}

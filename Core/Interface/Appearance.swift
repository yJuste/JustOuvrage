//
//  Appearance.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/3/26.
//

import SwiftUI

/// Configures the global UI appearance across the App.
enum Appearance {
	
	/// Applies a `default picker appearance` globally.
	///
	/// ## Example
	/// ```swift
	/// struct App: App {
	///		init() {
	///			View.configurePicker()
	///		}
	/// }
	/// ```
	static func configurePicker() {
		
		let appearance = UISegmentedControl.appearance()
		let font = UIFont.boldSystemFont(ofSize: 12)
		let accent = UIColor(Color.accentColor)
		
		appearance.selectedSegmentTintColor = accent.withAlphaComponent(0.75)
		
		appearance.setTitleTextAttributes([
			.font: font,
			.foregroundColor: accent
		], for: .normal)
		
		appearance.setTitleTextAttributes([
			.font: font,
			.foregroundColor: UIColor.label
		], for: .selected)
	}
}

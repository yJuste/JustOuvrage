//
//  PickerView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/26/26.
//

import SwiftUI

/// Configure the looking of Picker().segmented.
enum PickerView {
	
	static func configure() {
		
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

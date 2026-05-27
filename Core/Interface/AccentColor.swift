//
//  AccentColor.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/27/26.
//

import SwiftUI

enum AccentColor: String, CaseIterable {
	
	case red
	case orange
	case yellow
	case green
	case mint
	case teal
	case cyan
	case blue
	case indigo
	case purple
	case pink
	case brown
	case gray
	
	// Assets
	case accent
	
	var color: Color {
		switch self {
		case .red: .red
		case .orange: .orange
		case .yellow: .yellow
		case .green: .green
		case .mint: .mint
		case .teal: .teal
		case .cyan: .cyan
		case .blue: .blue
		case .indigo: .indigo
		case .purple: .purple
		case .pink: .pink
		case .brown: .brown
		case .gray: .gray
			// Assets
		case .accent: Color(.accent)
		}
	}
}

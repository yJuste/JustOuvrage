//
//  ColorExtension.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/25/26.
//

import SwiftUI

extension Color {
	
	func mix(with color: Color, amount: CGFloat) -> Color {
		
		let uiColor1 = UIColor(self)
		let uiColor2 = UIColor(color)
		var r1: CGFloat = 0
		var g1: CGFloat = 0
		var b1: CGFloat = 0
		var a1: CGFloat = 0
		var r2: CGFloat = 0
		var g2: CGFloat = 0
		var b2: CGFloat = 0
		var a2: CGFloat = 0
		
		uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
		uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
		
		return Color(red: r1 + (r2 - r1) * amount, green: g1 + (g2 - g1) * amount, blue: b1 + (b2 - b1) * amount, opacity: a1 + (a2 - a1) * amount)
	}
}

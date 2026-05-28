//
//  AccentColor.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/27/26.
//

import SwiftUI

enum AccentColor: String, CaseIterable {
	
	case sienna
	case steelBlue
	case darkSapphire
	case cherry
	case eminence
	case mountBattenRose
	case firGreen
	case asparagus
	case peacockBlue
	
	var color: Color {
		switch self {
		case .sienna: Color(.sienna)
		case .steelBlue: Color(.steelBlue)
		case .darkSapphire: Color(.darkSapphire)
		case .cherry: Color(.cherry)
		case .eminence: Color(.eminence)
		case .mountBattenRose: Color(.mountbattenRose)
		case .firGreen: Color(.firGreen)
		case .asparagus: Color(.asparagus)
		case .peacockBlue: Color(.peacockBlue)
		}
	}
}

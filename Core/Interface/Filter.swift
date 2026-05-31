//
//  Filter.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

enum LanguageFilter: Int, CaseIterable {
	
	case atLeastOne
	case justOne
	case needBoth
	
	var title: String {
		switch self {
		case .atLeastOne: "At Least One"
		case .justOne: "Just One"
		case .needBoth: "Need Both"
		}
	}
	
	var icon: String {
		switch self {
		case .atLeastOne: "square.3.layers.3d.top.filled"
		case .justOne: "square.3.layers.3d.middle.filled"
		case .needBoth: "square.3.layers.3d.bottom.filled"
		}
	}
}

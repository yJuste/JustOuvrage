//
//  ArrayExtension.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/26/26.
//

import SwiftUI

extension Array where Element == Binding<Bool> {
	
	func setAll(to value: Bool) {
		forEach { $0.wrappedValue = value }
	}
	
	func showOnly(_ item: Binding<Bool>) {
		setAll(to: false)
		item.wrappedValue = true
	}
	
	func toggleOnly(_ item: Binding<Bool>) {
		let newValue = !item.wrappedValue
		setAll(to: false)
		item.wrappedValue = newValue
	}
}

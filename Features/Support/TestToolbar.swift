//
//  TestToolbar.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/17/26.
//

import SwiftUI

struct TestToolbar: View {
	@State private var givenName: String = ""
	@State private var familyName: String = ""
	
	
	var body: some View {
		VStack {
			TextField(
				"Given Name",
				text: $givenName
			)
			.disableAutocorrection(true)
			TextField(
				"Family Name",
				text: $familyName
			)
			.disableAutocorrection(true)
		}
		.textFieldStyle(.roundedBorder)
	}
}

#Preview {
	TestToolbar()
}

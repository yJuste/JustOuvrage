//
//  Two.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/21/26.
//

import SwiftUI

struct Two: View {
	
	@State private var selection = 0
	
	var body: some View {
		
		VStack {
			Picker("", selection: $selection) {
				Text("Left")
					.tag(0)
				Text("Right")
					.tag(1)
			}
			.pickerStyle(.segmented)
			.padding(.horizontal, 15)
			if selection == 0 {
				HomeView()
			} else {
				NewDeckView()
			}
		}
	}
}

#Preview {
	Two()
}

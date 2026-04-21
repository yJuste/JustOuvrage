//
//  FocusModifierViewTest.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/20/26.
//

import SwiftUI

//struct FocusModifierViewTest: View {
//	
//	enum FocusedField {
//		case username, password
//	}
//	
//	@FocusState private var focusedField: FocusedField?
//	@State private var username = "Anonymous"
//	@State private var password = "sekrit"
//	
//	var body: some View {
//		VStack {
//			
//			SplendidField(
//				title: "Username",
//				text: $username,
//				focusedField: $focusedField,   // 👈 ça marche
//				equals: .username
//			)
//			
//			SplendidField(
//				title: "Password",
//				text: $password,
//				focusedField: $focusedField,
//				equals: .password
//			)
//		}
//		.onSubmit {
//			if focusedField == .username {
//				focusedField = .password
//			} else {
//				focusedField = nil
//			}
//		}
//	}
//}

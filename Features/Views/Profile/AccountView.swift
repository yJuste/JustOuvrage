//
//  AccountView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/26/26.
//

import SwiftUI

struct AccountView: View {
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			ScrollView {
				Text("Not available yet.")
			}
			//.toolbar { toolbar }
			.navigationTitle("Account")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

/// Toolbar.
fileprivate extension AccountView {
	
//	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
//		//
//	}
}


#Preview {
	AccountView()
}

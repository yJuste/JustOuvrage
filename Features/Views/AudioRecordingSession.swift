//
//  AudioRecordingSession.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/19/26.
//

import SwiftUI

struct AudioRecordingSession: View {
	
	let id: UUID
	let namespace: Namespace.ID
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 16) {
					Image(.yellowflower)
						.resizable()
						.scaledToFill()
						.frame(height: 300)
						.navigationTransition(id: id, namespace: namespace)
				}
			}
			.ignoresSafeArea(edges: .top)
		}
	}
}

#Preview {
	@Previewable @Namespace var namespace
	AudioRecordingSession(id: UUID(), namespace: namespace)
}

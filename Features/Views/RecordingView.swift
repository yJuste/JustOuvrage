//
//  RecordingView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/21/26.
//

import SwiftUI
import AVFoundation

struct RecordingView: View {
	
	let card: Card
	
	@Environment(Recording.self) private var storage
	@Environment(\.dismiss) private var dismiss
	
	@State private var recordingFront = false
	@State private var recordingBack = false
	@State private var activeRecording: Side?
	@State private var player: AVAudioPlayer?
	
	var body: some View {
		NavigationStack {
			ScrollView {
				HStack(spacing: 40) {
					recordSection(title: "Front", url: card.frontRecording, isRecording: activeRecording == .front, onRecord: { toggleRecording(.front) }, onPlay: { play(card.frontRecording) })
					recordSection(title: "Back", url: card.backRecording, isRecording: activeRecording == .back, onRecord: { toggleRecording(.back) }, onPlay: { play(card.backRecording) })
				}
			}
			.toolbar { toolbar }
			.onDisappear {
				stopRecording()
			}
		}
	}
	
	@ViewBuilder private func recordSection(title: String, url: URL?, isRecording: Bool, onRecord: @escaping () -> Void, onPlay: @escaping () -> Void) -> some View {
		HStack(spacing: 12) {
			//Text(title)
			//	.font(.headline)
			Button {
				onRecord()
			} label: {
				Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
					.font(.system(size: 50))
			}
			if storage.exists(url) {
				Button {
					onPlay()
				} label: {
					Label("Play", systemImage: "play.circle.fill")
				}
			}
		}
	}
}

fileprivate extension RecordingView {
	
	private enum Side {
		
		case front
		case back
	}
	
	private func toggleRecording(_ side: Side) {
		
		if activeRecording == side {
			return stopRecording()
		}
		stopRecording()
		do {
			let url = try storage.start(id: card.id, tag: side == .front ? "front" : "back")
			
			switch side {
			case .front:
				card.frontRecording = url
				recordingFront = true
				recordingBack = false
			case .back:
				card.backRecording = url
				recordingBack = true
				recordingFront = false
			}
			activeRecording = side
		} catch {
			recordingFront = false
			recordingBack = false
			activeRecording = nil
		}
	}
	
	private func stopRecording() {
		storage.stop()
		recordingFront = false
		recordingBack = false
		activeRecording = nil
	}
	
	private func play(_ url: URL?) {
		stopRecording()
		guard let url else { return }
		
		do {
			let player = try AVAudioPlayer(contentsOf: url)
			self.player = player
			player.play()
		} catch {
			//
		}
	}
}

/// Toolbar.
fileprivate extension RecordingView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				dismiss()
			} label: {
				Label("Close", systemImage: "xmark")
			}
		}
		ToolbarItem(placement: .principal) {
			Text("Recording")
				.font(.headline)
				.foregroundStyle(.secondary)
		}
	}
}

#Preview {
	RecordingView(card: Card(
		frontEntry: "hello my na🇺🇸m on, l, l,",
		backEntry: ",,,bonjour,,,,",
		frontLanguage: .en_US,
		backLanguage: .fr_CA
	))
	.environment(Recording())
}

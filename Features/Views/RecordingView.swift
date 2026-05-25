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
	
	@State private var activeRecording: Side?
	@State private var activePlaying: Side?
	@State private var deleteSide: DeleteSide?
	@State private var player: AVAudioPlayer?
	@State private var playerDelegate = PlayerDelegate()
	@State private var durations: [Side: String] = [:]
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 20) {
					recordSection(title: card.frontEntry, filename: card.frontRecording, side: .front)
					recordSection(title: card.backEntry, filename: card.backRecording, side: .back)
				}
				.padding(.horizontal, 20)
			}
			.onAppear {
				duration(for: card.frontRecording, side: .front)
				duration(for: card.backRecording, side: .back)
			}
			.onDisappear {
				stopRecording()
				stopPlaying()
			}
			.toolbar { toolbar }
			.navigationTitle("Recording")
			.navigationBarTitleDisplayMode(.inline)
			.alert("Clear Audio", isPresented: Binding(get: { deleteSide != nil }, set: { if !$0 { deleteSide = nil } })
			) {
				Button("Clear", role: .destructive) {
					guard let target = deleteSide else { return }
					switch target {
					case .front: deleteAudio(for: .front)
					case .back: deleteAudio(for: .back)
					case .all: deleteAudio(for: .front); deleteAudio(for: .back)
					}
					deleteSide = nil
				}
				Button("Cancel", role: .cancel) {
					deleteSide = nil
				}
			} message: {
				Text("Are you sure you want to clear this audio?")
			}
		}
	}
}

/// Record Section.
fileprivate extension RecordingView {
	
	@ViewBuilder private func recordSection(title: String, filename: String?, side: Side) -> some View {
		VStack(alignment: .trailing) {
			HStack(spacing: 20) {
				Text(title)
					.bold()
				Spacer()
				Button {
					toggleRecording(side)
				} label: {
					Image(systemName: activeRecording == side ? "stop.circle.fill" : "mic.circle.fill")
						.font(.system(size: 40))
						.foregroundStyle(activeRecording == side ? .red : .primary)
						.padding(3)
						.background(Circle().glassEffect(.clear.interactive()))
				}
				Button {
					play(filename, side: side)
				} label: {
					VStack(spacing: 4) {
						Label(activePlaying == side ? "Stop" : "Play", systemImage: activePlaying == side ? "stop.fill" : "play.fill")
							.bold()
						Label(durations[side] ?? "time", systemImage: "timer")
							.font(.caption2)
							.foregroundStyle(.secondary)
					}
					.lineLimit(1)
					.minimumScaleFactor(0.01)
					.frame(minWidth: 70)
					.padding(EdgeInsets(top: 7, leading: 20, bottom: 7, trailing: 20))
					.background(Capsule().glassEffect(.clear.tint(filename != nil ? .green.opacity(0.4) : .clear).interactive()))
				}
			}
			.buttonStyle(.plain)
		}
	}
}

/// Methods of RecordingView.
fileprivate extension RecordingView {
	
	private enum Side {
		
		case front
		case back
	}
	
	private enum DeleteSide {
		
		case front
		case back
		case all
	}
	
	private func toggleRecording(_ side: Side) {
		
		if activeRecording == side {
			return stopRecording()
		}
		stopRecording()
		do {
			
			let filename = try storage.start()
			let previous: String?
			
			switch side {
			case .front:
				previous = card.frontRecording
				card.frontRecording = filename
			case .back:
				previous = card.backRecording
				card.backRecording = filename
			}
			if let previous {
				storage.delete(previous)
			}
			activeRecording = side
		} catch {
			stopRecording()
		}
	}
	
	private func stopRecording() {
		storage.stop()
		if let side = activeRecording {
			let filename = side == .front ? card.frontRecording : card.backRecording
			duration(for: filename, side: side)
		}
		activeRecording = nil
	}
	
	private func stopPlaying() {
		player?.stop()
		player = nil
		activePlaying = nil
	}
	
	private func play(_ filename: String?, side: Side) {
		
		stopRecording()
		if activePlaying == side { return stopPlaying() }
		stopPlaying()
		guard let filename else { return }
		do {
			let player = try AVAudioPlayer(contentsOf: storage.url(for: filename))
			playerDelegate.onFinish = {
				Task {
					self.activePlaying = nil
					self.player = nil
				}
			}
			player.delegate = playerDelegate
			self.player = player
			activePlaying = side
			player.play()
		} catch {
			activePlaying = nil
		}
	}
	
	private func deleteAudio(for side: Side) {
		
		let filename: String?
		
		stopRecording()
		stopPlaying()
		
		switch side {
		case .front:
			filename = card.frontRecording
			durations[side] = nil
		case .back:
			filename = card.backRecording
			durations[side] = nil
		}
		storage.delete(filename)
		switch side {
		case .front: card.frontRecording = nil
		case .back: card.backRecording = nil
		}
	}
	
	private func duration(for filename: String?, side: Side) {
		
		guard let filename else { return durations[side] = nil }
		do {
			let player = try AVAudioPlayer(contentsOf: storage.url(for: filename))
			let duration = player.duration
			if duration < 60 {
				durations[side] = String(format: "%.2fs", duration)
			} else {
				durations[side] = String(format: "%02d:%02d", Int(duration) / 60, Int(duration) % 60)
			}
		} catch {
			durations[side] = nil
		}
	}
	
	final class PlayerDelegate: NSObject, AVAudioPlayerDelegate {
		var onFinish: (() -> Void)?
		func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool
		) { onFinish?() }
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
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				Button {
					deleteSide = .back
				} label: {
					Label("Clear Back Audio", systemImage: "trash")
				}
				Button {
					deleteSide = .front
				} label: {
					Label("Clear Front Audio", systemImage: "trash")
				}
				Button {
					deleteSide = .all
				} label: {
					Label("Clear All", systemImage: "trash")
				}
			} label: {
				Image(systemName: "ellipsis")
			}
		}
	}
}

#Preview {
	RecordingView(card: Card(
		frontEntry: "hello my na🇺🇸m fjdofjdo l,",
		backEntry: ",,,bonjour,,,,",
		frontLanguage: .en_US,
		backLanguage: .fr_CA
	))
	.environment(Recording())
}


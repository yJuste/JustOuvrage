//
//  SettingsView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/16/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Bindable private var preferences: Preferences = .unique
	@State private var state: CleaningState = .idle
	@State private var isCleaning: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					Button {
						cleanup()
					} label: {
						Label(title, systemImage: icon)
							.foregroundStyle(color)
					}
					.disabled(isCleaning)
				} header: {
					Text("General")
				} footer: {
					Text("""
  \(lastClean)
  
  This action performs a full cleanup of the local database and stored files.
  
  It will:
  • Remove duplicate cards (keeping the newest version)
  • Delete unused audio recordings
  • Remove unused images
  • Delete exported .jtouvrage packages
  
  This operation cannot be undone.
""")
				}
				Section {
					Picker("Global Color", selection: $preferences.globalColor) {
						ForEach(AccentColor.allCases, id: \.self) { color in
							HStack {
								Circle()
									.fill(color.color)
									.frame(width: 16, height: 16)
								Text(color.rawValue.capitalized)
							}
							.tag(color)
						}
					}
					.pickerStyle(.menu)
				} footer: {
					Text("Choose the global color for the app.")
				}
				Section {
					Toggle("Open links internally", isOn: $preferences.globalBrowser)
				} footer: {
					Text("If enabled, links open inside the app. Otherwise, they open in the external browser.")
				}
				Section {
					VStack(alignment: .trailing) {
						HStack {
							Text("Swipe Trigger")
							Spacer()
							Text("\(preferences.trialSwipeThreshold, specifier: "%.0f") pt")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						Slider(value: Binding(
							get: {
								preferences.trialSwipeThreshold
							},
							set: { value in
								preferences.trialSwipeThreshold = value
							}
						), in: 10...150, step: 1)
						.font(.footnote)
						.foregroundStyle(.secondary)
					}
				} header: {
					Text("Behavior")
				} footer: {
					Text("""
   Controls how far a card must be dragged before it is swiped away.
   
   150 pt = very long swipe
   100 pt = long swipe
   80 pt = moderate swipe
   50 pt = quick swipe
   10 pt = very fast swipe
   """)
				}
				Section {
					VStack(alignment: .trailing) {
						HStack {
							Text("Refresh Timer")
							Spacer()
							Text("~ \(1.0 / preferences.trialRefreshTimer, specifier: "%.0f") FPS")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						Slider(value: Binding(
							get: {
								1.0 / preferences.trialRefreshTimer
							},
							set: { fps in
								preferences.trialRefreshTimer = 1.0 / fps
							}
						), in: 10...60, step: 1)
						.font(.footnote)
						.foregroundStyle(.secondary)
					}
				} footer: {
					Text("""
  Controls refresh speed of the trial system.

  60 FPS = fastest updates, smoother behavior
  10 FPS = slower but lighter on CPU
""")
				}
				Section {
					Picker("Audio Quality", selection: $preferences.audioQuality) {
						Text("Low")
							.tag(AudioQuality.low)
						Text("Medium")
							.tag(AudioQuality.medium)
						Text("High")
							.tag(AudioQuality.high)
						Text("Ultra")
							.tag(AudioQuality.ultra)
						Text("Max")
							.tag(AudioQuality.max)
					}
					.pickerStyle(.menu)
				} header: {
					Text("Advanced")
				} footer: {
					Text("""
  Choose the audio quality of recordings.
  
  Low: lightweight, smallest files, lowest CPU usage
  Medium: balanced quality and size
  High: clear audio for everyday use
  Ultra: high fidelity, larger files
  Max: stereo, highest quality, highest resource usage
  
  Storage estimate (for 100 Mo, 2-second recordings):
  
  Low ≈ 2,440 recordings
  Medium ≈ 1,980 recordings
  High ≈ 1,297 recordings
  Ultra ≈ 1,207 recordings
  Max ≈ 1,140 recordings
  
  Tip: lower quality improves battery life and storage usage.
  """)
				}
				Section {
					Picker("Colored Background", selection: Binding<Int>(
						get: {
							if preferences.gradientBackground { return preferences.animationBackground ? 2 : 1 }
							return 0
						},
						set: { value in
							switch value {
							case 0: preferences.gradientBackground = false; preferences.animationBackground = false
							case 1: preferences.gradientBackground = true; preferences.animationBackground = false
							case 2: preferences.gradientBackground = true; preferences.animationBackground = true
							default: break
							}
						}
					)
					) {
						Text("None")
							.tag(0)
						Text("Gradient")
							.tag(1)
						Text("Gradient + Animation")
							.tag(2)
					}
					.pickerStyle(.menu)
				} footer: {
					Text("""
  Choose whether to use an animated background.
  
  None: no background
  
  Gradient: static gradient background
  Moderate impact on memory (~1.5x) and energy usage.
  
  Animated background: dynamic visual effects
  Moderate impact on memory (~1.5x) and significant and continuous energy consumption (~2.5x)
  """)
				}
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

/// Clean Duplicate of SettingsView.
fileprivate extension SettingsView {
	
	private enum CleaningState {
		
		case idle
		case running
		case success
		case failure
	}
	
	private var title: String {
		switch state {
		case .idle: return "Cleanup"
		case .running: return "Cleaning..."
		case .success: return "Cleanup completed"
		case .failure: return "Cleanup failed"
		}
	}
	
	private var icon: String {
		switch state {
		case .idle: return "trash"
		case .running: return "hourglass"
		case .success: return "checkmark.circle"
		case .failure: return "xmark.circle"
		}
	}
	
	private var color: Color {
		switch state {
		case .idle: return .primary
		case .running: return .blue
		case .success: return .green
		case .failure: return .red
		}
	}
	
	private var lastClean: String {
		
		guard let date = preferences.lastCleanup else { return "Never cleaned" }
		let formatter = DateFormatter()
		
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return "Last cleanup: \(formatter.string(from: date))"
	}
	
	private func cleanup() {
		
		guard !isCleaning else { return }
		
		state = .running
		isCleaning = true
		
		Task {
			defer { isCleaning = false }
			do {
				try Cleanup.cards(in: modelContext)
				try Cleanup.recordings(in: modelContext)
				try Cleanup.images(in: modelContext)
				try Cleanup.jtouvrages()
				
				state = .success
				preferences.lastCleanup = Date()
				
				try? modelContext.save()
				try await Task.sleep(for: .seconds(1.5))
				
				await MainActor.run { state = .idle }
			} catch {
				await MainActor.run { state = .failure }
				print(Errors.Duplication)
			}
		}
	}
}

#Preview {
	SettingsView()
}

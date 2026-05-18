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
	
	@Bindable private var preferences = Preferences.unique
	@State private var state: CleaningState = .idle
	@State private var isCleaning = false
	
	var body: some View {
		
		NavigationStack {
			List {
				Section {
					Button {
						try? modelContext.save()
						cleanDuplicate()
					} label: {
						Label(title, systemImage: icon)
							.foregroundStyle(color)
					}
					.disabled(isCleaning)
				} footer: {
					Text("""
  \(lastClean)
  
  This action scans all saved cards and removes duplicates.
  
  A duplicate is defined as identical front text, back text, and both languages.
  
  Only the oldest version of each duplicate set is kept.
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

60 FPS = fastest updates, smoother behavior.
10 FPS = slower but lighter on CPU.
""")
				}
			}
			.toolbar { toolbar }
		}
	}
}

/// Toolbar.
fileprivate extension SettingsView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .principal) {
			Text("Settings")
				.font(.headline)
				.foregroundStyle(.secondary)
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
	
	var title: String {
		switch state {
		case .idle: return "Clean Duplicate"
		case .running: return "Cleaning duplicates ..."
		case .success: return "Clean completed"
		case .failure: return "Clean failed"
		}
	}
	
	var icon: String {
		switch state {
		case .idle: return "trash"
		case .running: return "hourglass"
		case .success: return "checkmark.circle"
		case .failure: return "xmark.circle"
		}
	}
	
	var color: Color {
		switch state {
		case .idle: return .primary
		case .running: return .blue
		case .success: return .green
		case .failure: return .red
		}
	}
	
	private var lastClean: String {
		
		guard let date = preferences.lastCleanDuplicate else { return "Never cleaned" }
		let formatter = DateFormatter()
		
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return "Last clean: \(formatter.string(from: date))"
	}
	
	private func cleanDuplicate() {
		
		guard !isCleaning else { return }
		state = .running
		isCleaning = true; defer { isCleaning = false }
		
		do {
			try CardDuplication.removeDuplicates(in: modelContext)
			state = .success
			preferences.lastCleanDuplicate = Date()
			Task { @MainActor in
				try? await Task.sleep(for: .seconds(1.5))
				state = .idle
			}
		} catch {
			state = .failure
			print(Errors.CardDuplicationError)
		}
	}
}

#Preview {
	SettingsView()
}

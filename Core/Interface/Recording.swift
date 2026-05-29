//
//  Recording.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/21/26.
//

import Foundation
import AVFoundation

@Observable final class Recording {
	
	private var recorder: AVAudioRecorder?
	private var player: AVAudioPlayer?
	private let preferences: Preferences = .unique
	
	private let folder: URL = {
		let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Audio", isDirectory: true)
		try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		return url
	}()
	
	private var hasRecordingPermission: Bool { AVAudioApplication.shared.recordPermission == .granted }
	private func requestRecordingPermission() async -> Bool { await AVAudioApplication.requestRecordPermission() }
	
	func url(for filename: String) -> URL {
		folder.appendingPathComponent(filename)
	}
	
	func start() async throws -> String {
		
		let allowed: Bool
		
		if hasRecordingPermission {
			allowed = true
		} else {
			allowed = await requestRecordingPermission()
		}
		
		guard allowed else { throw Errors.AudioRecorder }
		
		let filename = "\(UUID().uuidString).m4a"
		let url = url(for: filename)
		let session = AVAudioSession.sharedInstance()
		
		try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetoothHFP])
		try session.setActive(true)
		
		let settings: [String: Any] = preferences.audioQuality.settings
		
		recorder = try AVAudioRecorder(url: url, settings: settings)
		recorder?.prepareToRecord()
		recorder?.record()
		
		return filename
	}
	
	func stop() {
		recorder?.stop()
		recorder = nil
	}
	
	func exists(_ filename: String?) -> Bool {
		
		guard let filename else { return false }
		
		return FileManager.default.fileExists(atPath: url(for: filename).path)
	}
	
	func delete(_ filename: String?) {
		
		guard let filename else { return }
		
		let fileURL = url(for: filename)
		do {
			if FileManager.default.fileExists(atPath: fileURL.path) {
				try FileManager.default.removeItem(at: fileURL)
			}
		} catch {
			print(Errors.AudioRecorder)
		}
	}
	
	// Player
	
	func play(_ filename: String?) {
		
		guard let filename else { return }
		guard exists(filename) else { return }
		
		do {
			let session = AVAudioSession.sharedInstance()
			try session.setCategory(.playback, mode: .spokenAudio)
			try session.setActive(true)
			
			player?.stop()
			player = try AVAudioPlayer(contentsOf: url(for: filename))
			player?.prepareToPlay()
			player?.play()
		} catch {
			print(Errors.AudioRecorder)
		}
	}
}

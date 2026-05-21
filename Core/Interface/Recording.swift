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
	
	private let folder: URL = {
		let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Audio", isDirectory: true)
		try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		return url
	}()
	
	func url(id: UUID, tag: String) -> URL {
		folder.appendingPathComponent("\(id.uuidString)-\(tag).m4a")
	}
	
	func start(id: UUID, tag: String) throws -> URL {
		
		let url = url(id: id, tag: tag)
		let session = AVAudioSession.sharedInstance()
		
		try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
		try session.setActive(true)
		
		let settings: [String: Any] = [
			AVFormatIDKey: kAudioFormatMPEG4AAC,
			AVSampleRateKey: 44_100,
			AVNumberOfChannelsKey: 1,
			AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
		]
		
		recorder = try AVAudioRecorder(url: url, settings: settings)
		recorder?.prepareToRecord()
		recorder?.record()
		
		return url
	}
	
	func stop() {
		recorder?.stop()
		recorder = nil
	}
	
	func exists(_ url: URL?) -> Bool {
		guard let url else { return false }
		return FileManager.default.fileExists(atPath: url.path)
	}
}

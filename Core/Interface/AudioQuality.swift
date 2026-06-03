//
//  AudioQuality.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/22/26.
//

import AVFoundation

enum AudioQuality: String {
	
	case low
	case medium
	case high
	case ultra
	case max
	
	var settings: [String: Any] {
		switch self {
		case .low: return [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 16_000, AVNumberOfChannelsKey: 1, AVEncoderBitRateKey: 32_000, AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue]
		case .medium: return [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 24_000, AVNumberOfChannelsKey: 1, AVEncoderBitRateKey: 48_000, AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue]
		case .high: return [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44_100, AVNumberOfChannelsKey: 1, AVEncoderBitRateKey: 64_000, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
		case .ultra: return [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44_100, AVNumberOfChannelsKey: 1, AVEncoderBitRateKey: 96_000, AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue]
		case .max: return [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 48_000, AVNumberOfChannelsKey: 2, AVEncoderBitRateKey: 128_000, AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue]
		}
	}
}

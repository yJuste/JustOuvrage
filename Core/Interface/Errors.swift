//
//  Errors.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/23/26.
//

/// An Interface to throw `errors`.
enum Errors: Error {
	
	case Image
	case Password
	case Site
	case Duplication
	case DuplicationCard
	case DuplicationRecording
	case DuplicationJTouvrage
	case ModelContext
	case AudioRecorder
	case DataTransfer
	case Transfer
	case FileManager
}

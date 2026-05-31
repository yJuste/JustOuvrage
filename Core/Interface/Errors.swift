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
	case DuplicationCard
	case DuplicationRecording
	case ModelContext
	case AudioRecorder
	case DataTransfer
}

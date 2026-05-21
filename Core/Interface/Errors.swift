//
//  Errors.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/23/26.
//

/// An Interface to throw `errors`.
enum Errors: Error {
	
	case ImageError
	case PasswordError
	case SiteError
	case CardDuplicationError
	case ModelContextError
	case AudioRecorder
}

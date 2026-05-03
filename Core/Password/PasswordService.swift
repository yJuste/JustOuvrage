//
//  PasswordService.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/28/26.
//

/// A Service that contains `hash` functions for handling passwords.
protocol PasswordService {
	
	func hash(password: String) -> String
}

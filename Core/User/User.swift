//
//  User.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/28/26.
//

import SwiftUI

/// Create a ``User``.
@Observable final class User {
	
	var name: String
	var token: String
	
	init(name: String, token: String) {
		self.name = name
		self.token = token
	}
}

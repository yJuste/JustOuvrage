//
//  User.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/28/26.
//

import SwiftUI

@Observable final class User {
	
	var name: String
	var token: String
	
	init(name: String, token: String) {
		self.name = name
		self.token = token
	}
}

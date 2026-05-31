//
//  DataExtension.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

import Foundation
import CryptoKit

extension Data {
	
	var sha256: String {
		let hash = SHA256.hash(data: self)
		return hash.map { String(format: "%02x", $0) }.joined()
	}
}

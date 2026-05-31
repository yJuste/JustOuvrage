//
//  Duplication.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

import SwiftUI
import SwiftData
import CryptoKit

/// Deletes card duplicates..
struct Duplication {
	
	private struct Key: Hashable {
		
		let front: String
		let back: String
		let frontLanguage: Language
		let backLanguage: Language
		
		init(card: Card) {
			self.front = card.frontEntry.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
			self.back = card.backEntry.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
			self.frontLanguage = card.frontLanguage
			self.backLanguage = card.backLanguage
		}
	}
	
	static func removeCards(in modelContext: ModelContext) throws {
		
		let cards: [Card] = try modelContext.fetch(FetchDescriptor<Card>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))
		var seen: Set = Set<Key>()
		var duplicates: [Card] = []
		
		for card in cards {
			if seen.insert(Key(card: card)).inserted == false {
				duplicates.append(card)
			}
		}
		
		duplicates.forEach(modelContext.delete)
		try modelContext.save()
	}
	
	static func removeRecordings() throws {
		
		let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Audio")
		
		let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
		
		var seenNames = Set<String>()
		var seenHashes = Set<String>()
		
		for file in files {
			
			let name = file.lastPathComponent
			
			guard let data = try? Data(contentsOf: file) else {
				try? FileManager.default.removeItem(at: file)
				continue
			}
			
			let hash = data.sha256
			
			if seenNames.contains(name) || seenHashes.contains(hash) {
				try? FileManager.default.removeItem(at: file)
			} else {
				seenNames.insert(name)
				seenHashes.insert(hash)
			}
		}
	}
	
	static func removeImages() throws {
		
		let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Images")
		
		let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
		
		var seenNames = Set<String>()
		var seenHashes = Set<String>()
		
		for file in files {
			
			let name = file.lastPathComponent
			
			guard let data = try? Data(contentsOf: file) else {
				try? FileManager.default.removeItem(at: file)
				continue
			}
			
			let hash = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
			
			if seenNames.contains(name) || seenHashes.contains(hash) {
				try? FileManager.default.removeItem(at: file)
			} else {
				seenNames.insert(name)
				seenHashes.insert(hash)
			}
		}
	}
	
	static func removeJTouvrageFiles() {
		
		let fm = FileManager.default
		
		guard let files = try? fm.contentsOfDirectory(at: fm.urls(for: .documentDirectory, in: .userDomainMask)[0], includingPropertiesForKeys: nil) else { return }
		
		for file in files where file.pathExtension == "jtouvrage" {
			do {
				try fm.removeItem(at: file)
			} catch {
				print(Errors.DuplicationJTouvrage)
			}
		}
	}
}

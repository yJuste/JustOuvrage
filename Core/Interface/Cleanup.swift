//
//  Cleanup.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/3/26.
//

import SwiftUI
import SwiftData
import CryptoKit

/// Deletes card duplicates.
enum Cleanup {
	
	static func cards(in modelContext: ModelContext) throws {
		
		var latest: [Key: Card] = [:]
		var toDelete: [Card] = []
		
		for card in try modelContext.fetch(FetchDescriptor<Card>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])) {
			
			let key = Key(card: card)
			
			if latest[key] != nil {
				toDelete.append(card)
			} else {
				latest[key] = card
			}
		}
		
		toDelete.forEach(modelContext.delete)
		try modelContext.save()
	}
	
	static func recordings(in modelContext: ModelContext) throws {
		
		let fm = FileManager.default
		let referencedRecordings = Set(try modelContext.fetch(FetchDescriptor<Card>()).flatMap { [$0.frontRecording, $0.backRecording] }.compactMap { $0?.lowercased() })
		
		var seenNames = Set<String>()
		var seenHashes = Set<String>()
		
		for file in (try? fm.contentsOfDirectory(at: fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Audio"), includingPropertiesForKeys: nil)) ?? [] {
			
			let name = file.lastPathComponent.lowercased()
			
			guard referencedRecordings.contains(name) else {
				try? fm.removeItem(at: file)
				continue
			}
			
			guard let data = try? Data(contentsOf: file) else {
				try? fm.removeItem(at: file)
				continue
			}
			
			let hash = data.sha256
			
			if seenNames.contains(name) || seenHashes.contains(hash) {
				try? fm.removeItem(at: file)
			} else {
				seenNames.insert(name)
				seenHashes.insert(hash)
			}
		}
	}
	
	static func images(in modelContext: ModelContext) throws {
		
		let fm = FileManager.default
		let referencedImages = Set(try modelContext.fetch(FetchDescriptor<Deck>()).map { $0.image.lowercased() })
		
		var seenNames = Set<String>()
		var seenHashes = Set<String>()
		
		for file in (try? fm.contentsOfDirectory(at: fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Images"), includingPropertiesForKeys: nil)) ?? [] {
			
			let name = file.lastPathComponent.lowercased()
			
			guard name.lowercased().hasSuffix(".png") else {
				try? fm.removeItem(at: file)
				continue
			}
			
			guard referencedImages.contains(name) else {
				try? fm.removeItem(at: file)
				continue
			}
			
			guard let data = try? Data(contentsOf: file) else {
				try? fm.removeItem(at: file)
				continue
			}
			
			let hash = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
			
			if seenNames.contains(name) || seenHashes.contains(hash) {
				try? fm.removeItem(at: file)
			} else {
				seenNames.insert(name)
				seenHashes.insert(hash)
			}
		}
	}
	
	static func jtouvrages() throws {
		
		let fm = FileManager.default
		
		guard let items = try? fm.contentsOfDirectory(at: fm.urls(for: .documentDirectory, in: .userDomainMask)[0], includingPropertiesForKeys: nil) else { return }
		
		for item in items where item.pathExtension == "jtouvrage" {
			do {
				try fm.removeItem(at: item)
			} catch {
				throw Errors.DuplicationJTouvrage
			}
		}
	}
	
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
}

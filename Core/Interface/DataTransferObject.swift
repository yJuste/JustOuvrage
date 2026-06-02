//
//  DataTransferObject.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

import Foundation
import SwiftData

enum DataTransferObject {
	
	static var documentsURL: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!	}
	static var imagesURL: URL { documentsURL.appendingPathComponent("Images", isDirectory: true) }
	static var audioURL: URL { documentsURL.appendingPathComponent("Audio", isDirectory: true) }
	
	@MainActor static func export(deck: Deck?, cards: [Card], recording: Recording) throws -> URL {
		
		let fm = FileManager.default
		
		let packageURL = documentsURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jtouvrage")
		
		if fm.fileExists(atPath: packageURL.path) { try fm.removeItem(at: packageURL) }
		
		try fm.createDirectory(at: packageURL, withIntermediateDirectories: true)
		
		let imagesFolder = packageURL.appendingPathComponent("Images")
		let audioFolder = packageURL.appendingPathComponent("Audio")
		
		try fm.createDirectory(at: imagesFolder, withIntermediateDirectories: true)
		try fm.createDirectory(at: audioFolder, withIntermediateDirectories: true)
		
		let decksToExport: [Deck] = {
			if let deck { return [deck] }
			return Array(Set(cards.flatMap { $0.decks }))
		}()
		
		let payload = Payload(deck: deck.map(Payload.Deck.init), cards: cards.map(Payload.Card.init))
		
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted]
		encoder.dateEncodingStrategy = .iso8601
		
		let json = try encoder.encode(payload)
		try json.write(to: packageURL.appendingPathComponent("export.json"))
		
		for deck in decksToExport {
			let source = imagesURL.appendingPathComponent(deck.image)
			
			if fm.fileExists(atPath: source.path) { try fm.copyItem(at: source, to: imagesFolder.appendingPathComponent(deck.image)) }
		}
		
		for card in cards {
			for filename in [card.frontRecording, card.backRecording] {
				
				guard let filename else { continue }
				
				let source = recording.url(for: filename)
				
				guard fm.fileExists(atPath: source.path) else { continue }
				
				let destination = audioFolder.appendingPathComponent(filename)
				
				if !fm.fileExists(atPath: destination.path) { try fm.copyItem(at: source, to: destination) }
			}
		}
		
		return packageURL
	}
	
	static func `import`(from packageURL: URL, context: ModelContext) throws {
		
		guard packageURL.startAccessingSecurityScopedResource() else { throw Errors.DataTransfer }
		defer { packageURL.stopAccessingSecurityScopedResource() }
		
		let data = try Data(contentsOf: packageURL.appendingPathComponent("export.json"))
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		
		let payload = try decoder.decode(Payload.self, from: data)
		
		try copyAssets(from: packageURL.appendingPathComponent("Images"), to: imagesURL)
		try copyAssets(from: packageURL.appendingPathComponent("Audio"), to: audioURL)
		
		if let exportedDeck = payload.deck {
			
			let deck = Deck(name: exportedDeck.name, image: exportedDeck.image)
			deck.depiction = exportedDeck.depiction
			deck.author = exportedDeck.author
			context.insert(deck)
			
			for dto in payload.cards {
				let card = makeCard(dto)
				deck.cards.append(card)
				context.insert(card)
			}
		} else {
			for dto in payload.cards { context.insert(makeCard(dto)) }
		}
		try context.save()
	}
	
	static func copyAssets(from source: URL, to destination: URL) throws {
		
		let fm = FileManager.default
		
		guard fm.fileExists(atPath: source.path) else { return }
		
		if !fm.fileExists(atPath: destination.path) { try fm.createDirectory(at: destination, withIntermediateDirectories: true) }
		
		for file in try fm.contentsOfDirectory(at: source, includingPropertiesForKeys: nil) {
			
			let dest = destination.appendingPathComponent(file.lastPathComponent)
			
			if !fm.fileExists(atPath: dest.path) { try fm.copyItem(at: file, to: dest) }
		}
	}
	
	static func makeCard(_ dto: Payload.Card) -> Card {
		
		let card = Card(
			frontEntry: dto.frontEntry,
			backEntry: dto.backEntry,
			frontLanguage: dto.frontLanguage,
			backLanguage: dto.backLanguage
		)
		card.frontRecording = dto.frontRecording
		card.backRecording = dto.backRecording
		card.leitnerScore = dto.leitnerScore
		card.nextLeitnerAt = dto.nextLeitnerAt
		card.author = dto.author
		return card
	}
}

extension DataTransferObject {
	
	struct Payload: Codable {
		
		let deck: Deck?
		let cards: [Card]
		
		struct Deck: Codable {
			let name: String
			let image: String
			let depiction: String
			let author: String
		}
		
		struct Card: Codable {
			let frontEntry: String
			let backEntry: String
			let frontLanguage: Language
			let backLanguage: Language
			let frontRecording: String?
			let backRecording: String?
			let leitnerScore: Int
			let nextLeitnerAt: Date?
			let author: String
		}
	}
}

extension DataTransferObject.Payload.Deck {
	init(model deck: Deck) {
		self.name = deck.name
		self.image = deck.image
		self.depiction = deck.depiction
		self.author = deck.author
	}
}

extension DataTransferObject.Payload.Card {
	init(model card: Card) {
		self.frontEntry = card.frontEntry
		self.backEntry = card.backEntry
		self.frontLanguage = card.frontLanguage
		self.backLanguage = card.backLanguage
		self.frontRecording = card.frontRecording
		self.backRecording = card.backRecording
		self.leitnerScore = card.leitnerScore
		self.nextLeitnerAt = card.nextLeitnerAt
		self.author = card.author
	}
}

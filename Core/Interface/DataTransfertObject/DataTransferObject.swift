//
//  DataTransferObject.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

import Foundation
import SwiftData

enum DataTransferObject {
	
	static var documentsURL: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! }
	static var imagesURL: URL { documentsURL.appendingPathComponent("Images", isDirectory: true) }
	static var audioURL: URL { documentsURL.appendingPathComponent("Audio", isDirectory: true) }
	
	@MainActor static func export(deck: Deck?, cards: [Card], recording: Recording) throws -> URL {
		
		let fm = FileManager.default
		let packageURL = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jtouvrage")
		
		if fm.fileExists(atPath: packageURL.path) { try fm.removeItem(at: packageURL) }
		
		try fm.createDirectory(at: packageURL, withIntermediateDirectories: true)
		
		let images = packageURL.appendingPathComponent("Images")
		let audio = packageURL.appendingPathComponent("Audio")
		
		try fm.createDirectory(at: images, withIntermediateDirectories: true)
		try fm.createDirectory(at: audio, withIntermediateDirectories: true)
		
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted]
		encoder.dateEncodingStrategy = .iso8601
		
		try encoder.encode(Payload(deck: deck.map(Payload.Deck.init), cards: cards.map(Payload.Card.init))).write(to: packageURL.appendingPathComponent("export.json"))
		
		if let deck {
			let source = imagesURL.appendingPathComponent(deck.image)
			if fm.fileExists(atPath: source.path) {
				try fm.copyItem(at: source, to: images.appendingPathComponent(deck.image))
			}
		}
		
		for card in cards {
			
			for filename in [card.frontRecording, card.backRecording] {
				
				guard let filename else { continue }
				
				let source = recording.url(for: filename)
				
				guard fm.fileExists(atPath: source.path) else { continue }
				
				let destination = audio.appendingPathComponent(filename)
				
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
			
			let existingDeck = try context.fetch(FetchDescriptor<Deck>(predicate: #Predicate { $0.id == exportedDeck.id }))
			
			guard existingDeck.isEmpty else { return }
			
			let deck = Deck(name: exportedDeck.name, image: exportedDeck.image)
			
			deck.depiction = exportedDeck.depiction
			deck.author = exportedDeck.author
			
			for dto in payload.cards {
				
				let card = makeCard(dto)
				card.decks.append(deck)
				deck.cards.append(card)
				context.insert(card)
			}
			
			context.insert(deck)
		}
		else {
			
			for dto in payload.cards {
				
				let existing = try context.fetch(FetchDescriptor<Card>(predicate: #Predicate { $0.id == dto.id } ))
				
				guard existing.isEmpty else { continue }
				
				context.insert(makeCard(dto))
			}
		}
		try context.save()
	}
	
	static func copyAssets(from source: URL, to destination: URL) throws {
		
		let fm = FileManager.default
		
		guard fm.fileExists(atPath: source.path) else { return }
		
		if !fm.fileExists(atPath: destination.path) { try fm.createDirectory(at: destination, withIntermediateDirectories: true) }
		
		for file in try fm.contentsOfDirectory(at: source, includingPropertiesForKeys: nil) {
			
			let destinationFile = destination.appendingPathComponent(file.lastPathComponent)
			
			if !fm.fileExists(atPath: destinationFile.path) { try fm.copyItem(at: file, to: destinationFile) }
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
			
			let id: UUID
			let name: String
			let image: String
			let depiction: String
			let author: String
			let createdAt: Date
		}
		
		struct Card: Codable {
			
			let id: UUID
			let frontEntry: String
			let backEntry: String
			let frontLanguage: Language
			let backLanguage: Language
			let frontRecording: String?
			let backRecording: String?
			let leitnerScore: Int
			let nextLeitnerAt: Date?
			let author: String
			let createdAt: Date
		}
	}
}

private extension DataTransferObject.Payload.Deck {
	
	init(_ deck: Deck) {
		self.init(
			id: deck.id,
			name: deck.name,
			image: deck.image,
			depiction: deck.depiction,
			author: deck.author,
			createdAt: deck.createdAt
		)
	}
}

private extension DataTransferObject.Payload.Card {
	
	init(_ card: Card) {
		self.init(
			id: card.id,
			frontEntry: card.frontEntry,
			backEntry: card.backEntry,
			frontLanguage: card.frontLanguage,
			backLanguage: card.backLanguage,
			frontRecording: card.frontRecording,
			backRecording: card.backRecording,
			leitnerScore: card.leitnerScore,
			nextLeitnerAt: card.nextLeitnerAt,
			author: card.author,
			createdAt: card.createdAt
		)
	}
}

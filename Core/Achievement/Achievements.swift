//
//  Achievements.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/1/26.
//

enum Achievements: Identifiable, CaseIterable {
	
	case beginner			// A1 → ~500 words
	case rookie				// A2 → ~1,000 words
	case amateur			// B1 → ~2,500 words
	case grinder			// B2 → ~6,000 words
	case tryharder			// B2+ → ~8,000 words
	case seeker				// C1 → ~15,000 words
	case bilingual			// C2 → ~22,000 words
	case polyglot			// ~30,000 words ( 2 x C1 )
	case linguist			// ~44,000 words ( 2 x C2 )
	case wordsmith			// ~66,000 words ( 3 x C2 )
	case theAnswer			// ~105,000 words ( 7 x C1 )
	
	case deafened			// ~200 audios ( 100 cards )
	case silentNoMore		// ~500 audios ( 250 cards)
	case hearMeOut			// ~3,000 audios ( 1,500 cards )
	case inTheLoop			// ~6,000 audios ( 3,000 cards )
	case tunedIn			// ~10,000 audios ( 5,000 cards )
	case lostInTheMusic		// ~14,500 audios ( 7,000 cards )
	case soundMaster		// ~20,000 audios ( 10,000 cards )
	case audiophile			// ~40,000 audios ( 20,000 cards )
	
	case lightner			// ~100 cards with the maximum leitner score at 7.
	case boxer				// ~750 cards with the maximum leitner score at 7.
	case brawks				// 2,000 cards with the maximum leitner score at 7.
	case boxBox				// ~5,000 cards with the maximum leitner score at 7.
	
	case winner				// Have 250 time trials with the maximum score at 100%.
	case looser				// Have 250 time trials with the minimum score at 0%.
	
	case flagger			// I have at least one card of each language.
	case cleanup			// you cleaned up at least one time.
	case smileysEverywhere	// You have smiley in a card, a deck and your profile name!?
	
	var id: Self { self }
	
	var title: String {
		switch self {
		case .beginner: return "The Beginner"
		case .rookie: return "The Rookie"
		case .amateur: return "The Amateur"
		case .grinder: return "The Grinder"
		case .tryharder: return "The Tryharder"
		case .seeker: return "The Seeker"
		case .bilingual: return "The Bilingual"
		case .polyglot: return "The Polyglot"
		case .linguist: return "The Linguist"
		case .wordsmith: return "The Wordsmith"
		case .theAnswer: return "The Answer"
			
		case .deafened: return "Deafened"
		case .silentNoMore: return "Silent No More"
		case .hearMeOut: return "Hear Me Out"
		case .inTheLoop: return "In The Loop"
		case .tunedIn: return "Tuned In"
		case .lostInTheMusic: return "Lost In The Music"
		case .soundMaster: return "Sound Master"
		case .audiophile: return "The Audiophile"
			
		case .lightner: return "Lightner"
		case .boxer: return "Boxer"
		case .brawks: return "Brawks"
		case .boxBox: return "Box Box"
			
		case .winner: return "Winner"
		case .looser: return "Looser"
			
		case .flagger: return "Flagger"
		case .cleanup: return "Cleanup"
		case .smileysEverywhere: return "Smileys Everywhere"
		}
	}
	
	var shortDescription: String {
		switch self {
		case .beginner: return "reach 500 cards"
		case .rookie: return "reach 1,000 cards"
		case .amateur: return "reach 2,500 cards"
		case .grinder: return "reach 6,000 cards"
		case .tryharder: return "reach 8,000 cards"
		case .seeker: return "reach 15,000 cards"
		case .bilingual: return "reach 22,000 cards"
		case .polyglot: return "reach 30,000 cards"
		case .linguist: return "reach 44,000 cards"
		case .wordsmith: return "reach 66,000 cards"
		case .theAnswer: return "reach 105,000 cards"
			
		case .deafened: return "reach 200 audios"
		case .silentNoMore: return "reach 500 audios"
		case .hearMeOut: return "reach 3,000 audios"
		case .inTheLoop: return "reach 6,000 audios"
		case .tunedIn: return "reach 10,000 audios"
		case .lostInTheMusic: return "reach 14,500 audios"
		case .soundMaster: return "reach 20,000 audios"
		case .audiophile: return "reach 40,000 audios"
			
		case .lightner: return "100 cards (max. leitner score)"
		case .boxer: return "750 cards (max. leitner score)"
		case .brawks: return "2,000 cards (max. leitner score)"
		case .boxBox: return "5,000 cards (max. leitner score)"
			
		case .winner: return "250 trials at 100%"
		case .looser: return "250 trials at 0%"
			
		case .flagger: return "Quantity over quality"
		case .cleanup: return "I did my job"
		case .smileysEverywhere: return "The smileys took over. I've lost the words."
		}
	}
	
	var description: String {
		switch self {
		case .beginner: return "Start your journey with your first steps into vocabulary building."
		case .rookie: return "You are building consistency and expanding your base knowledge."
		case .amateur: return "You are getting serious about structured learning."
		case .grinder: return "Steady grinding leads to real long-term progress."
		case .tryharder: return "You are pushing beyond casual learning into discipline."
		case .seeker: return "You actively seek deeper understanding and mastery."
		case .bilingual: return "You can comfortably operate across multiple languages."
		case .polyglot: return "You are approaching advanced multilingual fluency."
		case .linguist: return "You demonstrate strong control of language systems."
		case .wordsmith: return "You express yourself with precision and depth."
		case .theAnswer: return "You reached extreme vocabulary mastery."
			
		case .deafened: return "You started engaging with audio learning."
		case .silentNoMore: return "You are actively repeating and practicing audio content."
		case .hearMeOut: return "You maintain consistent listening and repetition habits."
		case .inTheLoop: return "Audio learning is now part of your routine."
		case .tunedIn: return "You are deeply focused on auditory comprehension."
		case .lostInTheMusic: return "You are fully immersed in sound-based learning."
		case .soundMaster: return "You demonstrate strong mastery of audio learning systems."
		case .audiophile: return "You obsess over audio detail and precision."
			
		case .lightner: return "You reached basic Leitner discipline."
		case .boxer: return "You built solid spaced repetition habits."
		case .brawks: return "You achieved advanced Leitner consistency."
		case .boxBox: return "You reached elite spaced repetition mastery."
			
		case .winner: return "Worst grades, maybe the opposite ? I don't remember."
		case .looser: return "Best grades, maybe the opposite ? I don't remember."
			
		case .flagger: return "One thing at a time. Don't you think ?"
		case .cleanup: return "Keep up maintaining your system."
		case .smileysEverywhere: return "😂🐞📖🏁🥳"
		}
	}
	
	func pourcentage(in context: AchievementContext) -> Double {
		
		let cardsCount = Double(context.cards.count)
		let audioCount = Double(context.cards.reduce(0) { result, card in result + (card.frontRecording != nil ? 1 : 0) + (card.backRecording != nil ? 1 : 0) })
		let leitnerCount = Double(context.cards.filter { $0.leitnerScore == 7 }.count)
		
		switch self {
		case .beginner: return min(cardsCount / 500.0, 1.0)
		case .rookie: return min(cardsCount / 1_000.0, 1.0)
		case .amateur: return min(cardsCount / 2_500.0, 1.0)
		case .grinder: return min(cardsCount / 6_000.0, 1.0)
		case .tryharder: return min(cardsCount / 8_000.0, 1.0)
		case .seeker: return min(cardsCount / 15_000.0, 1.0)
		case .bilingual: return min(cardsCount / 22_000.0, 1.0)
		case .polyglot: return min(cardsCount / 30_000.0, 1.0)
		case .linguist: return min(cardsCount / 44_000.0, 1.0)
		case .wordsmith: return min(cardsCount / 66_000.0, 1.0)
		case .theAnswer: return min(cardsCount / 105_000.0, 1.0)
			
		case .deafened: return min(audioCount / 200.0, 1.0)
		case .silentNoMore: return min(audioCount / 500.0, 1.0)
		case .hearMeOut: return min(audioCount / 3_000.0, 1.0)
		case .inTheLoop: return min(audioCount / 6_000.0, 1.0)
		case .tunedIn: return min(audioCount / 10_000.0, 1.0)
		case .lostInTheMusic: return min(audioCount / 14_500.0, 1.0)
		case .soundMaster: return min(audioCount / 20_000.0, 1.0)
		case .audiophile: return min(audioCount / 40_000.0, 1.0)
			
		case .lightner: return min(leitnerCount / 100.0, 1.0)
		case .boxer: return min(leitnerCount / 750.0, 1.0)
		case .brawks: return min(leitnerCount / 2_000.0, 1.0)
		case .boxBox: return min(leitnerCount / 5_000.0, 1.0)
			
		case .winner: return min(Double(context.timeTrials.filter { $0.success >= 0.999 }.count) / 250.0, 1.0)
		case .looser: return min(Double(context.timeTrials.filter { $0.success <= 0.001 }.count) / 250.0, 1.0)
			
		case .flagger: return Language.allCases.allSatisfy { Set(context.cards.flatMap { [$0.frontLanguage, $0.backLanguage] }).contains($0) } ? 1.0 : 0.0
		case .cleanup: return context.cleanupDate != nil ? 1.0 : 0.0
		case .smileysEverywhere:
			return context.decks.filter { deck in
				guard deck.name.contains(where: \.isEmoji) else { return false }
				guard deck.depiction.contains(where: \.isEmoji) else { return false }
				return deck.cards.filter { $0.frontEntry.contains(where: \.isEmoji) || $0.backEntry.contains(where: \.isEmoji) }.count >= 10
			}.isEmpty ? 0.0 : 1.0
		}
	}
	
	func isUnlocked(in context: AchievementContext) -> Bool { pourcentage(in: context) >= 1.0 }
	
	func isUnlocked(pourcentage: Double) -> Bool { pourcentage >= 1.0 }
	
	private func isEmojiOnly(_ string: String) -> Bool { string.filter { !$0.isEmoji }.isEmpty }
}

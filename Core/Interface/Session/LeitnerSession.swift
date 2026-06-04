//
//  LeitnerSession.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/26/26.
//

import SwiftUI

struct LeitnerSession: SessionService {
	
	let id: UUID = UUID()
	let title: String = "Leitner Box"
	let subtitle: String = "Learn by repetion"
	let depiction: String = """
 This interface lets you use the Leitner System to learn faster and track all of your progress.
 
 The Leitner System is a widely used method designed to improve the efficiency of flashcards, introduced in the 1970s by the German science journalist Sebastian Leitner. It's a simple implementation of the spaced repetition principle, where cards are reviewed less and less frequently over time.
 
 Method:
 In this system, flashcards are sorted into groups depending on how well the learner knows them. Learners try to recall the answer written on a card. If they succeed, the card moves to the next group. If they fail, it goes back to the first group. The higher the group, the longer the delay before the learner reviews the card again.
 (credit: https://espaceup.univ-lemans.fr/docs/anka-et-la-boite-de-leitner-un-outil-numerique-pour-les-revisions)
 
 There are 7 boxes. The 7th one is the final stage, and if you reach it, you'll complete the card!
 
 In the header, you'll see the number of remaining cards to review.
 You'll also see the next review date. Each card has its own review schedule, and everything is based on those dates.
 
 The Learn button will launch a session with the cards that need to be reviewed.
 
 You have 2 sections:
 Pending, for all cards waiting to be reviewed.
 And All, which lists every card along with its Leitner score.
 """
	let banner: ImageResource = .leitner
	let leitnerExample: ImageResource = .leitnerExample
}

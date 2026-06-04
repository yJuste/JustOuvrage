//
//  RecordingSession.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/23/26.
//

import SwiftUI

struct RecordingSession: SessionService {
	
	let id: UUID = UUID()
	let title: String = "Audio Recording"
	let subtitle: String = "Record your own pronunciation"
	let depiction: String = """
 This interface lets you record your own pronunciations for every expression.
 
 All cards are sorted by date added, with the newest ones right at the top.
 
 On the right side of each expression, you'll find a waveform button that opens a sheet where you can record your audio.
 
 A color indicator helps you quickly track your recording progress:
 • Green — both recordings are completed
 • Orange — only one side is recorded
 • Gray — no recordings yet
 
 Small indicators are also displayed so you can instantly tell how many recordings have been made for a card.
 """
	let depiction2: String = """
   
   Once a card has recordings, you can play them back anytime directly from the card sheet by tapping the flags in the top toolbar.
  
   The first flag is linked to the first entry, while the second one corresponds to the second entry.
  """
	let depiction3: String = """
  
  Your overall progress is displayed at the top.
  
  Have fun completing them all :)
  """
	let banner: ImageResource = .audioRecording
	let recordingExample: ImageResource = .audioRecordingExample
	let cardExample: ImageResource = .cardExample
}

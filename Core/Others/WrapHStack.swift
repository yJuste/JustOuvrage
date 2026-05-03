//
//  WrapHStack.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/30/26.
//

import SwiftUI

/// An extension for HStack that can `wrap elements` for a better layout.
struct WrapHStack: Layout {
	
	var spacing: CGFloat = 8
	
	func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
		return compute(subviews: subviews, maxWidth: proposal.width ?? .infinity).size
	}
	
	func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
		
		for (index, frame) in compute(subviews: subviews, maxWidth: bounds.width).frames.enumerated() {
			subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
		}
	}
	
	private func compute(subviews: Subviews, maxWidth: CGFloat) -> (size: CGSize, frames: [CGRect]) {
		
		var frames: [CGRect] = []
		var x: CGFloat = 0
		var y: CGFloat = 0
		var rowHeight: CGFloat = 0
		
		for view in subviews {
			let size = view.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
			let spacingToUse = x == 0 ? 0 : spacing
			
			if x + size.width + spacingToUse > maxWidth {
				x = 0
				y += rowHeight + spacing
				rowHeight = 0
			}
			frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
			x += size.width + spacing
			rowHeight = max(rowHeight, size.height)
		}
		return (CGSize(width: maxWidth, height: y + rowHeight), frames)
	}
}

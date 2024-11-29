//
//  View+Extensions.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

import SwiftUI

public extension View {
    @ViewBuilder func morphed<Mask: View>(
        blurRadius: CGFloat = 50, insets: MorphedInsets = .init(),
        @ViewBuilder mask: @escaping () -> Mask
    ) -> some View {
        modifier(MorphedViewModifier(blurRadius: blurRadius, insets: insets, mask: mask))
    }
    
    @ViewBuilder func morphed(
        blurRadius: CGFloat = 50, insets: MorphedInsets = .init(),
        _ linearGradient: LinearGradient
    ) -> some View {
        modifier(MorphedViewModifier(blurRadius: blurRadius, insets: insets) {
            linearGradient
        })
    }
}

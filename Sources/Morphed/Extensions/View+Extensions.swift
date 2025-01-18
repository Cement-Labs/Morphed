//
//  View+Extensions.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

import SwiftUI

public extension View {
    /// Applies a progressive blur effect.
    ///
    /// - Parameters:
    ///   - blurRadius: the maximum radius of the blur effect.
    ///   The final blur radius of every pixel will dynamically adjust based on the mask, where *full white* returns the maximum radius and *full black* returns zero.
    ///   - insets: the ``MorphedInsets`` that defines the insets of the blur effect.
    ///   - isActive: whether the blur effect is actively applied onto the content.
    ///   - mask: the mask that configures the strength of the blur.
    @ViewBuilder func morphed<Mask: View>(
        blurRadius: CGFloat = 50, insets: MorphedInsets = .init(), isActive: Bool = true,
        @ViewBuilder mask: @escaping () -> Mask
    ) -> some View {
        modifier(MorphedViewModifier(blurRadius: blurRadius, insets: insets, isActive: isActive, mask: mask))
    }

    /// Applies a progressive blur effect with a simple linear gradient.
    ///
    /// - Parameters:
    ///   - blurRadius: the maximum radius of the blur effect.
    ///   The final blur radius of every pixel will dynamically adjust based on the mask, where *full white* returns the maximum radius and *full black* returns zero.
    ///   - insets: the ``MorphedInsets`` that defines the insets of the blur effect.
    ///   - linearGradient: the linear gradient mask that configures the strength of the blur.
    ///   - isActive: whether the blur effect is actively applied onto the content.
    @ViewBuilder func morphed(
        blurRadius: CGFloat = 50, insets: MorphedInsets = .init(), isActive: Bool = true,
        _ linearGradient: LinearGradient
    ) -> some View {
        modifier(MorphedViewModifier(blurRadius: blurRadius, insets: insets, isActive: isActive) {
            linearGradient
                .frame(width: 1024, height: 1024)
        })
    }
}

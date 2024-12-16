//
//  MorphedViewModifier.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

import SwiftUI

public struct MorphedViewModifier<Mask>: ViewModifier where Mask: View {
    public var blurRadius: CGFloat = 50
    public var insets: MorphedInsets = .init()

    @ViewBuilder public var mask: () -> Mask

    @ViewBuilder public func body(content: Content) -> some View {
        MorphedView(blurRadius: blurRadius, insets: insets) {
            content
        } mask: {
            mask()
        }
    }
}

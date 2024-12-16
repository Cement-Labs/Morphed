//
//  MorphedView.swift
//  Playground
//
//  Created by KrLite on 2024/11/29.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

/// Applies a progressive gradient effect to a view.
public struct MorphedView<Content, Mask>: NSViewRepresentable where Content: View, Mask: View {
    public let blurRadius: CGFloat
    public let insets: MorphedInsets

    @ViewBuilder public var content: () -> Content
    @ViewBuilder public var mask: () -> Mask

    /// Initializes a ``MorphedView``.
    ///
    /// - Parameters:
    ///   - blurRadius: the maximum radius of the blur effect.
    ///   The final blur radius of every pixel will dynamically adjust based on the mask, where *full white* returns the maximum radius and *full black* returns zero.
    ///   - insets: the ``MorphedInsets`` that defines the insets of the blur effect.
    ///   - content: the content to apply the blur effect to.
    ///   - mask: the mask that configures the strength of the blur.
    public init(
        blurRadius: CGFloat = 50,
        insets: MorphedInsets = .init(),
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder mask: @escaping () -> Mask
    ) {
        self.blurRadius = blurRadius
        self.insets = insets
        self.content = content
        self.mask = mask
    }

    public func makeNSView(context _: Context) -> NSView {
        let view = NSHostingView(rootView: content())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = .clear

        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            view.topAnchor.constraint(equalTo: containerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        attachBlurView(to: containerView)

        return containerView
    }

    public func updateNSView(_: NSView, context _: Context) {}

    private func attachBlurView(to nsView: NSView) {
        guard let mask = renderToCGImage(view: mask) else { return }
        let blurView = MaskedVariableBlurView(mask: mask, blurRadius: blurRadius, insets: insets)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        nsView.addSubview(blurView, positioned: .above, relativeTo: nil)

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: nsView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: nsView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: nsView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: nsView.bottomAnchor),
        ])
    }

    private func renderToCGImage<C: View>(view _: @escaping () -> C) -> CGImage? {
        let renderer = ImageRenderer(content: mask())
        return renderer.cgImage
    }
}

#Preview {
    ZStack {
        Color.accentColor
        MorphedView(insets: .init(bottom: .fixed(length: 64).mirrored)) {
            ScrollView {
                LinearGradient(colors: [.red, .yellow, .green, .blue, .purple], startPoint: .top, endPoint: .bottom)
                    .frame(height: 1000)

                ForEach(0 ..< 100) { num in
                    Text("\(num)")
                        .font(.title)
                        .padding()
                }
            }
            .frame(minWidth: 200, minHeight: 300)
        } mask: {
            LinearGradient(colors: [.white, .black], startPoint: .top, endPoint: .bottom)
        }
    }
}

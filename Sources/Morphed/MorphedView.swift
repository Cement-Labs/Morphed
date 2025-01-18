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
    let isActive: Bool

    @ViewBuilder public var content: () -> Content
    @ViewBuilder public var mask: () -> Mask

    /// Initializes a ``MorphedView``.
    ///
    /// - Parameters:
    ///   - blurRadius: the maximum radius of the blur effect.
    ///   The final blur radius of every pixel will dynamically adjust based on the mask, where *full white* returns the maximum radius and *full black* returns zero.
    ///   - insets: the ``MorphedInsets`` that defines the insets of the blur effect.
    ///   - isActive: whether the blur effect is actively applied onto the content.
    ///   - content: the content to apply the blur effect to.
    ///   - mask: the mask that configures the strength of the blur.
    public init(
        blurRadius: CGFloat = 50,
        insets: MorphedInsets = .init(),
        isActive: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder mask: @escaping () -> Mask
    ) {
        self.blurRadius = blurRadius
        self.insets = insets
        self.isActive = isActive
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

        return containerView
    }

    public func updateNSView(_ view: NSView, context: Context) {
        if isActive {
            context.coordinator.attachBlurView(to: view)
        } else {
            context.coordinator.detachBlurView()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor public class Coordinator {
        var parent: MorphedView<Content, Mask>
        var blurView: MaskedVariableBlurView?

        init(parent: MorphedView<Content, Mask>, blurView: MaskedVariableBlurView? = nil) {
            self.parent = parent
            self.blurView = blurView
        }

        func attachBlurView(to nsView: NSView) {
            guard blurView == nil else { return }
            guard let mask = renderToCGImage(view: parent.mask) else { return }
            let blurView = MaskedVariableBlurView(mask: mask, blurRadius: parent.blurRadius, insets: parent.insets)

            blurView.translatesAutoresizingMaskIntoConstraints = false
            nsView.addSubview(blurView, positioned: .above, relativeTo: nil)

            NSLayoutConstraint.activate([
                blurView.leadingAnchor.constraint(equalTo: nsView.leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: nsView.trailingAnchor),
                blurView.topAnchor.constraint(equalTo: nsView.topAnchor),
                blurView.bottomAnchor.constraint(equalTo: nsView.bottomAnchor),
            ])

            self.blurView = blurView
        }

        func detachBlurView() {
            blurView?.removeFromSuperview()
            blurView = nil
        }

        private func renderToCGImage<C: View>(view: @escaping () -> C) -> CGImage? {
            let renderer = ImageRenderer(content: view())
            return renderer.cgImage
        }
    }
}

@available(macOS 15.0, *)
#Preview {
    @Previewable @State var isActive = true

    Toggle("Active", isOn: $isActive)

    ZStack {
        Color.accentColor
        MorphedView(insets: .init(bottom: .fixed(length: 64).mirrored), isActive: isActive) {
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

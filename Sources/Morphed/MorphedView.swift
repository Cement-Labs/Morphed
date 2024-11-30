//
//  MorphedView.swift
//  Playground
//
//  Created by KrLite on 2024/11/29.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

public struct MorphedView<Content, Mask>: NSViewRepresentable where Content: View, Mask: View {
    public var blurRadius: CGFloat = 50
    public var insets: MorphedInsets = .init()
    
    @ViewBuilder public let content: () -> Content
    @ViewBuilder public let mask: () -> Mask
    
    @State private var size: CGSize = .zero
    
    private var appliedInsets: EdgeInsets {
        insets.apply(to: size)
    }
    
    @MainActor public class Coordinator: NSObject {
        var parent: MorphedView
        
        init(parent: MorphedView) {
            self.parent = parent
        }
        
        @objc func frameChanged(_ notification: Notification) {
            if let view = notification.object as? NSView {
                DispatchQueue.main.async { [weak self] in
                    self?.parent.size = view.frame.size
                }
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public func makeNSView(context: Context) -> NSView {
        let view = NSHostingView(rootView: content())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = .clear
        
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = .clear
        
        containerView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            view.topAnchor.constraint(equalTo: containerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        containerView.postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.frameChanged(_:)),
            name: NSView.frameDidChangeNotification,
            object: containerView
        )
        
        return containerView
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) {
        let _ = size // important for triggering view update
        
        DispatchQueue.main.async {
            self.removeBlurView(from: nsView)
            self.attachBlurView(to: nsView)
        }
    }
    
    private func removeBlurView(from nsView: NSView) {
        nsView.subviews.filter { $0.tag == MaskedVariableBlurView.tag }.forEach { $0.removeFromSuperview() }
    }
    
    private func attachBlurView(to nsView: NSView) {
        guard let mask = renderToCGImage(view: mask) else { return }
        let blurView = MaskedVariableBlurView(mask: mask, blurRadius: blurRadius, insets: appliedInsets)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        nsView.addSubview(blurView, positioned: .above, relativeTo: nil)
        
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: nsView.leadingAnchor, constant: appliedInsets.leading),
            blurView.trailingAnchor.constraint(equalTo: nsView.trailingAnchor, constant: -appliedInsets.trailing),
            blurView.topAnchor.constraint(equalTo: nsView.topAnchor, constant: appliedInsets.top),
            blurView.bottomAnchor.constraint(equalTo: nsView.bottomAnchor, constant: -appliedInsets.bottom)
        ])
    }
    
    private func renderToCGImage<C: View>(view: @escaping () -> C) -> CGImage? {
        let renderer = ImageRenderer(content: mask())
        return renderer.cgImage
    }
}

#Preview {
    ZStack {
        Color.accentColor
        MorphedView(insets: .init(bottom: .fixed(length: 150).mirrored)) {
            ScrollView {
                LinearGradient(colors: [.red, .yellow, .green, .blue, .purple], startPoint: .top, endPoint: .bottom)
                    .frame(height: 1000)
                
                ForEach(0..<100) { num in
                    Text("\(num)")
                        .font(.title)
                        .padding()
                }
            }
            .frame(minWidth: 200, minHeight: 300)
        } mask: {
            LinearGradient(colors: [.white, .black], startPoint: .top, endPoint: .bottom)
            //        Color.white
        }
    }
}

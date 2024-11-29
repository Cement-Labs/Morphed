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
        let size = size // important for triggering view update
        
        DispatchQueue.main.async {
            self.removeBlurView(nsView)
            let blurView = self.attachBlurView(nsView)
            let insettedSize = size.applyingInsets(.init(top: appliedInsets.top, leading: 0, bottom: 0, trailing: appliedInsets.trailing))
        
            if let maskImage = renderToCGImage(size: insettedSize, view: mask) {
                let filter = CIFilter.maskedVariableBlur()
                filter.setDefaults()
                filter.setValue(CIImage(cgImage: maskImage), forKey: "inputMask")
                filter.radius = Float(self.blurRadius)
                
                blurView.prepare(filter: filter)
            }
        }
    }
    
    private func removeBlurView(_ nsView: NSView) {
        nsView.subviews.filter { $0.tag == FilterView.tag }.forEach { $0.removeFromSuperview() }
    }
    
    private func attachBlurView(_ nsView: NSView) -> FilterView {
        let blurView = FilterView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        nsView.addSubview(blurView, positioned: .above, relativeTo: nil)
        
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: nsView.leadingAnchor, constant: appliedInsets.leading),
            blurView.trailingAnchor.constraint(equalTo: nsView.trailingAnchor, constant: -appliedInsets.trailing),
            blurView.topAnchor.constraint(equalTo: nsView.topAnchor, constant: appliedInsets.top),
            blurView.bottomAnchor.constraint(equalTo: nsView.bottomAnchor, constant: -appliedInsets.bottom)
        ])
        print(blurView.bounds.origin)
        
        return blurView
    }
    
    private func renderToCGImage<C: View>(size: CGSize, view: @escaping () -> C) -> CGImage? {
        let renderer = ImageRenderer(content: mask())
        return renderer.cgImage.flatMap { resizeAndStretch($0, to: size) }
    }
    
    private func resizeAndStretch(_ image: CGImage, to size: CGSize) -> CGImage? {
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: 0,
            space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: image.bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        context.draw(image, in: CGRect(origin: .zero, size: size))
        return context.makeImage()
    }
}

#Preview {
    MorphedView(insets: .init(top: .fixed(length: 20), leading: .fixed(length: 50), bottom: .fixed(length: 100).mirrored, trailing: .fixed(length: 300).mirrored)) {
        ScrollView {
            LinearGradient(colors: [.red, .yellow, .green, .blue, .purple], startPoint: .top, endPoint: .bottom)
                .frame(height: 1000)
        }
        .frame(minWidth: 200, minHeight: 300)
    } mask: {
//        LinearGradient(colors: [.white, .black], startPoint: .top, endPoint: .bottom)
        Color.white
    }
}

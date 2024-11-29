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
    public var insets: EdgeInsets = .init()
    
    @ViewBuilder public let content: () -> Content
    @ViewBuilder public let mask: () -> Mask
    
    public func makeNSView(context: Context) -> NSView {
        let view = NSHostingView(rootView: content())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = .clear
        
        let containerView = NSView()
        containerView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            view.topAnchor.constraint(equalTo: containerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) {
        nsView.subviews.filter { $0.tag == FilterView.tag }.forEach { $0.removeFromSuperview() }
        
        let blurView = FilterView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        nsView.addSubview(blurView, positioned: .above, relativeTo: nil)
        
        DispatchQueue.main.async {
            let size = nsView.bounds.size
            let insettedSize = size.applyingInsets(insets)
            
            NSLayoutConstraint.activate([
                blurView.leadingAnchor.constraint(equalTo: nsView.leadingAnchor, constant: insets.leading),
                blurView.trailingAnchor.constraint(equalTo: nsView.trailingAnchor, constant: -insets.trailing),
                blurView.topAnchor.constraint(equalTo: nsView.topAnchor, constant: insets.top),
                blurView.bottomAnchor.constraint(equalTo: nsView.bottomAnchor, constant: -insets.bottom)
            ])
        
            if let maskImage = renderToCGImage(size: insettedSize, view: mask) {
                let filter = CIFilter.maskedVariableBlur()
                filter.setDefaults()
                filter.setValue(CIImage(cgImage: maskImage), forKey: "inputMask")
                filter.radius = Float(self.blurRadius)
                
                blurView.prepare(filter: filter)
            }
        }
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
    MorphedView(insets: .init(top: 50, leading: 0, bottom: 50, trailing: 0)) {
        ScrollView {
            LinearGradient(colors: [.red, .yellow, .green, .blue, .purple], startPoint: .top, endPoint: .bottom)
                .frame(height: 1000)
        }
        .frame(minWidth: 200, minHeight: 300)
    } mask: {
        LinearGradient(colors: [.white, .black], startPoint: .top, endPoint: .bottom)
    }
}

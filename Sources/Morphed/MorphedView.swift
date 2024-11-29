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
    public var frame: UnitFrame = .full
    
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
        nsView.subviews.filter { $0.tag == .max }.forEach { $0.removeFromSuperview() }
        
        let blurView = FilterView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        nsView.addSubview(blurView, positioned: .above, relativeTo: nil)
        
        DispatchQueue.main.async {
            let size = nsView.bounds.size
            let frame = frame.transform(in: size)
            
            NSLayoutConstraint.activate([
                blurView.leadingAnchor.constraint(equalTo: nsView.leadingAnchor, constant: frame.minX),
                blurView.trailingAnchor.constraint(equalTo: nsView.trailingAnchor, constant: frame.maxX - size.width),
                blurView.topAnchor.constraint(equalTo: nsView.topAnchor, constant: frame.maxY - size.height),
                blurView.bottomAnchor.constraint(equalTo: nsView.bottomAnchor, constant: frame.minY)
            ])
        
            if let maskImage = renderToCGImage(size: size, view: mask) {
                let filter = CIFilter.maskedVariableBlur()
                filter.setDefaults()
                filter.setValue(CIImage(cgImage: maskImage), forKey: "inputMask")
                filter.radius = Float(self.blurRadius)
//                let filter = CIFilter.gaussianBlur()
//                filter.setDefaults()
//                filter.radius = Float(self.blurRadius)
                
                blurView.prepare(filter: filter)
            }
        }
    }
    
    private func renderToCGImage<C: View>(size: CGSize, view: @escaping () -> C) -> CGImage? {
//        guard let context = CGContext(
//            data: nil,
//            width: Int(round(size.width)),
//            height: Int(round(size.height)),
//            bitsPerComponent: 8,
//            bytesPerRow: 0,
//            space: CGColorSpaceCreateDeviceGray(),
//            bitmapInfo: CGImageAlphaInfo.none.rawValue
//        ) else { return nil }
        
//        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: true)
//        NSGraphicsContext.current = graphicsContext
//        
//        hostingView.layer?.render(in: context)
//        
//        NSGraphicsContext.current = nil
        let renderer = ImageRenderer(content: mask())
        return renderer.cgImage
//
//        let colors: [NSColor] = [
//            .black,
//            .black,
//            .black,
//            .white,
//        ]
//        let cgcolors = colors.map { $0.cgColor } as CFArray
//        
//        guard
//            let gradient = CGGradient(
//                colorsSpace: CGColorSpaceCreateDeviceGray(),
//                colors: cgcolors,
//                locations: nil)
//        else { return nil }
//        
//        context.drawLinearGradient(
//            gradient,
//            start: CGPoint(x: 0, y: 0),
//            end: CGPoint(x: 0, y: size.height),
//            options: [])  //[.drawsBeforeStartLocation, .drawsAfterEndLocation])
//        return context.makeImage()
    }
}

#Preview {
    MorphedView {
        ScrollView {
            LinearGradient(colors: [.red, .yellow, .green, .blue, .purple], startPoint: .top, endPoint: .bottom)
                .frame(width: 200, height: 1000)
        }
        .frame(height: 300)
    } mask: {
        Color.white.frame(width: 200, height: 500)
    }
}

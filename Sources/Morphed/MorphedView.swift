//
//  MorphedView.swift
//  Playground
//
//  Created by KrLite on 2024/11/29.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct MorphedView<Content>: NSViewRepresentable where Content: View {
    var blurRadius: CGFloat = 50
    var position: UnitP
    
    @ViewBuilder let content: () -> Content
    
    func makeNSView(context: Context) -> NSView {
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
    
    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.subviews.filter { $0.tag == .max }.forEach { $0.removeFromSuperview() }
        
        let blurView = FilterView()
        blurView.translatesAutoresizingMaskIntoConstraints = false
        nsView.addSubview(blurView, positioned: .above, relativeTo: nil)
        
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: nsView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: nsView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: nsView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: nsView.bottomAnchor)
        ])
        
        DispatchQueue.main.async {
            blurView.prepare()
        }
    }
}

#Preview {
    MorphedView {
        ScrollView {
            LinearGradient(colors: [.red, .yellow, .green, .blue, .purple], startPoint: .top, endPoint: .bottom)
                .frame(width: 200, height: 1000)
        }
        .frame(height: 300)
    }
}

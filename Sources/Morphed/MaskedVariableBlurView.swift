//
//  MaskedVariableBlurView.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

//
//  From https://github.com/usagimaru/ProgressiveBlur
//  Copyright © 2018 usagimaru.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

public class MaskedVariableBlurView: NSView {
    public static let tag: Int = 8080
    private var _tag: Int
    
    var mask: CGImage
    var blurRadius: CGFloat
    var insets: MorphedInsets
    
    private var maskLayer: CALayer = .init()
    
    init(tag: Int = MaskedVariableBlurView.tag, mask: CGImage, blurRadius: CGFloat, insets: MorphedInsets) {
        self._tag = tag
        self.mask = mask
        self.blurRadius = blurRadius
        self.insets = insets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func prepare(filter: CIFilter) {
        wantsLayer = true
        layerUsesCoreImageFilters = true
        layerContentsRedrawPolicy = .duringViewResize
        layer?.backgroundColor = .clear
        layer?.backgroundFilters = [filter]
        
        maskLayer.backgroundColor = .white
        layer?.mask = maskLayer
    }

    public override var tag: Int {
        get {
            _tag
        }

        set {
            _tag = newValue
        }
    }
    
    public override func layout() {
        super.layout()
        
        let size = bounds.size
        let insets = insets.apply(to: size)
        let frame = size.applyingInsets(insets) // the insetted frame
        
        maskLayer.frame = frame
        guard let mask = resizeAndStretch(mask, to: size, in: frame) else { return }
        
        let filter = CIFilter.maskedVariableBlur()
        filter.setDefaults()
        filter.setValue(CIImage(cgImage: mask), forKey: "inputMask")
        filter.radius = Float(blurRadius)
        
        prepare(filter: filter)
    }
    
    private func resizeAndStretch(_ image: CGImage, to size: CGSize, in frame: CGRect) -> CGImage? {
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
        
        context.draw(image, in: frame)
        return context.makeImage()
    }
}

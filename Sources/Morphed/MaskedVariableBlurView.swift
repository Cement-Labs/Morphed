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
    
    var mask: CIImage
    var blurRadius: CGFloat
    var insets: EdgeInsets
    
    init(tag: Int = MaskedVariableBlurView.tag, mask: CIImage, blurRadius: CGFloat, insets: EdgeInsets) {
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
        layer?.masksToBounds = true
        layer?.backgroundFilters = [filter]
        layer?.contentsGravity = .resize
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
        
        let scaledMask = mask.transformed(by: .init(
            scaleX: bounds.width / mask.extent.width, y: bounds.height / mask.extent.height
        ))
        
        let filter = CIFilter.maskedVariableBlur()
        filter.setDefaults()
        filter.setValue(scaledMask, forKey: "inputMask")
        filter.radius = Float(blurRadius)
        prepare(filter: filter)
    }
}

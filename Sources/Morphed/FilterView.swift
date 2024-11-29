//
//  FilterView.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

//
//  From https://github.com/usagimaru/ProgressiveBlur
//  Copyright © 2018 usagimaru.
//

import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

public class FilterView: NSView {
    public static let tag: Int = 8080
    private var _tag: Int = FilterView.tag

    public func prepare(filter: CIFilter) {
        wantsLayer = true
        layerUsesCoreImageFilters = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.masksToBounds = true
        layer?.backgroundFilters = [filter]
    }

    public override var tag: Int {
        get {
            _tag
        }

        set {
            _tag = newValue
        }
    }
}

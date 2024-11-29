//
//  CALayer+Extensions.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

//
//  From https://github.com/usagimaru/ProgressiveBlur
//  Copyright © 2018 usagimaru.
//

import QuartzCore

extension CALayer {
    func setBorderColor(
        _ color: CGColor?, width: CGFloat = 1.0
    ) {
        borderColor = color
        borderWidth = width
    }

    func setCornerRadius(
        _ radius: CGFloat, curve: CALayerCornerCurve = .continuous
    ) {
        cornerRadius = radius
        cornerCurve = curve
    }

    class func animate(
        enabled: Bool, duration: TimeInterval? = nil, animations: () -> Void,
        completionHandler: (() -> Void)? = nil
    ) {
        CATransaction.begin()
        CATransaction.setDisableActions(!enabled)
        CATransaction.setCompletionBlock(completionHandler)

        if enabled {
            CATransaction.setAnimationDuration(
                duration ?? CATransaction.animationDuration())
        } else {
            CATransaction.setAnimationDuration(0)
        }

        animations()

        CATransaction.commit()
    }

    class func disableAnimations(
        _ animationHandler: () -> Void, completionHandler: (() -> Void)? = nil
    ) {
        animate(
            enabled: false, animations: animationHandler,
            completionHandler: completionHandler)
    }
}

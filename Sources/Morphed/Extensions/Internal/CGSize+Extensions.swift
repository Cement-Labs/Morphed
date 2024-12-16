//
//  CGSize+Extensions.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

import SwiftUI

extension CGSize {
    func applyingInsets(_ insets: EdgeInsets, sign: FloatingPointSign = .minus) -> CGRect {
        let sign: CGFloat = switch sign {
        case .plus: 1
        case .minus: -1
        }
        let newWidth = width + sign * (insets.leading + insets.trailing)
        let newHeight = height + sign * (insets.top + insets.bottom)
        return .init(
            x: insets.leading, y: insets.bottom,
            width: max(0, newWidth), height: max(0, newHeight)
        )
    }

    func translatingInsets(_ insets: EdgeInsets, sign: FloatingPointSign = .plus) -> CGRect {
        let sign: CGFloat = switch sign {
        case .plus: 1
        case .minus: -1
        }
        return .init(origin: .init(x: sign * insets.leading, y: sign * insets.bottom), size: self)
    }
}

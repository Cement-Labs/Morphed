//
//  CGSize+Extensions.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

import SwiftUI

extension CGSize {
    func applyingInsets(_ insets: EdgeInsets) -> CGSize {
        let newWidth = self.width - (insets.leading + insets.trailing)
        let newHeight = self.height - (insets.top + insets.bottom)
        return CGSize(width: max(0, newWidth), height: max(0, newHeight))
    }
}

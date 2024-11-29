//
//  UnitFrame.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

import SwiftUI

public struct UnitFrame {
    public var start: UnitPoint
    public var end: UnitPoint
    
    public init(start: UnitPoint = .topLeading, end: UnitPoint = .bottomTrailing) {
        self.start = start
        self.end = end
    }
    
    public init(origin: UnitPoint = .topLeading, size: CGSize) {
        self.init(start: origin, end: .init(x: origin.x + size.width, y: origin.y + size.height))
    }
    
    public init(area: CGRect, in size: CGSize = .init(width: 1, height: 1)) {
        self.init(
            origin: .init(x: area.origin.x / size.width, y: area.origin.y / size.height),
            size: .init(width: area.width / size.width, height: area.height / size.height)
        )
    }
    
    public init(padding: CGFloat, in size: CGSize = .init(width: 1, height: 1)) {
        let horizontal = padding / size.width, vertical = padding / size.height
        let horizontalMax = size.width / 2, verticalMax = size.height / 2
        let x = min(horizontal, horizontalMax) / size.width, y = min(vertical, verticalMax) / size.height
        self.init(
            start: .init(x: x, y: y),
            end: .init(x: 1 - x, y: 1 - y)
        )
    }
    
    public init(_ edge: Edge, proportional: CGFloat) {
        switch edge {
        case .top:
            self.init(end: .init(x: 1, y: proportional))
        case .leading:
            self.init(end: .init(x: proportional, y: 1))
        case .bottom:
            self.init(start: .init(x: 0, y: 1 - proportional))
        case .trailing:
            self.init(start: .init(x: 1 - proportional, y: 0))
        }
    }
    
    public var size: CGSize {
        .init(width: end.x - start.x, height: end.y - start.y)
    }
    
    public func transform(in size: CGSize) -> CGRect {
        .init(
            x: start.x * size.width, y: start.y * size.height,
            width: self.size.width * size.width, height: self.size.height * size.height
        )
    }
}

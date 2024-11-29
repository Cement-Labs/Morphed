//
//  MorphedInsets.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

import SwiftUI

public enum MorphedInset: Hashable, Equatable {
    case fixed(length: CGFloat)
    case fixedMirrored(length: CGFloat)
    case relative(factor: CGFloat)
    case relativeMirrored(factor: CGFloat)
    
    public static var fixed: Self {
        .fixed(length: .zero)
    }
    
    public static var fixedMirrored: Self {
        .fixedMirrored(length: .zero)
    }
    
    public static var relative: Self {
        .relative(factor: .zero)
    }
    
    public static var relativeMirrored: Self {
        .relativeMirrored(factor: .zero)
    }
    
    public var mirrored: Self {
        switch self {
        case .fixed(let length):
                .fixedMirrored(length: length)
        case .fixedMirrored(let length):
                .fixed(length: length)
        case .relative(let factor):
                .relativeMirrored(factor: factor)
        case .relativeMirrored(let factor):
                .relative(factor: factor)
        }
    }
    
    public func apply(to total: CGFloat) -> CGFloat {
        switch self {
        case .fixed(let length):
            length
        case .fixedMirrored(let length):
            total - length
        case .relative(let factor):
            total * factor
        case .relativeMirrored(let factor):
            total * (1 - factor)
        }
    }
}

public struct MorphedInsets: Hashable, Equatable {
    public var top: MorphedInset = .fixed
    public var leading: MorphedInset = .fixed
    public var bottom: MorphedInset = .fixed
    public var trailing: MorphedInset = .fixed
    
    public init(
        top: MorphedInset = .fixed,
        leading: MorphedInset = .fixed,
        bottom: MorphedInset = .fixed,
        trailing: MorphedInset = .fixed
    ) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
    
    public func apply(to size: CGSize) -> EdgeInsets {
        .init(
            top: top.apply(to: size.height),
            leading: leading.apply(to: size.width),
            bottom: bottom.apply(to: size.height),
            trailing: trailing.apply(to: size.width)
        )
    }
}

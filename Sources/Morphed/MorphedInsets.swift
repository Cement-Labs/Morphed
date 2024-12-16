//
//  MorphedInsets.swift
//  Morphed
//
//  Created by KrLite on 2024/11/29.
//

import SwiftUI

/// Insets the blur effect in one edge base on a fixed or relative constraint.
public enum MorphedInset: Hashable, Equatable {
    /// A fixed inset.
    ///
    /// - Parameters:
    ///   - length: the fixed length to inset.
    case fixed(length: CGFloat)

    /// A fixed, mirrored inset.
    ///
    /// - Parameters:
    ///   - length: the fixed length to inset from the mirrored direction.
    case fixedMirrored(length: CGFloat)

    /// A relative inset.
    ///
    /// - Parameters:
    ///   - factor: the relative factor to inset, representing a proportional length of the applied view.
    case relative(factor: CGFloat)

    /// A relative, mirrored inset.
    ///
    /// - Parameters:
    ///   - factor: the relative factor to inset from the mirrored direction, representing a proportional length of the applied view.
    case relativeMirrored(factor: CGFloat)

    /// A fixed inset.
    public static var fixed: Self {
        .fixed(length: .zero)
    }

    /// A fixed, mirrored inset.
    public static var fixedMirrored: Self {
        .fixedMirrored(length: .zero)
    }

    /// A relative inset.
    public static var relative: Self {
        .relative(factor: .zero)
    }

    /// A relative, mirrored inset.
    public static var relativeMirrored: Self {
        .relativeMirrored(factor: .zero)
    }

    /// The mirrored inset.
    ///
    /// This is often useful to specify an inset that starts from one edge, but constraints the opposite edge.
    public var mirrored: Self {
        switch self {
        case let .fixed(length):
            .fixedMirrored(length: length)
        case let .fixedMirrored(length):
            .fixed(length: length)
        case let .relative(factor):
            .relativeMirrored(factor: factor)
        case let .relativeMirrored(factor):
            .relative(factor: factor)
        }
    }

    /// Applies the inset to a length.
    ///
    /// - Parameters:
    ///   - to: the total length to apply.
    public func apply(to total: CGFloat) -> CGFloat {
        switch self {
        case let .fixed(length):
            length
        case let .fixedMirrored(length):
            total - length
        case let .relative(factor):
            total * factor
        case let .relativeMirrored(factor):
            total * (1 - factor)
        }
    }
}

/// Insets the blur effect base on fixed or relative constraints.
public struct MorphedInsets: Hashable, Equatable {
    /// The ``MorphedInset`` for the top edge.
    public var top: MorphedInset = .fixed
    /// The ``MorphedInset`` for the leading edge.
    public var leading: MorphedInset = .fixed
    /// The ``MorphedInset`` for the bottom edge.
    public var bottom: MorphedInset = .fixed
    /// The ``MorphedInset`` for the trailing edge.
    public var trailing: MorphedInset = .fixed

    /// Initializes a ``MorphedInsets``.
    ///
    /// - Parameters:
    ///   - top: the inset for the top edge.
    ///   - leading: the inset for the leading edge.
    ///   - bottom: the inset for the bottom edge.
    ///   - trailing: the inset for the trailing edge.
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

    /// Applies the insets to a size.
    ///
    /// - Parameters:
    ///   - to: the size to apply.
    public func apply(to size: CGSize) -> EdgeInsets {
        .init(
            top: top.apply(to: size.height),
            leading: leading.apply(to: size.width),
            bottom: bottom.apply(to: size.height),
            trailing: trailing.apply(to: size.width)
        )
    }
}

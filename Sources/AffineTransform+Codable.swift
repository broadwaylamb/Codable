//
//  AffineTransform+Codable.swift
//  Codable
//
//  Created by Sergej Jaskiewicz on 31/07/2017.
//
//

import Foundation

#if swift(>=3.2)
#else

#if os(macOS)
extension AffineTransform : Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        m11 = try container.decode(CGFloat.self)
        m12 = try container.decode(CGFloat.self)
        m21 = try container.decode(CGFloat.self)
        m22 = try container.decode(CGFloat.self)
        tX  = try container.decode(CGFloat.self)
        tY  = try container.decode(CGFloat.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.m11)
        try container.encode(self.m12)
        try container.encode(self.m21)
        try container.encode(self.m22)
        try container.encode(self.tX)
        try container.encode(self.tY)
    }
}
#endif

#endif

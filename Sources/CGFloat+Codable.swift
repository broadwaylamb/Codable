//
//  CGFloat+Codable.swift
//  Codable
//
//  Created by Sergej Jaskiewicz on 31/07/2017.
//
//

import Foundation
import CoreGraphics

#if swift(>=3.2)
#else

extension CGFloat : Codable {
    @_transparent
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self.native = try container.decode(NativeType.self)
        } catch DecodingError.typeMismatch(let type, let context) {
            // We may have encoded as a different type on a different platform. A
            // strict fixed-format decoder may disallow a conversion, so let's try the
            // other type.
            do {
                if NativeType.self == Float.self {
                    self.native = NativeType(try container.decode(Double.self))
                } else {
                    self.native = NativeType(try container.decode(Float.self))
                }
            } catch {
                // Failed to decode as the other type, too. This is neither a Float nor
                // a Double. Throw the old error; we don't want to clobber the original
                // info.
                throw DecodingError.typeMismatch(type, context)
            }
        }
    }

    @_transparent
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.native)
    }
}

#endif

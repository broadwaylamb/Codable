// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// RUN: %target-run-simple-swift
// REQUIRES: executable_test
// REQUIRES: objc_interop

import Foundation
import CoreGraphics
import Codable

import XCTest
class TestCodableSuper : XCTestCase { }

// MARK: - Helper Functions
@available(OSX 10.11, iOS 9.0, *)
func makePersonNameComponents(namePrefix: String? = nil,
                              givenName: String? = nil,
                              middleName: String? = nil,
                              familyName: String? = nil,
                              nameSuffix: String? = nil,
                              nickname: String? = nil) -> PersonNameComponents {
    var result = PersonNameComponents()
    result.namePrefix = namePrefix
    result.givenName = givenName
    result.middleName = middleName
    result.familyName = familyName
    result.nameSuffix = nameSuffix
    result.nickname = nickname
    return result
}

func debugDescription<T>(_ value: T) -> String {
    if let debugDescribable = value as? CustomDebugStringConvertible {
        return debugDescribable.debugDescription
    } else if let describable = value as? CustomStringConvertible {
        return describable.description
    } else {
        return "\(value)"
    }
}

func expectRoundTripEquality<T : Codable>(of value: T, encode: (T) throws -> Data, decode: (Data) throws -> T, lineNumber: Int) where T : Equatable {
    let data: Data
    do {
        data = try encode(value)
    } catch {
        fatalError("\(#file):\(lineNumber): Unable to encode \(T.self) <\(debugDescription(value))>: \(error)")
    }

    let decoded: T
    do {
        decoded = try decode(data)
    } catch {
        fatalError("\(#file):\(lineNumber): Unable to decode \(T.self) <\(debugDescription(value))>: \(error)")
    }
    XCTAssertEqual(value, decoded, "\(#file):\(lineNumber): Decoded \(T.self) <\(debugDescription(decoded))> not equal to original <\(debugDescription(value))>")
}

func expectRoundTripEqualityThroughJSON<T : Codable>(for value: T, lineNumber: Int) where T : Equatable {
    let inf = "INF", negInf = "-INF", nan = "NaN"
    let encode = { (_ value: T) throws -> Data in
        let encoder = BackportJSONEncoder()
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: inf,
                                                                      negativeInfinity: negInf,
                                                                      nan: nan)
        return try encoder.encode(value)
    }

    let decode = { (_ data: Data) throws -> T in
        let decoder = BackportJSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: inf,
                                                                        negativeInfinity: negInf,
                                                                        nan: nan)
        return try decoder.decode(T.self, from: data)
    }

    expectRoundTripEquality(of: value, encode: encode, decode: decode, lineNumber: lineNumber)
}

// MARK: - Helper Types
// A wrapper around a UUID that will allow it to be encoded at the top level of an encoder.
struct UUIDCodingWrapper : Codable, Equatable {
    let value: UUID

    init(_ value: UUID) {
        self.value = value
    }

    static func ==(_ lhs: UUIDCodingWrapper, _ rhs: UUIDCodingWrapper) -> Bool {
        return lhs.value == rhs.value
    }
}

// MARK: - Tests
class TestCodable : TestCodableSuper {
    // MARK: - AffineTransform
    #if os(macOS)
    lazy var affineTransformValues: [Int : AffineTransform] = [
        #line : AffineTransform.identity,
        #line : AffineTransform(),
        #line : AffineTransform(translationByX: 2.0, byY: 2.0),
        #line : AffineTransform(scale: 2.0),
        #line : AffineTransform(rotationByDegrees: .pi / 2),

        #line : AffineTransform(m11: 1.0, m12: 2.5, m21: 66.2, m22: 40.2, tX: -5.5, tY: 3.7),
        #line : AffineTransform(m11: -55.66, m12: 22.7, m21: 1.5, m22: 0.0, tX: -22, tY: -33),
        #line : AffineTransform(m11: 4.5, m12: 1.1, m21: 0.025, m22: 0.077, tX: -0.55, tY: 33.2),
        #line : AffineTransform(m11: 7.0, m12: -2.3, m21: 6.7, m22: 0.25, tX: 0.556, tY: 0.99),
        #line : AffineTransform(m11: 0.498, m12: -0.284, m21: -0.742, m22: 0.3248, tX: 12, tY: 44)
    ]

    func test_AffineTransform_JSON() {
        for (testLine, transform) in affineTransformValues {
            expectRoundTripEqualityThroughJSON(for: transform, lineNumber: testLine)
        }
    }

    #endif

    // MARK: - Calendar
    lazy var calendarValues: [Int : Calendar] = [
        #line : Calendar(identifier: .gregorian),
        #line : Calendar(identifier: .buddhist),
        #line : Calendar(identifier: .chinese),
        #line : Calendar(identifier: .coptic),
        #line : Calendar(identifier: .ethiopicAmeteMihret),
        #line : Calendar(identifier: .ethiopicAmeteAlem),
        #line : Calendar(identifier: .hebrew),
        #line : Calendar(identifier: .iso8601),
        #line : Calendar(identifier: .indian),
        #line : Calendar(identifier: .islamic),
        #line : Calendar(identifier: .islamicCivil),
        #line : Calendar(identifier: .japanese),
        #line : Calendar(identifier: .persian),
        #line : Calendar(identifier: .republicOfChina),
        ]

    func test_Calendar_JSON() {
        for (testLine, calendar) in calendarValues {
            expectRoundTripEqualityThroughJSON(for: calendar, lineNumber: testLine)
        }
    }

    // MARK: - CharacterSet
    lazy var characterSetValues: [Int : CharacterSet] = [
        #line : CharacterSet.controlCharacters,
        #line : CharacterSet.whitespaces,
        #line : CharacterSet.whitespacesAndNewlines,
        #line : CharacterSet.decimalDigits,
        #line : CharacterSet.letters,
        #line : CharacterSet.lowercaseLetters,
        #line : CharacterSet.uppercaseLetters,
        #line : CharacterSet.nonBaseCharacters,
        #line : CharacterSet.alphanumerics,
        #line : CharacterSet.decomposables,
        #line : CharacterSet.illegalCharacters,
        #line : CharacterSet.punctuationCharacters,
        #line : CharacterSet.capitalizedLetters,
        #line : CharacterSet.symbols,
        #line : CharacterSet.newlines
    ]

    func test_CharacterSet_JSON() {
        for (testLine, characterSet) in characterSetValues {
            expectRoundTripEqualityThroughJSON(for: characterSet, lineNumber: testLine)
        }
    }

    // MARK: - CGAffineTransform
    lazy var cg_affineTransformValues: [Int : CGAffineTransform] = {
        var values = [
            #line : CGAffineTransform.identity,
            #line : CGAffineTransform(),
            #line : CGAffineTransform(translationX: 2.0, y: 2.0),
            #line : CGAffineTransform(scaleX: 2.0, y: 2.0),
            #line : CGAffineTransform(a: 1.0, b: 2.5, c: 66.2, d: 40.2, tx: -5.5, ty: 3.7),
            #line : CGAffineTransform(a: -55.66, b: 22.7, c: 1.5, d: 0.0, tx: -22, ty: -33),
            #line : CGAffineTransform(a: 4.5, b: 1.1, c: 0.025, d: 0.077, tx: -0.55, ty: 33.2),
            #line : CGAffineTransform(a: 7.0, b: -2.3, c: 6.7, d: 0.25, tx: 0.556, ty: 0.99),
            #line : CGAffineTransform(a: 0.498, b: -0.284, c: -0.742, d: 0.3248, tx: 12, ty: 44)
        ]

        if #available(OSX 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) {
            values[#line] = CGAffineTransform(rotationAngle: .pi / 2)
        }

        return values
    }()

    func test_CGAffineTransform_JSON() {
        for (testLine, transform) in cg_affineTransformValues {
            expectRoundTripEqualityThroughJSON(for: transform, lineNumber: testLine)
        }
    }

    // MARK: - CGPoint
    lazy var cg_pointValues: [Int : CGPoint] = {
        var values = [
            #line : CGPoint.zero,
            #line : CGPoint(x: 10, y: 20)
        ]

        if #available(OSX 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) {
            // Limit on magnitude in JSON. See rdar://problem/12717407
            values[#line] = CGPoint(x: CGFloat.greatestFiniteMagnitude,
                                    y: CGFloat.greatestFiniteMagnitude)
        }

        return values
    }()

    func test_CGPoint_JSON() {
        for (testLine, point) in cg_pointValues {
            expectRoundTripEqualityThroughJSON(for: point, lineNumber: testLine)
        }
    }

    // MARK: - CGSize
    lazy var cg_sizeValues: [Int : CGSize] = {
        var values = [
            #line : CGSize.zero,
            #line : CGSize(width: 30, height: 40)
        ]

        if #available(OSX 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) {
            // Limit on magnitude in JSON. See rdar://problem/12717407
            values[#line] = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                   height: CGFloat.greatestFiniteMagnitude)
        }

        return values
    }()

    func test_CGSize_JSON() {
        for (testLine, size) in cg_sizeValues {
            expectRoundTripEqualityThroughJSON(for: size, lineNumber: testLine)
        }
    }

    // MARK: - CGRect
    lazy var cg_rectValues: [Int : CGRect] = {
        var values = [
            #line : CGRect.zero,
            #line : CGRect.null,
            #line : CGRect(x: 10, y: 20, width: 30, height: 40)
        ]

        if #available(OSX 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) {
            // Limit on magnitude in JSON. See rdar://problem/12717407
            values[#line] = CGRect.infinite
        }

        return values
    }()

    func test_CGRect_JSON() {
        for (testLine, rect) in cg_rectValues {
            expectRoundTripEqualityThroughJSON(for: rect, lineNumber: testLine)
        }
    }

    // MARK: - CGVector
    lazy var cg_vectorValues: [Int : CGVector] = {
        var values = [
            #line : CGVector.zero,
            #line : CGVector(dx: 0.0, dy: -9.81)
        ]

        if #available(OSX 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) {
            // Limit on magnitude in JSON. See rdar://problem/12717407
            values[#line] = CGVector(dx: CGFloat.greatestFiniteMagnitude,
                                     dy: CGFloat.greatestFiniteMagnitude)
        }

        return values
    }()

    func test_CGVector_JSON() {
        for (testLine, vector) in cg_vectorValues {
            expectRoundTripEqualityThroughJSON(for: vector, lineNumber: testLine)
        }
    }


    // MARK: - DateComponents
    lazy var dateComponents: Set<Calendar.Component> = [
        .era, .year, .month, .day, .hour, .minute, .second, .nanosecond,
        .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear,
        .yearForWeekOfYear, .timeZone, .calendar
    ]

    func test_DateComponents_JSON() {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(dateComponents, from: Date())
        expectRoundTripEqualityThroughJSON(for: components, lineNumber: #line - 1)
    }

    // MARK: - DateInterval
    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    lazy var dateIntervalValues: [Int : DateInterval] = [
        #line : DateInterval(),
        #line : DateInterval(start: Date.distantPast, end: Date()),
        #line : DateInterval(start: Date(), end: Date.distantFuture),
        #line : DateInterval(start: Date.distantPast, end: Date.distantFuture)
    ]

    @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    func test_DateInterval_JSON() {
        for (testLine, interval) in dateIntervalValues {
            expectRoundTripEqualityThroughJSON(for: interval, lineNumber: testLine)
        }
    }

    // MARK: - Decimal
    lazy var decimalValues: [Int : Decimal] = [
        #line : Decimal.leastFiniteMagnitude,
        #line : Decimal.greatestFiniteMagnitude,
        #line : Decimal.leastNormalMagnitude,
        #line : Decimal.leastNonzeroMagnitude,
        #line : Decimal(),
        #line : Decimal(string: "67.52")!,

        // See 33996620 for re-enabling this test.
        // #line : Decimal.pi,
    ]

    func test_Decimal_JSON() {
        for (testLine, decimal) in decimalValues {
            // Decimal encodes as a number in JSON and cannot be encoded at the top level.
            expectRoundTripEqualityThroughJSON(for: TopLevelWrapper(decimal), lineNumber: testLine)
        }
    }

    // MARK: - IndexPath
    lazy var indexPathValues: [Int : IndexPath] = [
        #line : IndexPath(), // empty
        #line : IndexPath(index: 0), // single
        #line : IndexPath(indexes: [1, 2]), // pair
        #line : IndexPath(indexes: [3, 4, 5, 6, 7, 8]), // array
    ]

    func test_IndexPath_JSON() {
        for (testLine, indexPath) in indexPathValues {
            expectRoundTripEqualityThroughJSON(for: indexPath, lineNumber: testLine)
        }
    }

    // MARK: - IndexSet
    lazy var indexSetValues: [Int : IndexSet] = [
        #line : IndexSet(),
        #line : IndexSet(integer: 42),
        #line : IndexSet(integersIn: 0 ..< Int.max)
    ]

    func test_IndexSet_JSON() {
        for (testLine, indexSet) in indexSetValues {
            expectRoundTripEqualityThroughJSON(for: indexSet, lineNumber: testLine)
        }
    }

    // MARK: - Locale
    lazy var localeValues: [Int : Locale] = [
        #line : Locale(identifier: ""),
        #line : Locale(identifier: "en"),
        #line : Locale(identifier: "en_US"),
        #line : Locale(identifier: "en_US_POSIX"),
        #line : Locale(identifier: "uk"),
        #line : Locale(identifier: "fr_FR"),
        #line : Locale(identifier: "fr_BE"),
        #line : Locale(identifier: "zh-Hant-HK")
    ]

    func test_Locale_JSON() {
        for (testLine, locale) in localeValues {
            expectRoundTripEqualityThroughJSON(for: locale, lineNumber: testLine)
        }
    }

    // MARK: - NSRange
    lazy var nsrangeValues: [Int : NSRange] = [
        #line : NSRange(),
        #line : NSRange(location: 0, length: Int.max),
        #line : NSRange(location: NSNotFound, length: 0),
    ]

    func test_NSRange_JSON() {
        for (testLine, range) in nsrangeValues {
            expectRoundTripEqualityThroughJSON(for: range, lineNumber: testLine)
        }
    }

    // MARK: - PersonNameComponents
    @available(OSX 10.11, iOS 9.0, *)
    lazy var personNameComponentsValues: [Int : PersonNameComponents] = [
        #line : makePersonNameComponents(givenName: "John", familyName: "Appleseed"),
        #line : makePersonNameComponents(givenName: "John", familyName: "Appleseed", nickname: "Johnny"),
        #line : makePersonNameComponents(namePrefix: "Dr.", givenName: "Jane", middleName: "A.", familyName: "Appleseed", nameSuffix: "Esq.", nickname: "Janie")
    ]

    @available(OSX 10.11, iOS 9.0, *)
    func test_PersonNameComponents_JSON() {
        for (testLine, components) in personNameComponentsValues {
            expectRoundTripEqualityThroughJSON(for: components, lineNumber: testLine)
        }
    }

    // MARK: - TimeZone
    lazy var timeZoneValues: [Int : TimeZone] = [
        #line : TimeZone(identifier: "America/Los_Angeles")!,
        #line : TimeZone(identifier: "UTC")!,
        #line : TimeZone.current
    ]

    func test_TimeZone_JSON() {
        for (testLine, timeZone) in timeZoneValues {
            expectRoundTripEqualityThroughJSON(for: timeZone, lineNumber: testLine)
        }
    }

    // MARK: - URL
    lazy var urlValues: [Int : URL] = {
        var values: [Int : URL] = [
            #line : URL(fileURLWithPath: NSTemporaryDirectory()),
            #line : URL(fileURLWithPath: "/"),
            #line : URL(string: "http://swift.org")!,
            #line : URL(string: "documentation", relativeTo: URL(string: "http://swift.org")!)!
        ]

        if #available(OSX 10.11, iOS 9.0, *) {
            values[#line] = URL(fileURLWithPath: "bin/sh", relativeTo: URL(fileURLWithPath: "/"))
        }

        return values
    }()

    func test_URL_JSON() {
        for (testLine, url) in urlValues {
            // URLs encode as single strings in JSON. They lose their baseURL this way.
            // For relative URLs, we don't expect them to be equal to the original.
            if url.baseURL == nil {
                // This is an absolute URL; we can expect equality.
                expectRoundTripEqualityThroughJSON(for: TopLevelWrapper(url), lineNumber: testLine)
            } else {
                // This is a relative URL. Make it absolute first.
                let absoluteURL = URL(string: url.absoluteString)!
                expectRoundTripEqualityThroughJSON(for: TopLevelWrapper(absoluteURL), lineNumber: testLine)
            }
        }
    }

    // MARK: - UUID
    lazy var uuidValues: [Int : UUID] = [
        #line : UUID(),
        #line : UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
        #line : UUID(uuidString: "e621e1f8-c36c-495a-93fc-0c247a3e6e5f")!,
        #line : UUID(uuid: uuid_t(0xe6,0x21,0xe1,0xf8,0xc3,0x6c,0x49,0x5a,0x93,0xfc,0x0c,0x24,0x7a,0x3e,0x6e,0x5f))
    ]

    func test_UUID_JSON() {
        for (testLine, uuid) in uuidValues {
            // We have to wrap the UUID since we cannot have a top-level string.
            expectRoundTripEqualityThroughJSON(for: UUIDCodingWrapper(uuid), lineNumber: testLine)
        }
    }
}

// MARK: - Helper Types

struct TopLevelWrapper<T> : Codable, Equatable where T : Codable, T : Equatable {

    private enum CodingKeys: String, CodingKey {
        case value
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(T.self, forKey: .value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }

    let value: T

    init(_ value: T) {
        self.value = value
    }

    static func ==(_ lhs: TopLevelWrapper<T>, _ rhs: TopLevelWrapper<T>) -> Bool {
        return lhs.value == rhs.value
    }
}

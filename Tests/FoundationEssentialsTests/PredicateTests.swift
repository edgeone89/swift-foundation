//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022-2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#if canImport(TestSupport)
import TestSupport
#endif

final class PredicateTests: XCTestCase {
    
    override func setUp() async throws {
        guard #available(macOS 14, iOS 17, tvOS 17, watchOS 10, *) else {
            throw XCTSkip("This test is not available on this OS version")
        }
    }
    
    struct Object {
        var a: Int
        var b: String
        var c: Double
        var d: Int
        var e: Character
        var f: Bool
        var g: [Int]
        var h: Date = .now
    }
    
    struct Object2 {
        var a: Bool
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testBasic() throws {
        let compareTo = 2
        let predicate = Predicate<Object> {
            // $0.a == compareTo
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: $0,
                        keyPath: \.a
                    )
                ),
                rhs: PredicateExpressions.build_Arg(compareTo)
            )
        }
        try XCTAssertFalse(predicate.evaluate(Object(a: 1, b: "", c: 0, d: 0, e: "c", f: true, g: [])))
        try XCTAssertTrue(predicate.evaluate(Object(a: 2, b: "", c: 0, d: 0, e: "c", f: true, g: [])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testBasicMacro() throws {
#if compiler(<5.9) || os(Windows)
        throw XCTSkip("Macros are not supported on this platform")
#else
        let compareTo = 2
        let predicate: Predicate = #Predicate<Object> {
             $0.a == compareTo
        }
        try XCTAssertFalse(predicate.evaluate(Object(a: 1, b: "", c: 0, d: 0, e: "c", f: true, g: [])))
        try XCTAssertTrue(predicate.evaluate(Object(a: 2, b: "", c: 0, d: 0, e: "c", f: true, g: [])))
#endif
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testVariadic() throws {
        let predicate = Predicate<Object, Int> {
            // $0.a == $1 + 1
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: $0,
                        keyPath: \.a
                    )
                ),
                rhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_Arithmetic(
                        lhs: PredicateExpressions.build_Arg($1),
                        rhs: PredicateExpressions.build_Arg(1),
                        op: .add
                    )
                )
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 3, b: "", c: 0, d: 0, e: "c", f: true, g: []), 2))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testArithmetic() throws {
        let predicate = Predicate<Object> {
            // $0.a + 2 == 4
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_Arithmetic(
                        lhs: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_KeyPath(
                                root: $0,
                                keyPath: \.a
                            )
                        ),
                        rhs: PredicateExpressions.build_Arg(2),
                        op: .add
                    )
                ),
                rhs: PredicateExpressions.build_Arg(4)
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 2, b: "", c: 0, d: 0, e: "c", f: true, g: [])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testDivision() throws {
        let predicate = Predicate<Object> {
            // $0.a / 2 == 3
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_Division(
                        lhs: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_KeyPath(
                                root: $0,
                                keyPath: \.a
                            )
                        ),
                        rhs: PredicateExpressions.build_Arg(2)
                    )
                ),
                rhs: PredicateExpressions.build_Arg(3)
            )
        }
        let predicate2 = Predicate<Object> {
            // $0.c / 2.1 <= 3.0
            PredicateExpressions.build_Comparison(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_Division(
                        lhs: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_KeyPath(
                                root: $0,
                                keyPath: \.c
                            )
                        ),
                        rhs: PredicateExpressions.build_Arg(2.1)
                    )
                ),
                rhs: PredicateExpressions.build_Arg(3.0),
                op: .lessThanOrEqual
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 6, b: "", c: 0, d: 0, e: "c", f: true, g: [])))
        XCTAssert(try predicate2.evaluate(Object(a: 2, b: "", c: 6.0, d: 0, e: "c", f: true, g: [])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testBuildDivision() throws {
        let predicate = Predicate<Object> {
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_Division(
                        lhs: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_KeyPath(
                                root: $0,
                                keyPath: \.a
                            )
                        ),
                        rhs: PredicateExpressions.build_Arg(2)
                    )
                ),
                rhs: PredicateExpressions.build_Arg(3))
        }
        XCTAssert(try predicate.evaluate(Object(a: 6, b: "", c: 0, d: 0, e: "c", f: true, g: [])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testUnaryMinus() throws {
        let predicate = Predicate<Object> {
            // -$0.a == 17
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_UnaryMinus(
                        PredicateExpressions.build_Arg(
                            PredicateExpressions.build_KeyPath(
                                root: $0,
                                keyPath: \.a
                            )
                        )
                    )
                ),
                rhs: PredicateExpressions.build_Arg(17)
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: -17, b: "", c: 0, d: 0, e: "c", f: true, g: [])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testCount() throws {
        let predicate = Predicate<Object> {
            // $0.g.count == 5
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_KeyPath(
                            root: $0,
                            keyPath: \.g
                        ),
                        keyPath: \.count
                    )
                ),
                rhs: PredicateExpressions.build_Arg(5)
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 0, b: "", c: 0, d: 0, e: "c", f: true, g: [2, 3, 5, 7, 11])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testFilter() throws {
        let predicate = Predicate<Object> { object in
            /*object.g.filter {
                $0 == object.d
            }.count > 0*/
            
            PredicateExpressions.build_Comparison(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_filter(
                            PredicateExpressions.build_Arg(
                                PredicateExpressions.build_KeyPath(
                                    root: object,
                                    keyPath: \.g
                                )
                            ),
                            {
                                PredicateExpressions.build_Equal(
                                    lhs: PredicateExpressions.build_Arg($0),
                                    rhs: PredicateExpressions.build_Arg(
                                        PredicateExpressions.build_KeyPath(
                                            root: object,
                                            keyPath: \.d
                                        )
                                    )
                                )
                            }
                        ),
                        keyPath: \.count
                    )
                ),
                rhs: PredicateExpressions.build_Arg(0),
                op: .greaterThan
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 0, b: "", c: 0.0, d: 17, e: "c", f: true, g: [3, 5, 7, 11, 13, 17, 19])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testContains() throws {
        let predicate = Predicate<Object> {
            // $0.g.contains($0.a)
            PredicateExpressions.build_contains(
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: $0,
                        keyPath: \.g
                    )
                ),
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: $0,
                        keyPath: \.a
                    )
                )
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 13, b: "", c: 0.0, d: 0, e: "c", f: true, g: [2, 3, 5, 11, 13, 17])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testContainsWhere() throws {
        let predicate = Predicate<Object> { object in
            // object.g.contains { $0 % object.a == 0 }
            PredicateExpressions.build_contains(
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: object,
                        keyPath: \.g
                    )
                ),
                where: {
                    PredicateExpressions.build_Equal(
                        lhs: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_Remainder(
                                lhs: PredicateExpressions.build_Arg($0),
                                rhs: PredicateExpressions.build_Arg(
                                    PredicateExpressions.build_KeyPath(
                                        root: object,
                                        keyPath: \.a
                                    )
                                )
                            )
                        ),
                        rhs: PredicateExpressions.build_Arg(0)
                    )
                }
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 2, b: "", c: 0.0, d: 0, e: "c", f: true, g: [3, 5, 7, 2, 11, 13])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testAllSatisfy() throws {
        let predicate = Predicate<Object> { object in
            // object.g.allSatisfy { $0 % object.d != 0 }
            PredicateExpressions.build_allSatisfy(
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: object,
                        keyPath: \.g
                    )
                ),
                {
                    PredicateExpressions.build_NotEqual(
                        lhs: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_Remainder(
                                lhs: PredicateExpressions.build_Arg($0),
                                rhs: PredicateExpressions.build_Arg(
                                    PredicateExpressions.build_KeyPath(
                                        root: object,
                                        keyPath: \.d
                                    )
                                )
                            )
                        ),
                        rhs: PredicateExpressions.build_Arg(0)
                    )
                }
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 0, b: "", c: 0.0, d: 2, e: "c", f: true, g: [3, 5, 7, 11, 13, 17, 19])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testOptional() throws {
        struct Wrapper<T> {
            let wrapped: T?
        }
        let predicate = Predicate<Wrapper<Int>> {
//            ($0.wrapped.flatMap { $0 + 1 } ?? 7) % 2 == 1
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_Remainder(
                        lhs: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_NilCoalesce(
                                lhs: PredicateExpressions.build_Arg(
                                    PredicateExpressions.build_flatMap(
                                        PredicateExpressions.build_Arg(
                                            PredicateExpressions.build_KeyPath(
                                                root: $0,
                                                keyPath: \.wrapped
                                            )
                                        ),
                                        {
                                            PredicateExpressions.build_Arithmetic(
                                                lhs: PredicateExpressions.build_Arg($0),
                                                rhs: PredicateExpressions.build_Arg(1),
                                                op: .add
                                            )
                                        }
                                    )
                                ),
                                rhs: PredicateExpressions.build_Arg(7)
                            )
                        ),
                        rhs: PredicateExpressions.build_Arg(2)
                    )
                ),
                rhs: PredicateExpressions.build_Arg(1))
        }
        let predicate2 = Predicate<Wrapper<Int>> {
//          $0.wrapped! == 19
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_ForcedUnwrap(
                        PredicateExpressions.build_KeyPath(
                            root: $0,
                            keyPath: \.wrapped
                        )
                    )
                ),
                rhs: PredicateExpressions.build_Arg(
                    19
                )
            )
        }
        XCTAssert(try predicate.evaluate(Wrapper<Int>(wrapped: 4)))
        XCTAssert(try predicate.evaluate(Wrapper<Int>(wrapped: nil)))
        XCTAssert(try predicate2.evaluate(Wrapper<Int>(wrapped: 19)))
        XCTAssertThrowsError(try predicate2.evaluate(Wrapper<Int>(wrapped: nil)))
        
        struct _NonCodableType : Equatable {}
        let predicate3 = Predicate<Wrapper<_NonCodableType>> {
            // $0.wrapped == nil
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_KeyPath(
                    root: PredicateExpressions.build_Arg($0),
                    keyPath: \.wrapped
                ),
                rhs: PredicateExpressions.build_NilLiteral()
            )
        }
        XCTAssertFalse(try predicate3.evaluate(Wrapper(wrapped: _NonCodableType())))
        XCTAssertTrue(try predicate3.evaluate(Wrapper(wrapped: nil)))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testConditional() throws {
        let predicate = Predicate<Bool, String, String> {
            // ($0 ? $1 : $2) == "if branch"
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_Conditional(
                        $0,
                        PredicateExpressions.build_Arg($1),
                        PredicateExpressions.build_Arg($2)
                    )
                ),
                rhs: PredicateExpressions.build_Arg("if branch")
            )
        }
        XCTAssert(try predicate.evaluate(true, "if branch", "else branch"))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testClosedRange() throws {
        let predicate = Predicate<Object> {
            // (3...5).contains($0.a)
            PredicateExpressions.build_contains(
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_ClosedRange(
                        lower: PredicateExpressions.build_Arg(3),
                        upper: PredicateExpressions.build_Arg(5)
                    )
                ),
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: $0,
                        keyPath: \.a
                    )
                )
            )
        }
        let predicate2 = Predicate<Object> {
            // ($0.a...$0.d).contains(4)
            PredicateExpressions.build_contains(
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_ClosedRange(
                        lower: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_KeyPath(
                                root: $0,
                                keyPath: \.a
                            )
                        ),
                        upper: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_KeyPath(
                                root: $0,
                                keyPath: \.d
                            )
                        )
                    )
                ),
                PredicateExpressions.build_Arg(4)
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 4, b: "", c: 0.0, d: 0, e: "c", f: true, g: [])))
        XCTAssert(try predicate2.evaluate(Object(a: 3, b: "", c: 0.0, d: 5, e: "c", f: true, g: [])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testRange() throws {
        let predicate = Predicate<Object> {
            // (3..<5).contains($0.a)
            PredicateExpressions.build_contains(
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_Range(
                        lower: PredicateExpressions.build_Arg(3),
                        upper: PredicateExpressions.build_Arg(5)
                    )
                ),
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: $0,
                        keyPath: \.a
                    )
                )
            )
        }
        let toMatch = 4
        let predicate2 = Predicate<Object> {
            // ($0.a..<$0.d).contains(toMatch)
            PredicateExpressions.build_contains(
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_Range(
                        lower: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_KeyPath(
                                root: $0,
                                keyPath: \.a
                            )
                        ),
                        upper: PredicateExpressions.build_Arg(
                            PredicateExpressions.build_KeyPath(
                                root: $0,
                                keyPath: \.d
                            )
                        )
                    )
                ),
                PredicateExpressions.build_Arg(toMatch)
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 4, b: "", c: 0.0, d: 0, e: "c", f: true, g: [])))
        XCTAssert(try predicate2.evaluate(Object(a: 3, b: "", c: 0.0, d: 5, e: "c", f: true, g: [])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testRangeContains() throws {
        let date = Date.distantPast
        let predicate = Predicate<Object> {
            // (date ..< date).contains($0.h)
            PredicateExpressions.build_contains(
                PredicateExpressions.build_Range(
                    lower: PredicateExpressions.build_Arg(date),
                    upper: PredicateExpressions.build_Arg(date)
                ),
                PredicateExpressions.build_KeyPath(
                    root: PredicateExpressions.build_Arg($0),
                    keyPath: \.h
                )
            )
        }
        
        XCTAssertFalse(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 5, e: "c", f: true, g: [])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testTypes() throws {
        let predicate = Predicate<Object> {
            // ($0.a as? Int).flatMap { $0 == 3 } ?? false
            PredicateExpressions.build_NilCoalesce(
                lhs: PredicateExpressions.build_Arg(
                    PredicateExpressions.build_flatMap(
                        PredicateExpressions.build_Arg(
                            PredicateExpressions.ConditionalCast<_, Int>(
                                PredicateExpressions.build_Arg(
                                    PredicateExpressions.build_KeyPath(
                                        root: $0,
                                        keyPath: \.a
                                    )
                                )
                            )
                        ),
                        {
                            PredicateExpressions.build_Equal(
                                lhs: PredicateExpressions.build_Arg($0),
                                rhs: PredicateExpressions.build_Arg(3)
                            )
                        }
                    )
                ),
                rhs: PredicateExpressions.build_Arg(false)
            )
        }
        let predicate2 = Predicate<Object> {
            // $0.a is BinaryInteger
            PredicateExpressions.TypeCheck<_, BinaryInteger>(
                PredicateExpressions.build_Arg(
                    PredicateExpressions.build_KeyPath(
                        root: $0,
                        keyPath: \.a
                    )
                )
            )
        }
        XCTAssert(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [])))
        XCTAssert(try predicate2.evaluate(Object(a: 3, b: "", c: 0.0, d: 5, e: "c", f: true, g: [])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testSubscripts() throws {
        var predicate = Predicate<Object> {
            // $0.g[0] == 0
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_subscript(
                    PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_Arg($0),
                        keyPath: \.g
                    ),
                    PredicateExpressions.build_Arg(0)
                ),
                rhs: PredicateExpressions.build_Arg(0)
            )
        }
        
        XCTAssertTrue(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [0])))
        XCTAssertFalse(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [1])))
        XCTAssertThrowsError(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [])))
        
        predicate = Predicate<Object> {
            // $0.g[0 ..< 2].isEmpty
            PredicateExpressions.build_KeyPath(
                root: PredicateExpressions.build_subscript(
                    PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_Arg($0),
                        keyPath: \.g
                    ),
                    PredicateExpressions.build_Range(
                        lower: PredicateExpressions.build_Arg(0),
                        upper: PredicateExpressions.build_Arg(2))
                ),
                keyPath: \.isEmpty
            )
        }
        
        XCTAssertFalse(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [0, 1, 2])))
        XCTAssertFalse(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [0, 1])))
        XCTAssertThrowsError(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [0])))
        XCTAssertThrowsError(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [])))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testLazyDefaultValueSubscript() throws {
        struct Foo : Codable, Sendable {
            static var num = 1
            
            var property: Int {
                defer { Foo.num += 1 }
                return Foo.num
            }
        }
        
        let foo = Foo()
        let predicate = Predicate<[String : Int]> {
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_subscript(
                    PredicateExpressions.build_Arg($0),
                    PredicateExpressions.build_Arg("key"),
                    default: PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_Arg(foo),
                        keyPath: \.property
                    )
                ),
                rhs: PredicateExpressions.build_Arg(1)
            )
        }
        XCTAssertFalse(try predicate.evaluate(["key" : 2]))
        XCTAssertEqual(Foo.num, 1)
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testStaticValues() throws {
        func assertPredicate<T>(_ pred: Predicate<T>, value: T, expected: Bool) throws {
            XCTAssertEqual(try pred.evaluate(value), expected)
        }
        
        try assertPredicate(.true, value: "Hello", expected: true)
        try assertPredicate(.false, value: "Hello", expected: false)
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testMaxMin() throws {
        var predicate = Predicate<Object> {
            // $0.g.max() == 2
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_max(
                    PredicateExpressions.build_KeyPath(
                        root: $0,
                        keyPath: \.g
                    )
                ),
                rhs: PredicateExpressions.build_Arg(2)
            )
        }
        XCTAssertFalse(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [1, 3])))
        XCTAssertTrue(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [1, 2])))
        
        predicate = Predicate<Object> {
            // $0.g.min() == 2
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_min(
                    PredicateExpressions.build_KeyPath(
                        root: $0,
                        keyPath: \.g
                    )
                ),
                rhs: PredicateExpressions.build_Arg(2)
            )
        }
        XCTAssertFalse(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [1, 3])))
        XCTAssertTrue(try predicate.evaluate(Object(a: 3, b: "", c: 0.0, d: 0, e: "c", f: true, g: [2, 3])))
    }
    
    #if FOUNDATION_FRAMEWORK
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testCaseInsensitiveCompare() throws {
        let equal = ComparisonResult.orderedSame
        let predicate = Predicate<Object> {
            // $0.b.caseInsensitiveCompare("ABC") == equal
            PredicateExpressions.build_Equal(
                lhs: PredicateExpressions.build_caseInsensitiveCompare(
                    PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_Arg($0),
                        keyPath: \.b
                    ),
                    PredicateExpressions.build_Arg("ABC")
                ),
                rhs: PredicateExpressions.build_Arg(equal)
            )
        }
        XCTAssertTrue(try predicate.evaluate(Object(a: 3, b: "abc", c: 0.0, d: 0, e: "c", f: true, g: [1, 3])))
        XCTAssertFalse(try predicate.evaluate(Object(a: 3, b: "def", c: 0.0, d: 0, e: "c", f: true, g: [1, 3])))
    }
    
    #endif
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testBuildDynamically() throws {
        func _build(_ equal: Bool) -> Predicate<Int> {
            Predicate<Int> {
                if equal {
                    PredicateExpressions.Equal(
                        lhs: $0,
                        rhs: PredicateExpressions.Value(1)
                    )
                } else {
                    PredicateExpressions.NotEqual(
                        lhs: $0,
                        rhs: PredicateExpressions.Value(1)
                    )
                }
            }
        }
        
        XCTAssertTrue(try _build(true).evaluate(1))
        XCTAssertFalse(try _build(false).evaluate(1))
    }
    
    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    func testResilientKeyPaths() {
        // Local, non-resilient type
        struct Foo {
            let a: String   // Non-resilient
            let b: Date     // Resilient (in Foundation)
            let c: String   // Non-resilient
        }
        
        let now = Date.now
        let _ = Predicate<Foo> {
            PredicateExpressions.build_Conjunction(
                lhs: PredicateExpressions.build_Equal(
                    lhs: PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_Arg($0),
                        keyPath: \.a
                    ),
                    rhs: PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_Arg($0),
                        keyPath: \.c
                    )
                ),
                rhs: PredicateExpressions.build_Equal(
                    lhs: PredicateExpressions.build_KeyPath(
                        root: PredicateExpressions.build_Arg($0),
                        keyPath: \.b
                    ),
                    rhs: PredicateExpressions.build_Arg(now)
                )
            )
        }
    }
}

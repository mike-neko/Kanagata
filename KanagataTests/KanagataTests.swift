//
//  KanagataTests.swift
//  KanagataTests
//
//  Created by M.Ike on 2016/12/08.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import XCTest
@testable import Kanagata

private func DQ(_ key: String) -> String { return "\"\(key)\"" }

class KanagataTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    private func checkString(_ data: JSONData, _ value: String) -> Bool { return (try? data.stringValue()) == value }
    private func checkInt(_ data: JSONData, _ value: Int) -> Bool { return (try? data.intValue()) == value }
    private func checkDouble(_ data: JSONData, _ value: Double) -> Bool { return (try? data.doubleValue()) == value }
    private func checkBool(_ data: JSONData, _ value: Bool) -> Bool { return (try? data.boolValue()) == value }
    private func mix(_ a: [String: Any], _ b: [String: Any]) -> [String: Any] {
        var dic: [String: Any] = [:]
        a.forEach { dic[$0.key] = $0.value }
        b.forEach { dic[$0.key] = $0.value }
        return dic
    }

    private struct Key {
        static let str = "str"
        static let int = "int"
        static let double = "double"
        static let bool = "bool"
        static let boolTrue = "boolTrue"
        static let boolFalse = "boolFalse"

        static let strN = "strN"
        static let intN = "intN"
        static let doubleN = "doubleN"
        static let boolN = "boolN"
        static let strNo = "strNo"
        static let intNo = "intNo"
        static let doubleNo = "doubleNo"
        static let boolNo = "boolNo"

        static let obj = "obj"
        static let objInt = "objInt"
        static let objObj = "objObj"
        static let objArr = "objArr"
        static let objEmpty = "objEmpty"

        static let arr = "arr"
        static let arrStr = "arrStr"
        static let arrInt = "arrInt"
        static let arrDouble = "arrDouble"
        static let arrBool = "arrBool"
        static let arrObj = "arrObj"
        static let arrArr = "arrArr"
        static let arrEmpty = "arrEmpty"
        static let arrNest = "arrNest"

        static let unknown = "unknown"
        static let over = 10000
    }

    private struct Value {
        static let str = "text"
        static let int = 1
        static let double = Double(3.14)
        static let bool = true
        static let boolTrue = true
        static let boolFalse = false

        static let null = NSNull()

        static let arrStr = ["a", "b", "c"]
        static let arrInt = [0, 1, 2]
        static let arrDouble = [1.0, 1.1, 1.2] as [Double]
        static let arrBool = [true, false]
    }

    private struct StrData {
        static let str = DQ(Key.str) + ":" + DQ(Value.str)
        static let int = DQ(Key.int) + ": \(Value.int)"
        static let double = DQ(Key.double) + ": \(Value.double)"
        static let boolTrue = DQ(Key.boolTrue) + ": \(Value.boolTrue)"
        static let boolFalse = DQ(Key.boolFalse) + ": \(Value.boolFalse)"

        static let objEmpty = DQ(Key.objEmpty) + ": {}"

        static let arrStr = DQ(Key.arrStr) + ":" + "[\"a\",\"b\",\"c\"]"
        static let arrInt = DQ(Key.arrInt) + ":" + "[0, 1, 2]"
        static let arrDouble = DQ(Key.arrDouble) + ":" + "[1.0, 1.1, 1.2]"
    }

    /*
     basicType...基本のデータ型
     { "str": "text", "int": 1, "double": 3.14, "boolTrue": true, "boolFalse": false }
     */
    private let basicTypeText = "{" + [StrData.str, StrData.int, StrData.double, StrData.boolTrue, StrData.boolFalse].joined(separator: ",") + "}"
    private let basicTypeDictionary: [String: Any] = [
        Key.str: Value.str, Key.int: Value.int, Key.double: Value.double,
        Key.boolTrue: Value.boolTrue, Key.boolFalse: Value.boolFalse
    ]
    private let basicTypeFormat: JSON.Format = [
        Key.str: .string, Key.int: .int, Key.double: .double,
        Key.boolTrue: .bool, Key.boolFalse: .bool
    ]

    /*
     baseObj...object形式一式
     { "objInt": {"int": 1}, "objObj": {"obj": {"str": "text"}}, "objArr": {"arr": [true, false]}, "objEmpty": {} }
     */
    private let baseObjText = "{"
        + DQ(Key.objInt) + ":{" + StrData.int + "},"
        + DQ(Key.objObj) + ":{" + DQ(Key.obj) + ":{" + StrData.str + "}},"
        + DQ(Key.objArr) + ":{" + DQ("arr") + ":[true, false]},"
        + StrData.objEmpty + "}"
    private let baseObjDictionary: [String: Any] = [
        Key.objInt: [Key.int: Value.int], Key.objObj: [Key.obj: [Key.str: Value.str]],
        Key.objArr: [Key.arr: [Value.boolTrue, Value.boolFalse]], Key.objEmpty: [:]
    ]
    private let baseObjFormat: JSON.Format = [
        Key.objInt: .object([Key.int: .int]), Key.objObj: .object([Key.obj: .object([Key.str: .string])]),
        Key.objArr: .object([Key.arr: .array(.bool)]), Key.objEmpty: .object([:])
    ]

    /*
     baseArray...array形式一式
     { "arrStr": ["a", "b", "c"], "arr": ["arrInt": [0, 1, 2], "arrDouble": [1.0, 1.1, 1.2]],
     "arrObj": [{"bool": true}, {"bool": false}], "arrNest": [[0, 1, 2], [0, 1, 2, 3]],
     "arrEmpty": [], "arrArr": [[]] }
     */
    private let baseArrayText = "{"
        + StrData.arrStr + "," + DQ(Key.arr) + ":{\(StrData.arrInt), \(StrData.arrDouble)},"
        + DQ(Key.arrObj) + ":[{" + DQ(Key.bool) + ": true},{" + DQ(Key.bool) + ": false}],"
        + DQ(Key.arrNest) + ":[[0, 1, 2], [0, 1, 2, 3]],"
        + DQ(Key.arrEmpty) + ":[]," + DQ(Key.arrArr) + ":[[]]" + "}"
    private let baseArrayDictionary: [String: Any] = [
        Key.arrStr: Value.arrStr, Key.arr: [Key.arrInt: Value.arrInt, Key.arrDouble: Value.arrDouble],
        Key.arrObj: [[Key.bool: Value.boolTrue], [Key.bool: Value.boolFalse]],
        Key.arrNest: [Value.arrInt, Value.arrInt + [3]],
        Key.arrEmpty: [], Key.arrArr: [[]]
    ]
    private let baseArrayFormat: JSON.Format = [
        Key.arrStr: .array(.string), Key.arr: .object([Key.arrInt: .array(.int), Key.arrDouble: .array(.double)]),
        Key.arrObj: .array(.object([Key.bool: .bool])), Key.arrNest: .array(.array(.int)),
        Key.arrEmpty: .array(.string), Key.arrArr: .array(.array(.string))
    ]

    /*
     nullType...基本のデータ型のnull
     { "strN": null, "intN": null, "doubleN": null, "boolN": null }
     */
    private let nullTypeText = "{\(DQ(Key.strN)):null,\(DQ(Key.intN)):null,\(DQ(Key.doubleN)):null,\(DQ(Key.boolN)):null}"
    private let nullTypeDictionary: [String: Any] = [
        Key.strN: Value.null, Key.intN: Value.null, Key.doubleN: Value.null, Key.boolN: Value.null
    ]
    private let nullTypeFormat: JSON.Format = [
        Key.strN: .stringOrNull, Key.intN: .intOrNull, Key.doubleN: .doubleOrNull, Key.boolN: .boolOrNull
    ]

    /*
     nothingType...基本のデータ型のnothingテスト用
     { "strNo": null, "intNo": null, "doubleNo": null, "boolNo": null }
     */
    private let nothingTypeText = "{\(DQ(Key.strNo)):null,\(DQ(Key.intNo)):null,\(DQ(Key.doubleNo)):null,\(DQ(Key.boolNo)):null}"
    private let nothingTypeDictionary: [String: Any] = [
        Key.strNo: Value.null, Key.intNo: Value.null, Key.doubleNo: Value.null, Key.boolNo: Value.null
    ]
    private let nothingTypeFormat: JSON.Format = [
        Key.strNo: .stringOrNothing, Key.intNo: .intOrNothing, Key.doubleNo: .doubleOrNothing, Key.boolNo: .boolOrNothing
    ]

    /*
     nullObj...object形式のnull
     */
    private let nullObjDictionary: [String: Any] = [
        "d1": ["a": NSNull(), "b": NSNull(), "c": NSNull(), "d": NSNull()], "d2": NSNull(),
        "d3": ["a": ["b": "aaa", "c": NSNull(), "d": ["e": NSNull()]]],
        "d4": ["a": ["b": 1, "c": NSNull(), "d": NSNull()]],
        ]
    private let nullObjFormat: JSON.Format = [
        "d1": .objectOrNull(["a": .stringOrNull, "b": .intOrNull, "c": .doubleOrNull, "d": .boolOrNull]),
        "d2": .objectOrNull(["a": .int, "b": .string]),
        "d3": .object(["a": .object(["b": .string, "c": .objectOrNull(["a": .int, "b": .string]),
                                     "d": .objectOrNull(["e": .objectOrNull(["a": .int, "b": .string])])])]),
        "d4": .object(["a": .object(["b": .int, "c": .objectOrNull(["cc": .array(.int)]),
                                     "d": .objectOrNull(["e": .objectOrNull(["a": .int, "b": .string])])])]),
        ]
    private let nothingObjFormat: JSON.Format = [
        "d1": .objectOrNothing(["a": .stringOrNothing, "b": .intOrNothing, "c": .doubleOrNothing, "d": .boolOrNothing]),
        "d2": .objectOrNothing(["a": .int, "b": .string]),
        "d3": .object(["a": .object(["b": .string, "c": .objectOrNothing(["a": .int, "b": .string]),
                                     "d": .objectOrNothing(["e": .objectOrNothing(["a": .int, "b": .string])])])]),
        "d4": .object(["a": .object(["b": .int, "c": .objectOrNothing(["cc": .array(.int)]),
                                     "d": .objectOrNothing(["e": .objectOrNothing(["a": .int, "b": .string])])])]),
        ]

    /*
     nullArray...array形式のnull
     */
    private let nullArrayDictionary: [String: Any] = [
        "a1": ["a", NSNull(), "c"], "a2": NSNull(), "a3": NSNull(),
        "a4": ["aa": [0, NSNull(), 2], "ab": [NSNull()]],
        "a5": [["a": NSNull()], ["a": false]],
        ]
    let nullArrayFormat: JSON.Format = [
        "a1": .array(.stringOrNull),
        "a2": .arrayOrNull(.int), "a3": .arrayOrNull(.stringOrNull),
        "a4": .object(["aa": .array(.intOrNull), "ab": .array(.stringOrNull)]),
        "a5": .array(.object(["a": .boolOrNull])),
        ]
    let nothingArrayFormat: JSON.Format = [
        "a1": .array(.stringOrNothing),
        "a2": .arrayOrNothing(.int), "a3": .arrayOrNothing(.stringOrNothing),
        "a4": .object(["aa": .array(.intOrNothing), "ab": .array(.stringOrNothing)]),
        "a5": .array(.object(["a": .boolOrNothing]))
    ]

    // MARK: -
    func testBasicTypeFromString() {
        guard let j = try? JSON(string: basicTypeText, format: basicTypeFormat)  else {
            XCTFail()
            return
        }

        XCTAssert(checkString(j[Key.str], Value.str))
        XCTAssert(checkInt(j[Key.int], Value.int))
        XCTAssert(checkDouble(j[Key.double], Value.double))
        XCTAssert(checkBool(j[Key.boolTrue], Value.boolTrue))
        XCTAssert(checkBool(j[Key.boolFalse], Value.boolFalse))
    }

    func testBaseObjectFromString() {
        guard let j = try? JSON(string: baseObjText, format: baseObjFormat)  else {
            XCTFail()
            return
        }

        XCTAssert(checkInt(j[Key.objInt][Key.int], Value.int))
        XCTAssert(checkString(j[Key.objObj][Key.obj][Key.str], Value.str))
        XCTAssert(checkBool(j[Key.objArr][Key.arr][0], Value.boolTrue))
        XCTAssert(checkBool(j[Key.objArr][Key.arr][1], Value.boolFalse))
        XCTAssertTrue(j[Key.objEmpty].exists)

        XCTAssertFalse(j[Key.unknown].exists)
        XCTAssertFalse(j[Key.objInt][Key.unknown].exists)
        XCTAssertFalse(j[Key.objArr][Key.arr][Key.over].exists)
    }

    func testBaseArrayFromString() {
        guard let j = try? JSON(string: baseArrayText, format: baseArrayFormat)  else {
            XCTFail()
            return
        }

        XCTAssert(checkString(j[Key.arrStr][2], "c"))
        XCTAssert(checkInt(j[Key.arr][Key.arrInt][1], 1))
        XCTAssert(checkDouble(j[Key.arr][Key.arrDouble][1], 1.1))
        XCTAssert(checkBool(j[Key.arrObj][0][Key.bool], Value.boolTrue))
        XCTAssert(checkBool(j[Key.arrObj][1][Key.bool], Value.boolFalse))
        XCTAssert(checkInt(j[Key.arrNest][0][0], 0))
        XCTAssert(checkInt(j[Key.arrNest][1][2], 2))
        XCTAssertTrue(j[Key.arrEmpty].exists)
        XCTAssertTrue(j[Key.arrArr].exists)
    }

    func testNull() {
        do {
            // dataのみでnullだった時にエラーになるか
            XCTAssertThrowsError(try JSON(string: nullTypeText, format: [Key.strN: .string]))
            XCTAssertThrowsError(try JSON(string: nullTypeText, format: [Key.intN: .int]))
            XCTAssertThrowsError(try JSON(string: nullTypeText, format: [Key.doubleN: .double]))
            XCTAssertThrowsError(try JSON(string: nullTypeText, format: [Key.boolN: .bool]))
            // dataのみで存在しない時にエラーになるか
            XCTAssertThrowsError(try JSON(string: nullTypeText, format: [Key.strNo: .string]))
            XCTAssertThrowsError(try JSON(string: nullTypeText, format: [Key.intNo: .int]))
            XCTAssertThrowsError(try JSON(string: nullTypeText, format: [Key.doubleNo: .double]))
            XCTAssertThrowsError(try JSON(string: nullTypeText, format: [Key.boolNo: .bool]))
        }

        do {
            // OrNullでnullだった時にnullになるか
            guard let j = try? JSON(string: nullTypeText, format: nullTypeFormat)  else {
                XCTFail()
                return
            }
            XCTAssertTrue(j[Key.strN].isNull)
            XCTAssertTrue(j[Key.intN].isNull)
            XCTAssertTrue(j[Key.doubleN].isNull)
            XCTAssertTrue(j[Key.boolN].isNull)
        }
        do {
            // OrNullで存在しない時にnullになるか
            guard let j = try? JSON(string: nothingTypeText, format: nullTypeFormat)  else {
                XCTFail()
                return
            }
            XCTAssertTrue(j[Key.strN].isNull)
            XCTAssertTrue(j[Key.intN].isNull)
            XCTAssertTrue(j[Key.doubleN].isNull)
            XCTAssertTrue(j[Key.boolN].isNull)
        }
        do {
            // OrNothingでnullだった時に存在しないか
            guard let j = try? JSON(string: nothingTypeText, format: nothingTypeFormat)  else {
                XCTFail()
                return
            }
            XCTAssertFalse(j[Key.strNo].exists)
            XCTAssertFalse(j[Key.intNo].exists)
            XCTAssertFalse(j[Key.doubleNo].exists)
            XCTAssertFalse(j[Key.boolNo].exists)
        }
        do {
            // OrNothingで存在しない時に存在しないか
            guard let j = try? JSON(string: nullTypeText, format: nothingTypeFormat)  else {
                XCTFail()
                return
            }
            XCTAssertFalse(j[Key.strNo].exists)
            XCTAssertFalse(j[Key.intNo].exists)
            XCTAssertFalse(j[Key.doubleNo].exists)
            XCTAssertFalse(j[Key.boolNo].exists)
        }
    }

    func testNullObject() {
        let data = try! JSONSerialization.data(withJSONObject: nullObjDictionary, options: [])
        do {
            guard let j = try? JSON(data: data, format: nullObjFormat)  else {
                XCTFail()
                return
            }

            XCTAssertTrue(j["d1"]["a"].isNull)
            XCTAssertTrue(j["d1"]["b"].isNull)
            XCTAssertTrue(j["d1"]["c"].isNull)
            XCTAssertTrue(j["d1"]["d"].isNull)
            XCTAssertTrue(j["d2"].isNull)
            XCTAssertFalse(j["d2"]["a"].exists)
            XCTAssertTrue(j["d3"]["a"]["c"].isNull)
            XCTAssertTrue(j["d3"]["a"]["d"].exists)
            XCTAssertTrue(j["d3"]["a"]["d"]["e"].isNull)
            XCTAssertTrue(j["d4"]["a"]["c"].isNull)
            XCTAssertTrue(j["d4"]["a"]["d"].isNull)
            XCTAssert(checkString(j["d3"]["a"]["b"], "aaa"))
            XCTAssert(checkInt(j["d4"]["a"]["b"], 1))
        }
        do {
            guard let j = try? JSON(data: data, format: nothingObjFormat)  else {
                XCTFail()
                return
            }
            XCTAssertFalse(j["d1"]["a"].exists)
            XCTAssertFalse(j["d1"]["b"].exists)
            XCTAssertFalse(j["d1"]["c"].exists)
            XCTAssertFalse(j["d1"]["d"].exists)
            XCTAssertFalse(j["d2"].exists)
            XCTAssertFalse(j["d2"]["a"].exists)
            XCTAssertFalse(j["d3"]["a"]["c"].exists)
            XCTAssertTrue(j["d3"]["a"]["d"].exists)
            XCTAssertFalse(j["d3"]["a"]["d"]["e"].exists)
            XCTAssertFalse(j["d4"]["a"]["c"].exists)
            XCTAssertFalse(j["d4"]["a"]["d"].exists)
            XCTAssert(checkString(j["d3"]["a"]["b"], "aaa"))
            XCTAssert(checkInt(j["d4"]["a"]["b"], 1))
        }
    }

    func testNullArray() {
        let data = try! JSONSerialization.data(withJSONObject: nullArrayDictionary, options: [])
        do {
            guard let j = try? JSON(data: data, format: nullArrayFormat)  else {
                XCTFail()
                return
            }

            XCTAssert(checkString(j["a1"][0], "a"))
            XCTAssertTrue(j["a1"][1].isNull)
            XCTAssert(checkString(j["a1"][2], "c"))
            XCTAssertTrue(j["a2"].isNull)
            XCTAssertTrue(j["a3"].isNull)
            XCTAssertTrue(j["a4"]["aa"][1].isNull)
            XCTAssert(checkInt(j["a4"]["aa"][2], 2))
            XCTAssertTrue(j["a4"]["ab"][0].isNull)
            XCTAssertTrue(j["a5"][0]["a"].isNull)
            XCTAssert(checkBool(j["a5"][1]["a"], false))
        }
        do {
            guard let j = try? JSON(data: data, format: nothingArrayFormat)  else {
                XCTFail()
                return
            }

            XCTAssert(checkString(j["a1"][0], "a"))
            XCTAssert(checkString(j["a1"][1], "c"))
            XCTAssertFalse(j["a2"].exists)
            XCTAssertFalse(j["a3"].exists)
            XCTAssert(checkInt(j["a4"]["aa"][0], 0))
            XCTAssert(checkInt(j["a4"]["aa"][1], 2))
            XCTAssertTrue(j["a4"]["ab"].exists)
            XCTAssertEqual(j["a4"]["ab"].array.count, 0)
            XCTAssertFalse(j["a5"][0]["a"].exists)
            XCTAssert(checkBool(j["a5"][1]["a"], false))
        }
    }

    func testGetBasicValue() {
        let data = try! JSONSerialization.data(withJSONObject: basicTypeDictionary, options: [])
        guard let j = try? JSON(data: data, format: basicTypeFormat)  else {
            XCTFail()
            return
        }

        XCTAssertEqual(try? j[Key.str].stringValue(), Value.str)
        XCTAssertEqual(String(json: j[Key.str]), Value.str)
        XCTAssertEqual((j[Key.str].value() as String), Value.str)

        XCTAssertEqual(try? j[Key.int].intValue(), Value.int)
        XCTAssertEqual(Int(json: j[Key.int]), Value.int)
        XCTAssertEqual((j[Key.int].value() as Int), Value.int)

        XCTAssertEqual(try? j[Key.double].doubleValue(), Value.double)
        XCTAssertEqual(Double(json: j[Key.double]), Value.double)
        XCTAssertEqual((j[Key.double].value() as Double), Value.double)

        XCTAssertEqual(try? j[Key.boolTrue].boolValue(), Value.boolTrue)
        XCTAssertEqual(Bool(json: j[Key.boolTrue]), Value.boolTrue)
        XCTAssertEqual((j[Key.boolTrue].value() as Bool), Value.boolTrue)

        // Error
        XCTAssertNil(String(json: j[Key.int]))
        XCTAssertNil(Int(json: j[Key.str]))
        XCTAssertNil(Double(json: j[Key.int]))
        XCTAssertNil(Bool(json: j[Key.int]))
        XCTAssertThrowsError(try j[Key.unknown].stringValue())
        XCTAssertThrowsError(try j[Key.unknown].intValue())
        XCTAssertThrowsError(try j[Key.unknown].doubleValue())
        XCTAssertThrowsError(try j[Key.unknown].boolValue())
        XCTAssertEqual(j[Key.unknown].value(default: Value.str), Value.str)
        XCTAssertEqual(j[Key.unknown].value(default: Value.int), Value.int)
        XCTAssertEqual(j[Key.unknown].value(default: Value.double), Value.double)
        XCTAssertEqual(j[Key.unknown].value(default: Value.bool), Value.bool)
    }

    func testSetBasicValue() {
        let data = try! JSONSerialization.data(withJSONObject: basicTypeDictionary, options: [])
        guard let j = try? JSON(data: data, format: basicTypeFormat)  else {
            XCTFail()
            return
        }

        j[Key.str] = JSONData.value("text2")
        j[Key.int] = JSONData.value(21)
        j[Key.double] = JSONData.value(1.73)
        j[Key.boolTrue] = JSONData.value(false)

        XCTAssert(checkString(j[Key.str], "text2"))
        XCTAssert(checkInt(j[Key.int], 21))
        XCTAssert(checkDouble(j[Key.double], 1.73))
        XCTAssert(checkBool(j[Key.boolTrue], false))
    }

    func testSetArray() {
        var dic = baseArrayDictionary
        dic["arrBool"] = [true]

        let data = try! JSONSerialization.data(withJSONObject: dic, options: [])
        guard let j = try? JSON(data: data, format: baseArrayFormat + ["arrBool": .array(.bool)]) else {
            XCTFail()
            return
        }

        j[Key.arrStr][0] = JSONData.value("test")
        j[Key.arr][Key.arrInt][1] = JSONData.value(100)
        j[Key.arr][Key.arrDouble][2] = JSONData.value(1.73)
        j[Key.arrObj][1][Key.bool] = JSONData.value(true)
        j[Key.arrNest][1][3] = JSONData.value(200)

        XCTAssert(checkString(j[Key.arrStr][0], "test"))
        XCTAssert(checkInt(j[Key.arr][Key.arrInt][1], 100))
        XCTAssert(checkDouble(j[Key.arr][Key.arrDouble][2], 1.73))
        XCTAssert(checkBool(j[Key.arrObj][1][Key.bool], true))
        XCTAssert(checkInt(j[Key.arrNest][1][3], 200))
    }

    func testSetNull() {
        do {
            let data = try! JSONSerialization.data(withJSONObject: basicTypeDictionary, options: [])
            let format: JSON.Format = [Key.str: .stringOrNull, Key.int: .intOrNull, Key.double: .doubleOrNull, Key.boolTrue: .boolOrNull]
            guard let j = try? JSON(data: data, format: format) else {
                XCTFail()
                return
            }

            j[Key.str] = JSONData.null
            j[Key.int] = JSONData.null
            j[Key.double] = JSONData.null
            j[Key.boolTrue] = JSONData.null

            XCTAssertTrue(j[Key.str].isNull)
            XCTAssertTrue(j[Key.int].isNull)
            XCTAssertTrue(j[Key.double].isNull)
            XCTAssertTrue(j[Key.boolTrue].isNull)

            j[Key.str] = JSONData.value("text2")
            j[Key.int] = JSONData.value(21)
            j[Key.double] = JSONData.value(1.73)
            j[Key.boolTrue] = JSONData.value(false)

            XCTAssert(checkString(j[Key.str], "text2"))
            XCTAssert(checkInt(j[Key.int], 21))
            XCTAssert(checkDouble(j[Key.double], 1.73))
            XCTAssert(checkBool(j[Key.boolTrue], false))
        }
        do {
            let data = try! JSONSerialization.data(withJSONObject: nullTypeDictionary, options: [])
            guard let j = try? JSON(data: data, format: nullTypeFormat) else {
                XCTFail()
                return
            }

            j[Key.strN] = JSONData.null
            j[Key.intN] = JSONData.null
            j[Key.doubleN] = JSONData.null
            j[Key.boolN] = JSONData.null

            XCTAssertTrue(j[Key.strN].isNull)
            XCTAssertTrue(j[Key.intN].isNull)
            XCTAssertTrue(j[Key.doubleN].isNull)
            XCTAssertTrue(j[Key.boolN].isNull)

            j[Key.strN] = JSONData.value("text2")
            j[Key.intN] = JSONData.value(21)
            j[Key.doubleN] = JSONData.value(1.73)
            j[Key.boolN] = JSONData.value(false)

            XCTAssert(checkString(j[Key.strN], "text2"))
            XCTAssert(checkInt(j[Key.intN], 21))
            XCTAssert(checkDouble(j[Key.doubleN], 1.73))
            XCTAssert(checkBool(j[Key.boolN], false))
        }
    }

    func testSetNullObject() {
        let data = try! JSONSerialization.data(withJSONObject: nullObjDictionary, options: [])
        guard let j = try? JSON(data: data, format: nullObjFormat) else {
            XCTFail()
            return
        }

        j["d1"]["a"] = JSONData.value("test")
        j["d1"]["b"] = JSONData.value(100)
        j["d1"]["c"] = JSONData.value(1.73)
        j["d1"]["d"] = JSONData.value(true)

        XCTAssert(checkString(j["d1"]["a"], "test"))
        XCTAssert(checkInt(j["d1"]["b"], 100))
        XCTAssert(checkDouble(j["d1"]["c"], 1.73))
        XCTAssert(checkBool(j["d1"]["d"], true))

        j["d1"]["a"] = JSONData.null
        j["d1"]["b"] = JSONData.null
        j["d1"]["c"] = JSONData.null
        j["d1"]["d"] = JSONData.null
        j["d2"] = JSONData.null
        j["d3"]["a"]["d"] = JSONData.null

        XCTAssertTrue(j["d1"]["a"].isNull)
        XCTAssertTrue(j["d1"]["b"].isNull)
        XCTAssertTrue(j["d1"]["c"].isNull)
        XCTAssertTrue(j["d1"]["d"].isNull)
        XCTAssertTrue(j["d2"].isNull)
        XCTAssertTrue(j["d3"]["a"]["d"].isNull)

        j["d1"] = JSONData.null
        XCTAssertTrue(j["d1"].isNull)
        XCTAssertFalse(j["d1"]["a"].exists)
    }

    func testSetNullArray() {
        let dic: [String: Any] = [
            "a1": ["text0", "text1", "text2"],
            "a2": [0, 1, 2],
            "d3": ["a3": [0.0, 0.1, 0.2], "a4": [true]]
        ]

        let data = try! JSONSerialization.data(withJSONObject: dic, options: [])
        let format: JSON.Format = ["a1": .arrayOrNull(.stringOrNull), "a2": .arrayOrNull(.intOrNull),
                                   "d3": .objectOrNull(["a3": .arrayOrNull(.doubleOrNull), "a4": .arrayOrNull(.boolOrNull)])]
        guard let j = try? JSON(data: data, format: format) else {
            XCTFail()
            return
        }

        j["a1"][0] = JSONData.null
        j["a2"][2] = JSONData.null
        j["d3"]["a3"][1] = JSONData.null
        j["d3"]["a4"][0] = JSONData.null

        XCTAssertTrue(j["a1"][0].isNull)
        XCTAssertTrue(j["a2"][2].isNull)
        XCTAssertTrue(j["d3"]["a3"][1].isNull)
        XCTAssertTrue(j["d3"]["a4"][0].isNull)

        j["a1"][0] = JSONData.value("test")
        j["a2"][2] = JSONData.value(100)
        j["d3"]["a3"][1] = JSONData.value(1.73)
        j["d3"]["a4"][0] = JSONData.value(true)

        XCTAssert(checkString(j["a1"][0], "test"))
        XCTAssert(checkInt(j["a2"][2], 100))
        XCTAssert(checkDouble(j["d3"]["a3"][1], 1.73))
        XCTAssert(checkBool(j["d3"]["a4"][0], true))

        j["a1"] = JSONData.null
        XCTAssertTrue(j["a1"].isNull)
        j["d3"]["a3"] = JSONData.null
        XCTAssertTrue(j["d3"]["a3"].isNull)
    }

    func testArray() {
        let dic: [String: Any] = [
            Key.arrStr: Value.arrStr, Key.arrInt: Value.arrInt, Key.arrDouble: Value.arrDouble, Key.arrBool: Value.arrBool,
            Key.arr: [Key.str: Value.arrStr], Key.arrNest: [Value.arrInt, Value.arrInt],
            Key.arrObj: [[Key.str: "a"], [Key.str: "b"]],
            Key.strN: [], Key.intN: [], Key.doubleN: [], Key.boolN: [], Key.objObj: [], Key.arrArr: []
        ]
        let data = try! JSONSerialization.data(withJSONObject: dic, options: [])
        let format: JSON.Format = [
            Key.arrStr: .array(.string), Key.arrInt: .array(.int), Key.arrDouble: .array(.double), Key.arrBool: .array(.bool),
            Key.arr: .object([Key.str: .array(.stringOrNull)]), Key.arrNest: .array(.array(.int)),
            Key.arrObj: .array(.object([Key.str: .string])),
            Key.strN: .array(.stringOrNull), Key.intN: .array(.intOrNull),
            Key.doubleN: .array(.doubleOrNull), Key.boolN: .array(.boolOrNull),
            Key.objObj: .array(.objectOrNull([Key.bool: .bool])), Key.arrArr: .array(.arrayOrNull(.intOrNull))
        ]
        guard let j = try? JSON(data: data, format: format) else {
            XCTFail()
            return
        }

        j[Key.arrStr].append(array: ["test"])
        j[Key.arrInt].append(array: [1, 2])
        j[Key.arrDouble].append(array: [3.14])
        j[Key.arrBool].append(array: [false, false, false])
        j[Key.arr][Key.str].append(array: ["test2"])
        j[Key.arr][Key.str].append(array: ["test3"])
        j[Key.arrNest][1].append(array: [100])
        j[Key.arrObj].append(array: [[Key.str: "c"]])
        j[Key.arrNest].append(array: [[999]])

        XCTAssert(checkString(j[Key.arrStr][3], "test"))
        XCTAssert(checkInt(j[Key.arrInt][4], 2))
        XCTAssert(checkDouble(j[Key.arrDouble][3], 3.14))
        XCTAssert(checkBool(j[Key.arrBool][4], false))
        XCTAssert(checkString(j[Key.arr][Key.str][4], "test3"))
        XCTAssert(checkInt(j[Key.arrNest][1][3], 100))
        XCTAssert(checkString(j[Key.arrStr][3], "test"))
        XCTAssert(checkString(j[Key.arrObj][2][Key.str], "c"))
        XCTAssert(checkInt(j[Key.arrNest][2][0], 999))

        j[Key.arrStr].append(array: [])
        XCTAssertEqual(j[Key.arrStr].array.count, 4)

        j[Key.strN].append(array: ["test", NSNull()])
        j[Key.intN].append(array: [NSNull(), 2])
        j[Key.doubleN].append(array: [NSNull()])
        j[Key.boolN].append(array: [false, NSNull(), false])
        j[Key.objObj].append(array: [NSNull(), [Key.bool: true]])
        j[Key.arrArr].append(array: [[NSNull()], [0, NSNull()]])

        XCTAssert(checkString(j[Key.strN][0], "test"))
        XCTAssertTrue(j[Key.strN][1].isNull)
        XCTAssert(checkInt(j[Key.intN][1], 2))
        XCTAssertTrue(j[Key.intN][0].isNull)
        XCTAssertTrue(j[Key.doubleN][0].isNull)
        XCTAssertTrue(j[Key.boolN][1].isNull)
        XCTAssertTrue(j[Key.objObj][0].isNull)
        XCTAssert(checkBool(j[Key.objObj][1][Key.bool], true))
        XCTAssertTrue(j[Key.arrArr][0][0].isNull)
        XCTAssertTrue(j[Key.arrArr][1][1].isNull)
        XCTAssert(checkInt(j[Key.arrArr][1][0], 0))

        j[Key.arrStr].append(array: ["test2"])
        j[Key.arrStr].append(array: [100])
        XCTAssertEqual(j[Key.arrStr].array.count, 5)
        XCTAssert(checkString(j[Key.arrStr][4], "test2"))
    }

    func testConvert() {
        let dic = mix(basicTypeDictionary, baseObjDictionary)
        var fmt = basicTypeFormat
        fmt += baseObjFormat

        guard let json = try? JSON(data: try! JSONSerialization.data(withJSONObject: dic, options: []), format: fmt) else {
            XCTFail()
            return
        }
        guard let data = try? json.data() else {
            XCTFail()
            return
        }
        guard let obj = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
            XCTFail()
            return
        }

        XCTAssertEqual(obj[Key.str] as? String, Value.str)
        XCTAssertEqual(obj[Key.int] as? Int, Value.int)
        XCTAssertEqual(obj[Key.double] as? Double, Value.double)
        XCTAssertEqual(obj[Key.boolFalse] as? Bool, Value.boolFalse)
        XCTAssertEqual((obj[Key.objInt] as? [String: Any])?[Key.int] as? Int, Value.int)
        XCTAssertEqual(((obj[Key.objObj] as? [String: Any])?[Key.obj] as? [String: Any])?[Key.str] as? String, Value.str)
        XCTAssertEqual(((obj[Key.objArr] as? [String: Any])?[Key.arr] as? [Bool])?[1], false)

        guard let j = try? JSON(data: data, format: fmt) else {
            XCTFail()
            return
        }

        XCTAssert(checkString(j[Key.str], Value.str))
        XCTAssert(checkInt(j[Key.int], Value.int))
        XCTAssert(checkDouble(j[Key.double], Value.double))
        XCTAssert(checkBool(j[Key.boolTrue], Value.boolTrue))
        XCTAssert(checkBool(j[Key.boolFalse], Value.boolFalse))

        XCTAssert(checkInt(j[Key.objInt][Key.int], Value.int))
        XCTAssert(checkString(j[Key.objObj][Key.obj][Key.str], Value.str))
        XCTAssert(checkBool(j[Key.objArr][Key.arr][0], Value.boolTrue))
        XCTAssert(checkBool(j[Key.objArr][Key.arr][1], Value.boolFalse))
        XCTAssertTrue(j[Key.objEmpty].exists)

        XCTAssertFalse(j[Key.unknown].exists)
        XCTAssertFalse(j[Key.objInt][Key.unknown].exists)
        XCTAssertFalse(j[Key.objArr][Key.arr][Key.over].exists)
    }

    func testConvertString() {
        let dic = mix(basicTypeDictionary, baseObjDictionary)
        var fmt = basicTypeFormat
        fmt += baseObjFormat

        guard let json = try? JSON(data: try! JSONSerialization.data(withJSONObject: dic, options: []), format: fmt) else {
            XCTFail()
            return
        }
        guard let text = try? json.stringData() else {
            XCTFail()
            return
        }
        guard let data = text.data(using: .utf8) else {
            XCTFail()
            return
        }
        guard let obj = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
            XCTFail()
            return
        }

        XCTAssertEqual(obj[Key.str] as? String, Value.str)
        XCTAssertEqual(obj[Key.int] as? Int, Value.int)
        XCTAssertEqual(obj[Key.double] as? Double, Value.double)
        XCTAssertEqual(obj[Key.boolFalse] as? Bool, Value.boolFalse)
        XCTAssertEqual((obj[Key.objInt] as? [String: Any])?[Key.int] as? Int, Value.int)
        XCTAssertEqual(((obj[Key.objObj] as? [String: Any])?[Key.obj] as? [String: Any])?[Key.str] as? String, Value.str)
        XCTAssertEqual(((obj[Key.objArr] as? [String: Any])?[Key.arr] as? [Bool])?[1], false)

        guard let j = try? JSON(string: text, format: fmt) else {
            XCTFail()
            return
        }

        XCTAssert(checkString(j[Key.str], Value.str))
        XCTAssert(checkInt(j[Key.int], Value.int))
        XCTAssert(checkDouble(j[Key.double], Value.double))
        XCTAssert(checkBool(j[Key.boolTrue], Value.boolTrue))
        XCTAssert(checkBool(j[Key.boolFalse], Value.boolFalse))

        XCTAssert(checkInt(j[Key.objInt][Key.int], Value.int))
        XCTAssert(checkString(j[Key.objObj][Key.obj][Key.str], Value.str))
        XCTAssert(checkBool(j[Key.objArr][Key.arr][0], Value.boolTrue))
        XCTAssert(checkBool(j[Key.objArr][Key.arr][1], Value.boolFalse))
        XCTAssertTrue(j[Key.objEmpty].exists)

        XCTAssertFalse(j[Key.unknown].exists)
        XCTAssertFalse(j[Key.objInt][Key.unknown].exists)
        XCTAssertFalse(j[Key.objArr][Key.arr][Key.over].exists)
    }

    func testConvertNull() {
        let dic = mix(mix(nullTypeDictionary, nullObjDictionary), nullArrayDictionary)
        var fmt = nullTypeFormat
        fmt += nullObjFormat + nullArrayFormat

        guard let json = try? JSON(data: try! JSONSerialization.data(withJSONObject: dic, options: []), format: fmt) else {
            XCTFail()
            return
        }
        guard let data = try? json.data() else {
            XCTFail()
            return
        }
        guard let obj = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
            XCTFail()
            return
        }
        XCTAssertTrue(obj[Key.strN] is NSNull)
        XCTAssertTrue(obj[Key.intN] is NSNull)
        XCTAssertTrue(obj[Key.doubleN] is NSNull)
        XCTAssertTrue(obj[Key.boolN] is NSNull)
        XCTAssertTrue(obj["d2"] is NSNull)
        XCTAssertTrue(((obj["d3"] as? [String: Any])?["a"] as? [String: Any])?["c"] is NSNull)
        XCTAssertTrue((obj["a1"] as? [Any])?[1] is NSNull)
        XCTAssertTrue(((obj["a4"] as? [String: Any])?["ab"] as? [Any])?[0] is NSNull)
        XCTAssertTrue((obj["a5"] as? [[String: Any]])?[0]["a"] is NSNull)

        guard let j = try? JSON(data: data, format: fmt) else {
            XCTFail()
            return
        }

        XCTAssertTrue(j[Key.strN].isNull)
        XCTAssertTrue(j[Key.intN].isNull)
        XCTAssertTrue(j[Key.doubleN].isNull)
        XCTAssertTrue(j[Key.boolN].isNull)

        XCTAssertTrue(j["d2"].isNull)
        XCTAssertTrue(j["d3"]["a"]["c"].isNull)
        XCTAssertTrue(j["a1"][1].isNull)
        XCTAssertTrue(j["a4"]["ab"][0].isNull)
        XCTAssertTrue(j["a5"][0]["a"].isNull)
    }

    func testConvertNullString() {
        let dic = mix(mix(nullTypeDictionary, nullObjDictionary), nullArrayDictionary)
        var fmt = nullTypeFormat
        fmt += nullObjFormat + nullArrayFormat

        guard let json = try? JSON(data: try! JSONSerialization.data(withJSONObject: dic, options: []), format: fmt) else {
            XCTFail()
            return
        }
        guard let text = try? json.stringData() else {
            XCTFail()
            return
        }
        guard let data = text.data(using: .utf8) else {
            XCTFail()
            return
        }
        guard let obj = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
            XCTFail()
            return
        }

        XCTAssertTrue(obj[Key.strN] is NSNull)
        XCTAssertTrue(obj[Key.intN] is NSNull)
        XCTAssertTrue(obj[Key.doubleN] is NSNull)
        XCTAssertTrue(obj[Key.boolN] is NSNull)
        XCTAssertTrue(obj["d2"] is NSNull)
        XCTAssertTrue(((obj["d3"] as? [String: Any])?["a"] as? [String: Any])?["c"] is NSNull)
        XCTAssertTrue((obj["a1"] as? [Any])?[1] is NSNull)
        XCTAssertTrue(((obj["a4"] as? [String: Any])?["ab"] as? [Any])?[0] is NSNull)
        XCTAssertTrue((obj["a5"] as? [[String: Any]])?[0]["a"] is NSNull)

        guard let j = try? JSON(string: text, format: fmt) else {
            XCTFail()
            return
        }

        XCTAssertTrue(j[Key.strN].isNull)
        XCTAssertTrue(j[Key.intN].isNull)
        XCTAssertTrue(j[Key.doubleN].isNull)
        XCTAssertTrue(j[Key.boolN].isNull)

        XCTAssertTrue(j["d2"].isNull)
        XCTAssertTrue(j["d3"]["a"]["c"].isNull)
        XCTAssertTrue(j["a1"][1].isNull)
        XCTAssertTrue(j["a4"]["ab"][0].isNull)
        XCTAssertTrue(j["a5"][0]["a"].isNull)
    }

    func testNothingSetNull() {
        // nothingでも値ありで生成されれば後からnullを設定できる。その場合再変換では削除される
        let dic = mix(mix(basicTypeDictionary, baseObjDictionary), baseArrayDictionary)

        let fmt: JSON.Format = [
            Key.str: .stringOrNothing, Key.int: .intOrNothing, Key.double: .doubleOrNothing, Key.boolTrue: .boolOrNothing,
            Key.objInt: .object([Key.int: .intOrNothing]),
            Key.objArr: .objectOrNothing([Key.arr: .array(.bool)]),
            Key.objObj: .object([Key.obj: .objectOrNothing([Key.str: .string])]),
            Key.arrStr: .array(.stringOrNothing),
            Key.arrObj: .arrayOrNothing(.object([Key.bool: .bool])),
            Key.arrNest: .array(.arrayOrNothing(.int)),
            ]

        guard let j = try? JSON(data: try! JSONSerialization.data(withJSONObject: dic, options: []), format: fmt) else {
            XCTFail()
            return
        }

        j[Key.str] = JSONData.null
        j[Key.int] = JSONData.null
        j[Key.double] = JSONData.null
        j[Key.boolTrue] = JSONData.null
        j[Key.objInt][Key.int] = JSONData.null
        j[Key.objArr] = JSONData.null
        j[Key.objObj][Key.obj] = JSONData.null
        j[Key.arrStr][0] = JSONData.null
        j[Key.arrObj] = JSONData.null
        j[Key.arrNest][1] = JSONData.null

        XCTAssertTrue(j[Key.str].isNull)
        XCTAssertTrue(j[Key.int].isNull)
        XCTAssertTrue(j[Key.double].isNull)
        XCTAssertTrue(j[Key.boolTrue].isNull)
        XCTAssertTrue(j[Key.objInt][Key.int].isNull)
        XCTAssertTrue(j[Key.objArr].isNull)
        XCTAssertTrue(j[Key.objObj][Key.obj].isNull)
        XCTAssertTrue(j[Key.arrStr][0].isNull)
        XCTAssertTrue(j[Key.arrObj].isNull)
        XCTAssertTrue(j[Key.arrNest][1].isNull)

        j[Key.arrStr].append(array: [NSNull(), "test", "test2"])
        XCTAssertTrue(j[Key.arrStr][3].isNull)
        XCTAssert(checkString(j[Key.arrStr][4], "test"))
        j[Key.arrNest].append(array: [[999], NSNull()])
        XCTAssert(checkInt(j[Key.arrNest][2][0], 999))
        XCTAssertTrue(j[Key.arrNest][3].isNull)

        j.append(key: Key.objEmpty, type: .object([Key.bool: .bool]), data: [Key.bool: Value.bool])
        j[Key.objEmpty].append(key: Key.str, type: .string, data: Value.str)
        j[Key.objEmpty].append(key: Key.doubleNo, type: .doubleOrNothing, data: NSNull())
        j[Key.objEmpty].append(key: Key.arrInt, type: .array(.intOrNull), data: [0, NSNull()])

        XCTAssert(checkBool(j[Key.objEmpty][Key.bool], Value.bool))
        XCTAssert(checkString(j[Key.objEmpty][Key.str], Value.str))
        XCTAssertTrue(j[Key.objEmpty][Key.doubleNo].isNull)
        XCTAssert(checkInt(j[Key.objEmpty][Key.arrInt][0], 0))
        XCTAssertTrue(j[Key.objEmpty][Key.arrInt][1].isNull)

        do {
            guard let data = try? j.data() else {
                XCTFail()
                return
            }
            guard let obj = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
                XCTFail()
                return
            }

            XCTAssertNil(obj[Key.str])
            XCTAssertNil(obj[Key.int])
            XCTAssertNil(obj[Key.double])
            XCTAssertNil(obj[Key.boolTrue])
            XCTAssertNotNil(obj[Key.objInt] as? [String: Any])
            XCTAssertTrue((obj[Key.objInt] as? [String: Any])?.isEmpty ?? false)
            XCTAssertNil(obj[Key.objArr])
            XCTAssertNotNil(obj[Key.objObj] as? [String: Any])
            XCTAssertTrue((obj[Key.objObj] as? [String: Any])?.isEmpty ?? false)
            XCTAssertEqual((obj[Key.arrStr] as? [String])?[0], "b")
            XCTAssertEqual((obj[Key.arrStr] as? [String])?[1], "c")
            XCTAssertNil(obj[Key.arrObj])
            XCTAssertEqual((obj[Key.arrNest] as? [[Int]])?.count, 2)
            XCTAssertEqual((obj[Key.arrNest] as? [[Int]])?[1][0], 999)
            XCTAssertEqual((obj[Key.arrStr] as? [String])?[2], "test")

            XCTAssertEqual((obj[Key.objEmpty] as? [String: Any])?[Key.bool] as? Bool, Value.bool)
            XCTAssertEqual((obj[Key.objEmpty] as? [String: Any])?[Key.str] as? String, Value.str)
            XCTAssertNil((obj[Key.objEmpty] as? [String: Any])?[Key.doubleNo])
            XCTAssertEqual(((obj[Key.objEmpty] as? [String: Any])?[Key.arrInt] as? [Any])?[0] as? Int, 0)
            XCTAssertTrue(((obj[Key.objEmpty] as? [String: Any])?[Key.arrInt] as? [Any])?[1] is NSNull)
        }
        do {
            guard let text = try? j.stringData() else {
                XCTFail()
                return
            }
            guard let data = text.data(using: .utf8) else {
                XCTFail()
                return
            }
            guard let obj = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
                XCTFail()
                return
            }

            XCTAssertNil(obj[Key.str])
            XCTAssertNil(obj[Key.int])
            XCTAssertNil(obj[Key.double])
            XCTAssertNil(obj[Key.boolTrue])
            XCTAssertNotNil(obj[Key.objInt] as? [String: Any])
            XCTAssertTrue((obj[Key.objInt] as? [String: Any])?.isEmpty ?? false)
            XCTAssertNil(obj[Key.objArr])
            XCTAssertNotNil(obj[Key.objObj] as? [String: Any])
            XCTAssertTrue((obj[Key.objObj] as? [String: Any])?.isEmpty ?? false)
            XCTAssertEqual((obj[Key.arrStr] as? [String])?[0], "b")
            XCTAssertEqual((obj[Key.arrStr] as? [String])?[1], "c")
            XCTAssertNil(obj[Key.arrObj])
            XCTAssertEqual((obj[Key.arrNest] as? [[Int]])?.count, 2)
            XCTAssertEqual((obj[Key.arrNest] as? [[Int]])?[1][0], 999)
            XCTAssertEqual((obj[Key.arrStr] as? [String])?[2], "test")

            XCTAssertEqual((obj[Key.objEmpty] as? [String: Any])?[Key.bool] as? Bool, Value.bool)
            XCTAssertEqual((obj[Key.objEmpty] as? [String: Any])?[Key.str] as? String, Value.str)
            XCTAssertNil((obj[Key.objEmpty] as? [String: Any])?[Key.doubleNo])
            XCTAssertEqual(((obj[Key.objEmpty] as? [String: Any])?[Key.arrInt] as? [Any])?[0] as? Int, 0)
            XCTAssertTrue(((obj[Key.objEmpty] as? [String: Any])?[Key.arrInt] as? [Any])?[1] is NSNull)
        }
    }

    func testSkelton() {
        guard let j = try? JSON(skeletonFormat: basicTypeFormat) else {
            XCTFail()
            return
        }

        j[Key.str] = JSONData.value(Value.str)
        j[Key.int] = JSONData.value(Value.int)
        j[Key.double] = JSONData.value(Value.double)
        j[Key.boolTrue] = JSONData.value(Value.boolTrue)

        XCTAssert(checkString(j[Key.str], Value.str))
        XCTAssert(checkInt(j[Key.int], Value.int))
        XCTAssert(checkDouble(j[Key.double], Value.double))
        XCTAssert(checkBool(j[Key.boolTrue], Value.boolTrue))

        j[Key.str] = JSONData.value("text2")
        j[Key.int] = JSONData.value(21)
        j[Key.double] = JSONData.value(1.73)
        j[Key.boolTrue] = JSONData.value(false)

        XCTAssert(checkString(j[Key.str], "text2"))
        XCTAssert(checkInt(j[Key.int], 21))
        XCTAssert(checkDouble(j[Key.double], 1.73))
        XCTAssert(checkBool(j[Key.boolTrue], false))

        j.append(key: Key.strN, type: .string, data: "test")
        j.append(key: Key.intN, type: .int, data: 100)
        j.append(key: Key.doubleN, type: .double, data: 2.36)
        j.append(key: Key.boolN, type: .bool, data: true)

        XCTAssert(checkString(j[Key.strN], "test"))
        XCTAssert(checkInt(j[Key.intN], 100))
        XCTAssert(checkDouble(j[Key.doubleN], 2.36))
        XCTAssert(checkBool(j[Key.boolN], true))
    }

    func testSkeltonNull() {
        guard let j = try? JSON(skeletonFormat: nullTypeFormat) else {
            XCTFail()
            return
        }

        XCTAssertTrue(j[Key.strN].isNull)
        XCTAssertTrue(j[Key.intN].isNull)
        XCTAssertTrue(j[Key.doubleN].isNull)
        XCTAssertTrue(j[Key.boolN].isNull)

        j[Key.strN] = JSONData.value("text2")
        j[Key.intN] = JSONData.value(21)
        j[Key.doubleN] = JSONData.value(1.73)
        j[Key.boolN] = JSONData.value(false)

        XCTAssert(checkString(j[Key.strN], "text2"))
        XCTAssert(checkInt(j[Key.intN], 21))
        XCTAssert(checkDouble(j[Key.doubleN], 1.73))
        XCTAssert(checkBool(j[Key.boolN], false))

        j[Key.strN] = JSONData.null
        j[Key.intN] = JSONData.null
        j[Key.doubleN] = JSONData.null
        j[Key.boolN] = JSONData.null

        XCTAssertTrue(j[Key.strN].isNull)
        XCTAssertTrue(j[Key.intN].isNull)
        XCTAssertTrue(j[Key.doubleN].isNull)
        XCTAssertTrue(j[Key.boolN].isNull)

        j.append(key: Key.str, type: .stringOrNull, data: "test")
        j.append(key: Key.int, type: .intOrNull, data: 100)
        j.append(key: Key.double, type: .doubleOrNull, data: 2.36)
        j.append(key: Key.bool, type: .boolOrNull, data: true)

        XCTAssert(checkString(j[Key.str], "test"))
        XCTAssert(checkInt(j[Key.int], 100))
        XCTAssert(checkDouble(j[Key.double], 2.36))
        XCTAssert(checkBool(j[Key.bool], true))

        j.append(key: Key.strNo, type: .stringOrNull, data: NSNull())
        j.append(key: Key.intNo, type: .intOrNull, data: NSNull())
        j.append(key: Key.doubleNo, type: .doubleOrNull, data: NSNull())
        j.append(key: Key.boolNo, type: .boolOrNull, data: NSNull())

        XCTAssertTrue(j[Key.strNo].isNull)
        XCTAssertTrue(j[Key.intNo].isNull)
        XCTAssertTrue(j[Key.doubleNo].isNull)
        XCTAssertTrue(j[Key.boolNo].isNull)
    }

    func testSkeltonNothing() {
        guard let j = try? JSON(skeletonFormat: nothingTypeFormat) else {
            XCTFail()
            return
        }

        XCTAssertTrue(j[Key.strNo].isNull)
        XCTAssertTrue(j[Key.intNo].isNull)
        XCTAssertTrue(j[Key.doubleNo].isNull)
        XCTAssertTrue(j[Key.boolNo].isNull)

        j[Key.strNo] = JSONData.value("text2")
        j[Key.intNo] = JSONData.value(21)
        j[Key.doubleNo] = JSONData.value(1.73)
        j[Key.boolNo] = JSONData.value(false)

        XCTAssert(checkString(j[Key.strNo], "text2"))
        XCTAssert(checkInt(j[Key.intNo], 21))
        XCTAssert(checkDouble(j[Key.doubleNo], 1.73))
        XCTAssert(checkBool(j[Key.boolNo], false))

        j[Key.strNo] = JSONData.null
        j[Key.intNo] = JSONData.null
        j[Key.doubleNo] = JSONData.null
        j[Key.boolNo] = JSONData.null

        XCTAssertTrue(j[Key.strNo].isNull)
        XCTAssertTrue(j[Key.intNo].isNull)
        XCTAssertTrue(j[Key.doubleNo].isNull)
        XCTAssertTrue(j[Key.boolNo].isNull)

        j.append(key: Key.str, type: .stringOrNothing, data: "test")
        j.append(key: Key.int, type: .intOrNothing, data: 100)
        j.append(key: Key.double, type: .doubleOrNothing, data: 2.36)
        j.append(key: Key.bool, type: .boolOrNothing, data: true)

        XCTAssert(checkString(j[Key.str], "test"))
        XCTAssert(checkInt(j[Key.int], 100))
        XCTAssert(checkDouble(j[Key.double], 2.36))
        XCTAssert(checkBool(j[Key.bool], true))

        j.append(key: Key.strN, type: .stringOrNothing, data: NSNull())
        j.append(key: Key.intN, type: .intOrNothing, data: NSNull())
        j.append(key: Key.doubleN, type: .doubleOrNothing, data: NSNull())
        j.append(key: Key.boolN, type: .boolOrNothing, data: NSNull())

        XCTAssertTrue(j[Key.strN].isNull)
        XCTAssertTrue(j[Key.intN].isNull)
        XCTAssertTrue(j[Key.doubleN].isNull)
        XCTAssertTrue(j[Key.boolN].isNull)
    }

    func testSkeltonNullObject() {
        guard let j = try? JSON(skeletonFormat: nullObjFormat) else {
            XCTFail()
            return
        }

        j["d1"]["a"] = JSONData.value("test")
        j["d1"]["b"] = JSONData.value(100)
        j["d1"]["c"] = JSONData.value(1.73)
        j["d1"]["d"] = JSONData.value(true)

        XCTAssert(checkString(j["d1"]["a"], "test"))
        XCTAssert(checkInt(j["d1"]["b"], 100))
        XCTAssert(checkDouble(j["d1"]["c"], 1.73))
        XCTAssert(checkBool(j["d1"]["d"], true))

        j["d1"]["a"] = JSONData.null
        j["d1"]["b"] = JSONData.null
        j["d1"]["c"] = JSONData.null
        j["d1"]["d"] = JSONData.null
        j["d2"] = JSONData.null
        j["d3"]["a"]["d"] = JSONData.null

        XCTAssertTrue(j["d1"]["a"].isNull)
        XCTAssertTrue(j["d1"]["b"].isNull)
        XCTAssertTrue(j["d1"]["c"].isNull)
        XCTAssertTrue(j["d1"]["d"].isNull)
        XCTAssertTrue(j["d2"].isNull)
        XCTAssertTrue(j["d3"]["a"]["d"].isNull)

        j["d1"] = JSONData.null
        XCTAssertTrue(j["d1"].isNull)
        XCTAssertFalse(j["d1"]["a"].exists)
    }

    func testSkeltonNullArray() {
        let format: JSON.Format = ["a1": .arrayOrNull(.stringOrNull), "a2": .arrayOrNull(.intOrNull),
                                   "d3": .objectOrNull(["a3": .arrayOrNull(.doubleOrNull), "a4": .arrayOrNull(.boolOrNull)])]
        guard let j = try? JSON(skeletonFormat: format) else {
            XCTFail()
            return
        }

        XCTAssertEqual(j["a1"].array.count, 0)
        XCTAssertEqual(j["d3"]["a3"].array.count, 0)

        j["a1"].append(array: ["test", NSNull()])
        j["a2"].append(array: [NSNull(), 100])
        j["d3"]["a3"].append(array: [0.5, NSNull()])
        j["d3"]["a4"].append(array: [false, NSNull(), true])

        XCTAssert(checkString(j["a1"][0], "test"))
        XCTAssertTrue(j["a1"][1].isNull)
        XCTAssert(checkInt(j["a2"][1], 100))
        XCTAssertTrue(j["a2"][0].isNull)
        XCTAssert(checkDouble(j["d3"]["a3"][0], 0.5))
        XCTAssertTrue(j["d3"]["a3"][1].isNull)
        XCTAssert(checkBool(j["d3"]["a4"][0], false))
        XCTAssert(checkBool(j["d3"]["a4"][2], true))
        XCTAssertTrue(j["d3"]["a4"][1].isNull)
    }

    func testObject() {
        let dic: [String: Any] = [
            Key.objObj: [:], Key.objArr: [[Key.arrObj: 0]]
        ]
        let data = try! JSONSerialization.data(withJSONObject: dic, options: [])
        let format: JSON.Format = [
            Key.objObj: .object(([Key.bool: .boolOrNothing])),
            Key.objArr: .array(.object([Key.arrObj: .int]))
        ]
        guard let j = try? JSON(data: data, format: format) else {
            XCTFail()
            return
        }

        j.append(key: Key.str, type: .string, data: Value.str)
        j.append(key: Key.int, type: .int, data: Value.int)
        j.append(key: Key.double, type: .double, data: Value.double)
        j.append(key: Key.bool, type: .bool, data: Value.bool)
        j.append(key: Key.arrStr, type: .array(.string), data: Value.arrStr)
        j.append(key: Key.objInt, type: .object([Key.int: .int]), data: [Key.int: Value.int])

        XCTAssert(checkString(j[Key.str], Value.str))
        XCTAssert(checkInt(j[Key.int], Value.int))
        XCTAssert(checkDouble(j[Key.double], Value.double))
        XCTAssert(checkBool(j[Key.bool], Value.bool))
        XCTAssert(checkString(j[Key.arrStr][2], Value.arrStr[2]))
        XCTAssert(checkInt(j[Key.objInt][Key.int], Value.int))

        j[Key.objObj].append(key: Key.str, type: .string, data: Value.str)
        j[Key.objObj].append(key: Key.int, type: .int, data: Value.int)
        j[Key.objObj].append(key: Key.double, type: .double, data: Value.double)
        j[Key.objObj].append(key: Key.bool, type: .bool, data: Value.bool)
        j[Key.objObj].append(key: Key.arrStr, type: .array(.string), data: Value.arrStr)
        j[Key.objObj].append(key: Key.objInt, type: .object([Key.int: .int]), data: [Key.int: Value.int])

        XCTAssert(checkString(j[Key.objObj][Key.str], Value.str))
        XCTAssert(checkInt(j[Key.objObj][Key.int], Value.int))
        XCTAssert(checkDouble(j[Key.objObj][Key.double], Value.double))
        XCTAssert(checkBool(j[Key.objObj][Key.bool], Value.bool))
        XCTAssert(checkString(j[Key.objObj][Key.arrStr][2], Value.arrStr[2]))
        XCTAssert(checkInt(j[Key.objObj][Key.objInt][Key.int], Value.int))

        j[Key.objArr][0].append(key: Key.str, type: .string, data: Value.str)
        j[Key.objArr][0].append(key: Key.int, type: .int, data: Value.int)
        j[Key.objArr][0].append(key: Key.double, type: .double, data: Value.double)
        j[Key.objArr][0].append(key: Key.bool, type: .bool, data: Value.bool)
        j[Key.objArr][0].append(key: Key.arrStr, type: .array(.string), data: Value.arrStr)
        j[Key.objArr][0].append(key: Key.objInt, type: .object([Key.int: .int]), data: [Key.int: Value.int])

        XCTAssert(checkString(j[Key.objArr][0][Key.str], Value.str))
        XCTAssert(checkInt(j[Key.objArr][0][Key.int], Value.int))
        XCTAssert(checkDouble(j[Key.objArr][0][Key.double], Value.double))
        XCTAssert(checkBool(j[Key.objArr][0][Key.bool], Value.bool))
        XCTAssert(checkString(j[Key.objArr][0][Key.arrStr][2], Value.arrStr[2]))
        XCTAssert(checkInt(j[Key.objArr][0][Key.objInt][Key.int], Value.int))

        j.append(key: Key.str, type: .stringOrNull, data: NSNull())
        j.append(key: Key.int, type: .intOrNull, data: NSNull())
        j.append(key: Key.double, type: .doubleOrNull, data: NSNull())
        j.append(key: Key.bool, type: .boolOrNull, data: NSNull())
        j.append(key: Key.arrStr, type: .arrayOrNull(.string), data: NSNull())
        j.append(key: Key.objInt, type: .objectOrNull([Key.int: .int]), data: NSNull())

        XCTAssertTrue(j[Key.str].isNull)
        XCTAssertTrue(j[Key.int].isNull)
        XCTAssertTrue(j[Key.double].isNull)
        XCTAssertTrue(j[Key.bool].isNull)
        XCTAssertTrue(j[Key.arrStr].isNull)
        XCTAssertTrue(j[Key.objInt].isNull)
    }

    func testRemove() {
        let data = try! JSONSerialization.data(withJSONObject: baseObjDictionary, options: [])
        guard let j = try? JSON(data: data, format: baseObjFormat)  else {
            XCTFail()
            return
        }

        j.removeValue(forKey: Key.objInt)
        j[Key.objObj].removeValue(forKey: Key.obj)

        XCTAssertFalse(j[Key.objInt].exists)
        XCTAssertTrue(j[Key.objObj].exists)
        XCTAssertFalse(j[Key.objObj][Key.obj].exists)

        j[Key.objArr][Key.arr].remove(at: 0)
        XCTAssert(checkBool(j[Key.objArr][Key.arr][0], Value.boolFalse))

        j[Key.objArr][Key.arr].removeAll()
        XCTAssertEqual(j[Key.objArr][Key.arr].array.count, 0)
        j[Key.objArr].removeAll()
        XCTAssertFalse(j[Key.objArr][Key.arr].exists)

        j.removeAll()
        XCTAssertFalse(j[Key.objEmpty].exists)
    }

    func testOperator() {
        var format = basicTypeFormat + [Key.str: .int, Key.strN: .string]
        if let type = format[Key.str], case .int = type {
        } else {
            XCTAssertNil(nil)
        }
        if let type = format[Key.strN], case .string = type {
        } else {
            XCTAssertNil(nil)
        }

        format += [Key.str: .string, Key.strN: .stringOrNull]
        if let type = format[Key.str], case .string = type {
        } else {
            XCTAssertNil(nil)
        }
        if let type = format[Key.strN], case .stringOrNull = type {
        } else {
            XCTAssertNil(nil)
        }

        let data = try! JSONSerialization.data(withJSONObject: basicTypeDictionary, options: [])
        guard let j = try? JSON(data: data, format: basicTypeFormat)  else {
            XCTFail()
            return
        }
        do {
            try j.update {
                j[Key.str] = JSONData.value(Value.str)
            }
        } catch {
            XCTFail()
        }
    }

    func testError() {
        do {
            let text = "{\(DQ(Key.arr)): [0, \(DQ("a"))]}"
            XCTAssertThrowsError(try JSON(string: text, format: [Key.arr: .array(.int)]))
        }
        do {
            let text = "{\(DQ(Key.obj)): [0, \(DQ("a"))]}"
            XCTAssertThrowsError(try JSON(string: text, format: [Key.obj: .object([Key.int: .int])]))
        }
        do {
            let data = "{::}".data(using: .utf8)!
            XCTAssertThrowsError(try JSON(data: data, format: basicTypeFormat))
        }

        let text = "{\(DQ(Key.str)): \(DQ("あいうえお")), \(DQ(Key.arr)): \(Value.arrInt),"
            + "\(DQ(Key.arr)): \(Value.arrInt), \(DQ(Key.obj)): {\(DQ(Key.str)): \(DQ(Value.str))}}"
        XCTAssertThrowsError(try JSON(string: text, using: .ascii, format: basicTypeFormat))

        guard let j = try? JSON(string: text, format: [Key.str: .string, Key.arr: .array(.int)])  else {
            XCTFail()
            return
        }
        XCTAssertThrowsError(try j.stringData(using: String.Encoding(rawValue: 1000)))

        XCTAssertThrowsError(try JSON(skeletonFormat: [Key.str: .forWrap]))
        XCTAssertThrowsError(try j.update { j[Key.unknown] = JSONData.value(Value.str) })

        XCTAssertNil(try? j.update { j.append(key: Key.strN, type: .string, data: 100) })
        XCTAssertFalse(j[Key.strN].exists)
        XCTAssertNil(try? j.update { j.removeValue(forKey: Key.strN) })
        XCTAssertEqual(j[Key.str].array.count, 0)
        XCTAssertFalse(j[Key.arr][Key.unknown].exists)
        XCTAssertThrowsError(try j.update { j[Key.arr] = JSONData.value(Value.str) })
        XCTAssertThrowsError(try j.update { j[Key.obj][Key.str] = JSONData.value(Value.str) })
        XCTAssertThrowsError(try j.update { j[Key.arr] = j[Key.obj] })
        XCTAssertThrowsError(try j.update { j[Key.obj][Key.str] = j[Key.obj] })
        XCTAssertThrowsError(try j.update { j[Key.arr][Key.over] = JSONData.value(Value.int) })
        XCTAssertThrowsError(try j.update { j[Key.obj][0] = j[Key.obj][1] })
        XCTAssertThrowsError(try j.update { j[Key.arr][0] = j[Key.obj] })
        XCTAssertThrowsError(try j.update { j[Key.strN].append(array: [0]) })
        XCTAssertThrowsError(try j.update { j[Key.strN].append(key: Key.int, type: .int, data: 0) })
        XCTAssertNil(try? j.update { j[Key.arr].append(key: Key.strN, type: .string, data: 100) })
        XCTAssertThrowsError(try j.update { j[Key.strN].removeValue(forKey: Key.int) })
        XCTAssertThrowsError(try j.update { j[Key.strN].remove(at: 0) })
        XCTAssertThrowsError(try j.update { j[Key.arr].remove(at: Key.over) })
        XCTAssertThrowsError(try j.update { j[Key.strN].removeAll() })
        XCTAssertFalse(j[Key.str].isNull)
        XCTAssertNil(try? j.update { j[Key.str] = JSONData.null })
        XCTAssertNil(try? j.update { j[Key.str] = j[Key.strN] })
        XCTAssertNil(try? j.update { j[Key.str] = j[Key.strN] })

        guard let sk = try? JSON(skeletonFormat: [Key.obj: .object([Key.str: .string])]) else {
            XCTFail()
            return
        }
        sk[Key.obj].append(key: Key.strN, type: .string, data: Value.str)
        XCTAssertThrowsError(try sk.data())

        XCTAssertThrowsError(try JSON(skeletonFormat: [Key.obj: .object([Key.arr: .array(.forWrap)])]))

    }
}

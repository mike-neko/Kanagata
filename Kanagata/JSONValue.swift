////////////////////////////////////////////////////////////////////////////////////
//
//  JSONValue.swift
//  Kanagata
//
//  MIT License
//
//  Copyright (c) 2018 mike-neko
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////////

import Foundation

extension JSONData {
    // MARK: - ValueType

    /// JSONデータのフォーマット
    ///
    /// - string:                           Stringに対応
    /// - int:                              Intに対応
    /// - double:                           Doubleに対応
    /// - bool:                             Boolに対応
    /// - array(ValueType):                 [ValueType]に対応
    /// - object([(Key, ValueType)]):       [(Key, ValueType)]に対応
    ///
    /// **元データに`null`が含まれている場合の挙動**
    ///
    /// フォーマット指定で
    /// - 何も付加されていない:                   フォーマット不一致でエラーになる
    /// - `OrNull`が付加:                      値として`null`が設定される
    /// - `OrNothing`が付加:                   オブジェクト自体が存在しない扱いとなり生成後のJSONデータには含まれない
    ///
    /// **スケルトン作成時の挙動**
    /// フォーマット指定で
    /// - 何も付加されていない:                   空の状態となるので値の設定が必要
    /// - `OrNull`が付加:                      値として`null`が設定される
    /// - `OrNothing`が付加:                   空の状態となるので値の設定が必要
    public indirect enum ValueType {
        case string, stringOrNull, stringOrNothing
        case int, intOrNull, intOrNothing
        case double, doubleOrNull, doubleOrNothing
        case bool, boolOrNull, boolOrNothing
        case array(ValueType), arrayOrNull(ValueType), arrayOrNothing(ValueType)
        case object([Key: ValueType]), objectOrNull([Key: ValueType]), objectOrNothing([Key: ValueType])

        case forWrap  // 子要素やエラーのラップ用

        /// `(フォーマット)OrNull`の場合は`true`
        var canNullable: Bool {
            switch self {
            case .stringOrNull, .intOrNull, .doubleOrNull, .boolOrNull, .arrayOrNull, .objectOrNull:
                return true
            default: return false
            }
        }

        /// `(フォーマット)OrNothing`の場合は`true`
        var canNothing: Bool {
            switch self {
            case .stringOrNothing, .intOrNothing, .doubleOrNothing,
                 .boolOrNothing, .arrayOrNothing, .objectOrNothing:
                return true
            default:
                return false
            }
        }
    }

    // JSONの値クラス
    indirect enum Value {
        case string(String)
        case int(Int)
        case double(Double)
        case bool(Bool)
        case array([JSONData])
        case object(ObjectDictionary)
        case null

        case error(ExceptionType)       // 取得時にエラーとなった場合
        case assignment(Any)            // 値を設定する時のラップ用
        case empty                      // スケルトン用

        init?(skeletonType: ValueType) {
            switch skeletonType {
            case .stringOrNull, .stringOrNothing,
                 .intOrNull, .intOrNothing,
                 .doubleOrNull, .doubleOrNothing,
                 .boolOrNull, .boolOrNothing:
                self = .null

            case .string, .int, .double, .bool:
                self = .empty

            case .array(let def), .arrayOrNull(let def), .arrayOrNothing(let def):
                guard let item = Value(skeletonType: def) else { return nil }
                if case .null = item {
                    self = .array([])
                } else {
                    self = .array([JSONData(key: "", data: item, type: def)])
                }

            case .object(let defList), .objectOrNull(let defList), .objectOrNothing(let defList):

                var list = ObjectDictionary()
                for def in defList {
                    let key = def.0, type = def.1
                    guard let value = Value(skeletonType: type) else { return nil }
                    list[key] = JSONData(key: key, data: value, type: type)
                }
                self = .object(list)

            case .forWrap: return nil
            }
        }

        init?(type: ValueType, value: Any) {
            if type.canNullable && value is NSNull {
                self = .null
                return
            }

            switch type {
            case .string, .stringOrNull, .stringOrNothing:
                guard let val = value as? String else { return nil }
                self = .string(val)

            case .int, .intOrNull, .intOrNothing:
                guard let val = value as? Int else { return nil }
                self = .int(val)

            case .double, .doubleOrNull, .doubleOrNothing:
                guard let val = value as? Double else { return nil }
                self = .double(val)

            case .bool, .boolOrNull, .boolOrNothing:
                guard let val = value as? Bool else { return nil }
                self = .bool(val)

            case .array(let def), .arrayOrNull(let def), .arrayOrNothing(let def):
                guard let list = value as? [Any] else { return nil }

                var arr = [JSONData]()
                for element in list {
                    if def.canNothing && element is NSNull {
                        continue
                    }
                    guard let item = Value(type: def, value: element) else { return nil }
                    arr += [JSONData(key: "", data: item, type: def)]
                }
                self = .array(arr)

            case .object(let defList), .objectOrNull(let defList), .objectOrNothing(let defList):
                guard let dic = value as? [String: Any] else { return nil }
                var list = ObjectDictionary()
                for def in defList {
                    let key = def.0, type = def.1

                    // XCTest用に崩して書く
                    let data: Value
                    if let d = dic[key] {
                        if d is NSNull && type.canNothing {
                            continue
                        }
                        guard let value = Value(type: type, value: d) else { return nil }
                        data = value
                        list[key] = JSONData(key: key, data: data, type: type)
                        continue
                    }
                    if type.canNullable {
                        data = .null
                        list[key] = JSONData(key: key, data: data, type: type)
                        continue
                    }
                    if type.canNothing {
                        continue
                    }
                    return nil
                }
                self = .object(list)

            case .forWrap: return nil
            }
        }

        var isNull: Bool {
            if case .null = self {
                return true
            }
            return false
        }

        var exists: Bool {
            switch self {
            case .string, .int, .double, .bool, .array, .object, .null:
                return true
            default:
                return false
            }
        }

        enum ConvertError: Error {
            case type, empty
        }

        func toAny() throws -> Any {
            switch self {
            case .string(let val): return val
            case .int(let val): return val
            case .double(let val): return val
            case .bool(let val): return val
            case .array(let list):
                return try list.flatMap { obj -> Any? in
                    let val = try obj.toAny()
                    if val is NSNull && obj.type.canNothing {
                        return nil
                    }
                    return val
                }
            case .object(let objs):
                var dic: [String: Any] = [:]
                try objs.forEach {
                    let val = try $0.value.toAny()
                    if val is NSNull && $0.value.type.canNothing {
                        return
                    }
                    dic[$0.key] = try $0.value.toAny()
                }
                return dic
            case .null: return NSNull()
            case .error, .assignment: throw ConvertError.type
            case .empty: throw ConvertError.empty
            }
        }
    }
}

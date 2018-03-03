////////////////////////////////////////////////////////////////////////////////////
//
//  JSONData.swift
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

/// JSONのデータクラス
public class JSONData {
    public typealias Key = String
    typealias ObjectDictionary = [Key: JSONData]
    typealias ObjectDefine = (Key, ValueType)
    public typealias ExceptionType = JSON.ExceptionType

    // MARK: - Property
    /// キー
    public let key: Key
    var data: Value                 // 値
    let type: ValueType             // フォーマット

    /// `null`が入っていれば`true`、入っていなければ`false`。エラーの場合も`false`
    public var isNull: Bool { return data.isNull }
    /// データが存在すれば`true`、エラーデータであれば`false`
    public var exists: Bool { return data.exists }
    private var objectDefine: ObjectDefine { return (key, type) }

    /// JSONデータの配列を取得する。`array`であれば`JSONData`の配列を取得し、それ以外は空の配列が取得される
    public var array: [JSONData] {
        guard case .array(let list) = data else { return [] }
        return list
    }

    // MARK: - Method
    init(key: Key, data: Value, type: ValueType) {
        self.key = key
        self.data = data
        self.type = type
    }

    /// objectから指定したキーのJSONデータを取得する
    ///
    /// - Parameter key: 取得対象のキー
    /// - returns: 指定したキーのデータ。キーが存在しない時は`ExceptionType.notFound`。objectでは無い時は`ExceptionType.notObject`
    public subscript(key: Key) -> JSONData {
        get {
            if case .object(let objs) = data {
                return objs[key] ?? JSONData(key: key,
                                             data: .error(.notFound(parent: self, accessKey: key)), type: .forWrap)
            }
            return JSONData(key: key, data: .error(.notObject(data: self, accessKey: key)), type: .forWrap)
        }

        set {
            guard case .object(var objs) = data else {
                JSON.errorList.append(.notObject(data: self, accessKey: key))
                return
            }
            guard let child = objs[key] else {
                JSON.errorList.append(.notFound(parent: self, accessKey: key))
                return
            }

            switch newValue.data {
            case .assignment(let valueObj):
                let newData: Value
                if valueObj is NSNull && (newValue.type.canNullable || child.type.canNothing) {
                    newData = .null
                } else if let val = Value(type: child.type, value: valueObj) {
                    newData = val
                } else {
                    JSON.errorList.append(.typeUnmatch(key: objectDefine.0, type: objectDefine.1, value: newValue))
                    return
                }
                objs[key] = JSONData(key: child.key, data: newData, type: child.type)
                data = .object(objs)
            default:
                JSON.errorList.append(.typeUnmatch(key: objectDefine.0, type: objectDefine.1, value: newValue))
                return
            }
        }
    }

    /// objectから指定したキーのJSONデータを`String`型で取得する
    ///
    /// - Parameters:
    ///   - key: 取得対象のキー
    ///   - value: 指定したキーでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したキーのデータ。キーが存在しない、objectでは無い、または指定した`String`型ではなかった時はデフォルト値
    public subscript(key: Key, default value: String) -> String {
        return self[key].value(default: value)
    }

    /// objectから指定したキーのJSONデータを`Int`型で取得する
    ///
    /// - Parameters:
    ///   - key: 取得対象のキー
    ///   - value: 指定したキーでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したキーのデータ。キーが存在しない、objectでは無い、または指定した`Int`型ではなかった時はデフォルト値
    public subscript(key: Key, default value: Int) -> Int {
        return self[key].value(default: value)
    }

    /// objectから指定したキーのJSONデータを`Double`型で取得する
    ///
    /// - Parameters:
    ///   - key: 取得対象のキー
    ///   - value: 指定したキーでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したキーのデータ。キーが存在しない、objectでは無い、または指定した`Double`型ではなかった時はデフォルト値
    public subscript(key: Key, default value: Double) -> Double {
        return self[key].value(default: value)
    }

    /// objectから指定したキーのJSONデータを`Bool`型で取得する
    ///
    /// - Parameters:
    ///   - key: 取得対象のキー
    ///   - value: 指定したキーでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したキーのデータ。キーが存在しない、objectでは無い、または指定した`Bool`型ではなかった時はデフォルト値
    public subscript(key: Key, default value: Bool) -> Bool {
        return self[key].value(default: value)
    }

    /// arrayから指定したインデックスのJSONデータを取得する
    ///
    /// - Parameter index: 取得対象のインデックス
    /// - returns: 指定したインデックスのデータ。インデックスが存在しない時は`ExceptionType.outOfRange`。arrayでは無い時は`ExceptionType.notArray`
    public subscript(index: Int) -> JSONData {
        get {
            if case .array(let arr) = data {
                guard arr.indices.contains(index) else {
                    return JSONData(key: key, data: .error(.outOfRange(parent: self, index: index)), type: .forWrap)
                }
                return arr[index]
            }

            return JSONData(key: key, data: .error(.notArray(data: self)), type: .forWrap)
        }

        set {
            guard case .array(var arr) = data else {
                JSON.errorList.append(.notArray(data: self))
                return
            }
            guard arr.indices.contains(index) else {
                JSON.errorList.append(.outOfRange(parent: self, index: index))
                return
            }

            let element = arr[index]
            switch newValue.data {
            case .assignment(let valueObj):
                let newData: Value
                if valueObj is NSNull && (newValue.type.canNullable || element.type.canNothing) {
                    newData = .null
                } else if let val = Value(type: element.type, value: valueObj) {
                    newData = val
                } else {
                    JSON.errorList.append(.typeUnmatch(key: objectDefine.0, type: objectDefine.1, value: newValue))
                    return
                }
                arr[index] = JSONData(key: element.key, data: newData, type: element.type)
                data = .array(arr)
            default:
                JSON.errorList.append(.typeUnmatch(key: objectDefine.0, type: objectDefine.1, value: newValue))
                return
            }
        }
    }

    /// arrayから指定したインデックスのJSONデータを`String`型で取得する
    ///
    /// - Parameters:
    ///   - index: 取得対象のインデックス
    ///   - value: 指定したインデックスでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したインデックスのデータ。インデックスが存在しない、arrayでは無い、または指定した`String`型ではなかった時はデフォルト値
    public subscript(index: Int, default value: String) -> String {
        return self[index].value(default: value)
    }

    /// arrayから指定したインデックスのJSONデータを`Int`型で取得する
    ///
    /// - Parameters:
    ///   - index: 取得対象のインデックス
    ///   - value: 指定したインデックスでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したインデックスのデータ。インデックスが存在しない、arrayでは無い、または指定した`Int`型ではなかった時はデフォルト値
    public subscript(index: Int, default value: Int) -> Int {
        return self[index].value(default: value)
    }

    /// arrayから指定したインデックスのJSONデータを`Double`型で取得する
    ///
    /// - Parameters:
    ///   - index: 取得対象のインデックス
    ///   - value: 指定したインデックスでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したインデックスのデータ。インデックスが存在しない、arrayでは無い、または指定した`Double`型ではなかった時はデフォルト値
    public subscript(index: Int, default value: Double) -> Double {
        return self[index].value(default: value)
    }

    /// arrayから指定したインデックスのJSONデータを`Bool`型で取得する
    ///
    /// - Parameters:
    ///   - index: 取得対象のインデックス
    ///   - value: 指定したインデックスでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したインデックスのデータ。インデックスが存在しない、arrayでは無い、または指定した`Bool`型ではなかった時はデフォルト値
    public subscript(index: Int, default value: Bool) -> Bool {
        return self[index].value(default: value)
    }

    /// JSONデータからStringを取得する
    ///
    /// - throws: `JSON.ExceptionType.typeUnmatch` : 型が一致しなかった場合
    /// - returns: Stringの取得データ
    public func stringValue() throws -> String {
        switch data {
        case .string(let val): return val
        case .error(let error): throw error
        default: throw ExceptionType.typeUnmatch(key: objectDefine.0,
                                                 type: objectDefine.1, value: (try? data.toAny()) as Any)
        }
    }

    /// JSONデータからIntを取得する
    ///
    /// - throws: `JSON.ExceptionType.typeUnmatch` : 型が一致しなかった場合
    /// - returns: Intの取得データ
    public func intValue() throws -> Int {
        switch data {
        case .int(let val): return val
        case .error(let error): throw error
        default: throw ExceptionType.typeUnmatch(key: objectDefine.0,
                                                 type: objectDefine.1, value: (try? data.toAny()) as Any)
        }
    }

    /// JSONデータからDoubleを取得する
    ///
    /// - throws: `JSON.ExceptionType.typeUnmatch` : 型が一致しなかった場合
    /// - returns: Doubleの取得データ
    public func doubleValue() throws -> Double {
        switch data {
        case .double(let val): return val
        case .error(let error): throw error
        default: throw ExceptionType.typeUnmatch(key: objectDefine.0,
                                                 type: objectDefine.1, value: (try? data.toAny()) as Any)
        }
    }

    /// JSONデータからBoolを取得する
    ///
    /// - throws: `JSON.ExceptionType.typeUnmatch` : 型が一致しなかった場合
    /// - returns: Boolの取得データ
    public func boolValue() throws -> Bool {
        switch data {
        case .bool(let val): return val
        case .error(let error): throw error
        default: throw ExceptionType.typeUnmatch(key: objectDefine.0,
                                                 type: objectDefine.1, value: (try? data.toAny()) as Any)
        }
    }

    /// JSONデータからStringを取得する。型が違うなどで取得に失敗した場合は指定されたデフォルト値を返す
    ///
    /// - parameter default: 取得失敗時に返すデフォルト値
    /// - returns: Stringの取得データ。存在しない場合はデフォルト値
    public func value(default: String = JSON.Default.stringValue) -> String { return String(json: self) ?? `default` }

    /// JSONデータからIntを取得する。型が違うなどで取得に失敗した場合は指定されたデフォルト値を返す
    ///
    /// - parameter default: 取得失敗時に返すデフォルト値
    /// - returns: Intの取得データ。存在しない場合はデフォルト値
    public func value(default: Int = JSON.Default.intValue) -> Int { return Int(json: self) ?? `default` }

    /// JSONデータからDoubleを取得する。型が違うなどで取得に失敗した場合は指定されたデフォルト値を返す
    ///
    /// - parameter default: 取得失敗時に返すデフォルト値
    /// - returns: Doubleの取得データ。存在しない場合はデフォルト値
    public func value(default: Double = JSON.Default.doubleValue) -> Double { return Double(json: self) ?? `default` }

    /// JSONデータからBoolを取得する。型が違うなどで取得に失敗した場合は指定されたデフォルト値を返す
    ///
    /// - parameter default: 取得失敗時に返すデフォルト値
    /// - returns: Boolの取得データ。存在しない場合はデフォルト値
    public func value(default: Bool = JSON.Default.boolValue) -> Bool { return Bool(json: self) ?? `default` }

    func appended(define: ObjectDefine, newData: Any) -> Value? {
        guard case .object(var objs) = data else {
            JSON.errorList.append(.notObject(data: self, accessKey: define.0))
            return nil
        }

        var value: Value

        if let val = Value(type: define.1, value: newData) {
            value = val
        } else if newData is NSNull && define.1.canNothing {
            value = .null
        } else {
            JSON.errorList.append(.typeUnmatch(key: define.0, type: define.1, value: newData))
            return nil
        }

        objs[define.0] = JSONData(key: define.0, data: value, type: define.1)
        return .object(objs)

    }

    func toAny() throws -> Any {
        guard let data = try? data.toAny() else {
            throw ExceptionType.includeErrorData(data: self)
        }
        return data
    }

    /// JSONにobjectを追加する。データ内容が定義と一致しない場合は追加されない
    ///
    /// - parameter key:          追加するobjectのキー名
    /// - parameter type:         追加するobjectの値のタイプ
    /// - parameter data:         追加するデータ
    public func append(key: JSONData.Key, type: JSONData.ValueType, data: Any) {
        if let val = appended(define: (key, type), newData: data) {
            self.data = val
        }
    }

    /// JSONにarrayを追加する。データ内容が定義と一致しない場合は追加されない
    ///
    /// - parameter array: 追加する配列データ
    public func append(array: [Any]) {
        var arr = [JSONData]()
        if case .array(let list) = self.data {
            arr = list
        }

        switch type {
        case .array(let def), .arrayOrNull(let def), .arrayOrNothing(let def):
            for ele in array as [Any] {
                let val: Value
                if let item = Value(type: def, value: ele) {
                    val = item
                } else if ele is NSNull && def.canNothing {
                    val = .null
                } else {
                    JSON.errorList.append(.typeUnmatch(key: objectDefine.0, type: objectDefine.1, value: ele))
                    return
                }
                arr += [JSONData(key: "", data: val, type: def)]
            }
            self.data = .array(arr)
        default:
            JSON.errorList.append(.notArray(data: self))
            return
        }
    }

    func removed(value: Value, forKey: Key) -> Value? {
        guard case .object(var objs) = value else {
            JSON.errorList.append(.notObject(data: self, accessKey: forKey))
            return nil
        }

        guard objs.removeValue(forKey: forKey) != nil else {
            JSON.errorList.append(.notFound(parent: self, accessKey: forKey))
            return nil
        }

        return .object(objs)
    }

    /// JSONから指定したキーのobjectを削除する。指定したキーが存在しない場合は何もされない
    ///
    /// - parameter forKey: 削除したいobjectのキー
    public func removeValue(forKey: Key) {
        guard let newData = removed(value: data, forKey: forKey) else { return }
        data = newData
    }

    /// arrayから指定したインデックスのデータを削除する。指定したインデックスが存在しない場合は何もされない
    ///
    /// - parameter at: arrayから削除したいデータのインデックス
    @discardableResult
    public func remove(at: Int) -> JSONData? {
        guard case .array(var arr) = data else {
            JSON.errorList.append(.notArray(data: self))
            return nil
        }

        guard arr.indices.contains(at) else {
            JSON.errorList.append(.outOfRange(parent: self, index: at))
            return nil
        }

        let child = arr.remove(at: at)
        data = .array(arr)
        return child
    }

    /// JSONのobjectを全て削除する
    public func removeAll() {
        switch data {
        case .object(var objs):
            objs.removeAll()
            data = .object(objs)
        case .array(var arr):
            arr.removeAll()
            data = .array(arr)
        default:
            JSON.errorList.append(.notSupportOperation(data: self))
        }
    }

    // MARK: - Static

    /// 値からJSONデータを作成する。JSONデータの内容の設定時に利用
    ///
    /// - parameter value: 値
    /// - returns: JSONデータ
    public static func value(_ value: Any) -> JSONData {
        return JSONData(key: "", data: .assignment(value), type: .forWrap)
    }

    /// `null`のJSONデータを作成する。JSONデータの内容の設定時に利用。読み取り専用
    public static var null: JSONData {
        return JSONData(key: "", data: .assignment(NSNull()), type: .forWrap)
    }
}

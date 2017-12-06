////////////////////////////////////////////////////////////////////////////////////
//
//  JSON.swift
//  Kanagata
//
//  MIT License
//
//  Copyright (c) 2016 mike-neko
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

// MARK: - extension
public extension String {
    /// JSONデータからStringを生成する
    ///
    /// - parameter json: Stringの値が入ったJSONデータ
    /// - returns: Stringのデータ。型が違うなどでデータが取り出せない場合は`nil`
    init?(json: JSONData) {
        guard let value = try? json.stringValue() else { return nil }
        self = value
    }
}

public extension Int {
    /// JSONデータからIntを生成する
    ///
    /// - parameter json: Intの値が入ったJSONデータ
    /// - returns: Intのデータ。型が違うなどでデータが取り出せない場合は`nil`
    init?(json: JSONData) {
        guard let value = try? json.intValue() else { return nil }
        self = value
    }
}

public extension Double {
    /// JSONデータからDoubleを生成する
    ///
    /// - parameter json: Doubleの値が入ったJSONデータ
    /// - returns: Doubleのデータ。型が違うなどでデータが取り出せない場合は`nil`
    init?(json: JSONData) {
        guard let value = try? json.doubleValue() else { return nil }
        self = value
    }
}

public extension Bool {
    /// JSONデータからBoolを生成する
    ///
    /// - parameter json: Boolの値が入ったJSONデータ
    /// - returns: Boolのデータ。型が違うなどでデータが取り出せない場合は`nil`
    init?(json: JSONData) {
        guard let value = try? json.boolValue() else { return nil }
        self = value
    }
}

/// フォーマットを合成する
///
/// 既存がある場合は上書きされる
public func + (left: JSON.Format, right: JSON.Format) -> JSON.Format {
    var dic: JSON.Format = left
    right.forEach { dic[$0.key] = $0.value }
    return dic
}

/// フォーマットを合成する
///
/// 既存がある場合は上書きされる
public func += (left: inout JSON.Format, right: JSON.Format) {
    right.forEach { left[$0.key] = $0.value }
}

// MARK: -

/// JSONデータの変換や操作を行うクラス
public class JSON {
    public typealias Format = [JSONData.Key: JSONData.ValueType]

    /// 空のJSONオブジェクト
    // swiftlint:disable force_try
    static let empty = try! JSON(string: "{}", format: [:])
    // swiftlint:enable force_try

    // MARK: - Property

    private static let RootKey = "root"                         // トップオブジェクトのキー名
    private var root: JSONData
    fileprivate static var errorList = [ExceptionType]()        // update()時のエラーリスト

    // MARK: - Method

    /// DataからJSONデータを生成する
    ///
    /// - parameter data:     生成元となるData。JSONSerialization.jsonObjectで変換できるデータであること
    /// - parameter format:   生成するJSONのフォーマット
    ///
    /// - throws: `JSON.ExceptionType.createObjectError` : 変換に失敗した場合<br>
    ///           `JSON.ExceptionType.typeUnmatch` : フォーマットと一致しなかった場合
    public init(data: Data, format: Format) throws {
        let result: Any
        do {
            result = try JSONSerialization.jsonObject(with: data, options: [])
        } catch let error as NSError {
            throw ExceptionType.createObjectError(error: error)
        }

        let define: JSONData.ObjectDefine = (key: JSON.RootKey, type: .object(format))
        guard let value = JSONData.Value(type: define.1, value: result) else {
            throw ExceptionType.typeUnmatch(key: JSON.RootKey, type: .object(format), value: result)
        }

        root = JSONData(key: define.0, data: value, type: define.1)
    }

    /// JSON文字列からJSONデータを生成する
    ///
    /// - parameter string:   変換したいJSON文字列
    /// - parameter using:    JSON文字列で利用しているエンコード
    /// - parameter format:   生成するJSONのフォーマット
    /// - throws: `JSON.ExceptionType.encodingError` : エンコードに失敗した場合<br>
    ///           `JSON.ExceptionType.createObjectError` : 変換に失敗した場合<br>
    ///           `JSON.ExceptionType.typeUnmatch` : フォーマットと一致しなかった場合
    public convenience init(string: String, using: String.Encoding = .utf8, format: Format) throws {
        guard let data = string.data(using: using) else {
            throw ExceptionType.encodingError
        }

        try self.init(data: data, format: format)
    }

    /// 空の状態のJSONデータを生成する
    ///
    /// - parameter skeletonFormat:   生成するJSONのフォーマット
    /// - throws: `JSON.ExceptionType.typeUnmatch` : フォーマットが不正な場合
    public init(skeletonFormat: Format) throws {
        let define: JSONData.ObjectDefine = (key: JSON.RootKey, type: .object(skeletonFormat))
        guard let value = JSONData.Value(skeletonType: define.1) else {
            throw ExceptionType.typeUnmatch(key: JSON.RootKey,
                                            type: .object(skeletonFormat), value: "empty")
        }

        root = JSONData(key: define.0, data: value, type: define.1)
    }

    /// JSONデータからDataを生成する
    ///
    /// - throws: `JSON.ExceptionType.includeErrorData` : JSONデータ内にエラーデータがある場合<br>
    ///           `Error` : 変換に失敗した場合
    /// - returns: 生成されたData
    public func data() throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: root.toAny(), options: [])
        //print(String(data: jsondata, encoding: .utf8)!)
        return data
    }

    /// JSONデータからJSON文字列を生成する
    ///
    /// - parameter using:    JSON文字列のエンコード
    /// - throws: `JSON.ExceptionType.includeErrorData` : JSONデータ内にエラーデータがある場合<br>
    ///           `JSON.ExceptionType.encodingError` : エンコードに失敗した場合<br>
    ///           `Error` : 変換に失敗した場合
    /// - returns: 生成されたString
    public func stringData(using: String.Encoding = .utf8) throws -> String {
        guard let str = String(data: try data(), encoding: using) else {
            throw ExceptionType.encodingError
        }
        return str
    }

    /// 指定したキーのJSONデータを取得する
    ///
    /// - Parameter key: 取得対象のキー
    /// - returns: 指定したキーのデータ。キーが存在しない時は`ExceptionType.notFound`
    public subscript(key: JSONData.Key) -> JSONData {
        get { return root[key] }
        set { root[key] = newValue }
    }

    /// 指定したキーのJSONデータを`String`型で取得する
    ///
    /// - Parameters:
    ///   - key: 取得対象のキー
    ///   - value: 指定したキーでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したキーのデータ。キーが存在しない、または指定した`String`型ではなかった時はデフォルト値
    public subscript(key: JSONData.Key, default value: String) -> String {
        return self[key].value(default: value)
    }

    /// 指定したキーのJSONデータを`Int`型で取得する
    ///
    /// - Parameters:
    ///   - key: 取得対象のキー
    ///   - value: 指定したキーでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したキーのデータ。キーが存在しない、または指定した`Int`型ではなかった時はデフォルト値
    public subscript(key: JSONData.Key, default value: Int) -> Int {
        return self[key].value(default: value)
    }

    /// 指定したキーのJSONデータを`Double`型で取得する
    ///
    /// - Parameters:
    ///   - key: 取得対象のキー
    ///   - value: 指定したキーでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したキーのデータ。キーが存在しない、または指定した`Double`型ではなかった時はデフォルト値
    public subscript(key: JSONData.Key, default value: Double) -> Double {
        return self[key].value(default: value)
    }

    /// 指定したキーのJSONデータを`Bool`型で取得する
    ///
    /// - Parameters:
    ///   - key: 取得対象のキー
    ///   - value: 指定したキーでデータが取得できなかった場合のデフォルト値
    /// - returns: 指定したキーのデータ。キーが存在しない、または指定した`Bool`型ではなかった時はデフォルト値
    public subscript(key: JSONData.Key, default value: Bool) -> Bool {
        return self[key].value(default: value)
    }

    /// JSONデータの変更や操作時のエラー内容を取得したい時用
    ///
    /// - parameter block: エラーを補足したい一連の処理を記述したクロージャ
    /// - throws: 発生したエラー内容。詳細は`JSON.ExceptionType`を参照
    public func update(_ block: (() -> Void)) throws {
        JSON.errorList.removeAll()
        block()
        if let error = JSON.errorList.first {
            JSON.errorList.removeAll()
            throw error
        }
    }

    /// JSONにobjectを追加する。データ内容が定義と一致しない場合は追加されない
    ///
    /// - note: 既存データがある場合は上書きされる
    /// - parameter key:          追加するobjectのキー名
    /// - parameter type:         追加するobjectの値のタイプ
    /// - parameter data:         追加するデータ
    public func append(key: JSONData.Key, type: JSONData.ValueType, data: Any) {
        guard let val = root.appended(define: (key, type),
                                      newData: data) else { return }

        root.data = val
    }

    /// JSONから指定したキーのobjectを削除する。指定したキーが存在しない場合は何もされない
    ///
    /// - parameter forKey: 削除したいobjectのキー
    public func removeValue(forKey: JSONData.Key) {
        guard let newData = root.removed(value: root.data, forKey: forKey) else { return }
        root.data = newData
    }

    /// JSONのobjectを全て削除する
    public func removeAll() {
        root = JSONData(key: JSON.RootKey, data: .object([:]), type: .object([:]))
    }

    /// 指定したJSONから指定したキーのデータをコピーする
    ///
    /// - Parameters:
    ///   - source: コピー元のJSON
    ///   - keyList: コピー対象となるキーリスト
    public func copy(source: JSON, keyList: [JSONData.Key]) {
        keyList.forEach {
            self[$0].data = source[$0].data
        }
    }

    // MARK: - Default
    /// 各データ型ごとの値の取得時のデフォルト値
    public struct Default {
        /// Stringの値の取得時のデフォルト値
        public static var stringValue = ""
        /// Intの値の取得時のデフォルト値
        public static var intValue = Int(0)
        /// Doubleの値の取得時のデフォルト値
        public static var doubleValue = Double(0)
        /// Boolの値の取得時のデフォルト値
        public static var boolValue = false
    }

    // MARK: - Error
    /// JSONクラスで発生して通知されるエラー
    public enum ExceptionType: Error {
        /// StringをDataへ変換できなかった場合
        case encodingError
        /// DataからJSONObjectを生成できなかった場合
        ///
        /// - parameter error: JSONSerialization.jsonObjectで発生したエラー
        case createObjectError(error: NSError)

        /// objectではないデータにキーでアクセスした場合
        ///
        /// - parameter data: 現在のデータ（objectではないデータ）
        /// - parameter accessKey: 指定したキー
        case notObject(data: JSONData, accessKey: JSONData.Key)
        /// arrayではないオブジェクトにインデックスでアクセスした場合
        ///
        /// - parameter data: 現在のデータ（arrayではないデータ）
        case notArray(data: JSONData)

        /// 指定したフォーマットとデータが一致しない場合
        ///
        /// - parameter key: キー
        /// - parameter type: フォーマット
        /// - parameter value: データ
        case typeUnmatch(key: JSONData.Key, type: JSONData.ValueType, value: Any)
        /// 指定したキーでオブジェクトがない場合
        ///
        /// - parameter parent: 対象のobject
        /// - parameter accessKey: 指定したキー
        case notFound(parent: JSONData, accessKey: JSONData.Key)
        /// 指定したインデックスが範囲外の場合
        ///
        /// - parameter parent: 対象のarray
        /// - parameter index: 指定したインデックス
        case outOfRange(parent: JSONData, index: Int)

        /// JSONデータに対してサポートされていない操作をした場合
        ///
        /// - parameter data: 操作対象のデータ
        case notSupportOperation(data: JSONData)

        /// エラーデータが含まれていてDataへ変換できなかった場合
        ///
        /// - parameter data: エラーとなったデータ
        case includeErrorData(data: JSONData)
    }
}

/// JSONのデータクラス
public class JSONData {
    public typealias Key = String
    fileprivate typealias ObjectDictionary = [Key: JSONData]
    fileprivate typealias ObjectDefine = (Key, ValueType)
    public typealias ExceptionType = JSON.ExceptionType

    // MARK: - Property
    /// キー
    public let key: Key
    fileprivate var data: Value             // 値
    private let type: ValueType             // フォーマット

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
    fileprivate init(key: Key, data: Value, type: ValueType) {
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

    fileprivate func appended(define: ObjectDefine, newData: Any) -> Value? {
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

    fileprivate func toAny() throws -> Any {
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

    fileprivate func removed(value: Value, forKey: Key) -> Value? {
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
    fileprivate indirect enum Value {
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

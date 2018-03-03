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
    static var errorList = [ExceptionType]()        // update()時のエラーリスト

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

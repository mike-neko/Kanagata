//
//  JSON.swift
//  Kanagata
//
//  Created by M.Ike on 2016/09/19.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

import Foundation

// MARK: - extension
extension String {
    /// jsonデータからStringを生成する
    ///
    /// - parameter json: Stringの値が入ったjsonデータ
    /// - returns: Stringのデータ。jsonデータの型が違う場合は`nil`
    init?(json: JSONData) {
        guard let value = try? json.stringValue() else { return nil }
        self = value
    }
}

extension Int {
    /// jsonデータからIntを生成する
    ///
    /// - parameter json: Intの値が入ったjsonデータ
    /// - returns: Intのデータ。jsonデータの型が違う場合は`nil`
    init?(json: JSONData) {
        guard let value = try? json.intValue() else { return nil }
        self = value
    }
}

extension Float {
    /// jsonデータからFloatを生成する
    ///
    /// - parameter json: Floatの値が入ったjsonデータ
    /// - returns: Floatのデータ。jsonデータの型が違う場合は`nil`
    init?(json: JSONData) {
        guard let value = try? json.floatValue() else { return nil }
        self = value
    }
}

extension Bool {
    /// jsonデータからBoolを生成する
    ///
    /// - parameter json: Boolの値が入ったjsonデータ
    /// - returns: Boolのデータ。jsonデータの型が違う場合は`nil`
    init?(json: JSONData) {
        guard let value = try? json.boolValue() else { return nil }
        self = value
    }
}

// MARK: -

/// JSONデータの変換や操作を行うクラス
class JSON {
    typealias ObjectDefine = JSONData.ObjectDefine
    typealias ObjectDefineList = JSONData.ObjectDefineList
    
    // MARK: - Property
    
    private static let RootKey = "root"                         // トップオブジェクトのキー名
    private var root: JSONData
    fileprivate static var errorList = [ExceptionType]()        // update()時のエラーリスト
    
    // MARK: - Method
    
    /// Dataからjsonデータを生成する
    ///
    /// - parameter data:     生成元となるData。JSONSerialization.jsonObjectで変換できるデータであること
    /// - parameter template: 生成するjsonのフォーマットを指定したテンプレート
    ///
    /// - throws: `JSON.ExceptionType.createObjectError` : 変換に失敗した場合<br>
    ///           `JSON.ExceptionType.typeUnmatch` : テンプレートと一致しなかった場合
    init(data: Data, template: ObjectDefineList) throws {
        do {
            let result = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
            
            let define: ObjectDefine = (key: JSON.RootKey, type: .object(template))
            guard let value = JSONData.Value(type: define.1, value: result) else {
                throw ExceptionType.typeUnmatch(define: define, value: result)
            }
            
            root = JSONData(key: define.0, data: value, define: define.1)
        } catch let error as NSError {
            throw ExceptionType.createObjectError(error: error)
        }
    }
    
    /// JSON文字列からjsonデータを生成する
    ///
    /// - parameter string:   変換したいJSON文字列
    /// - parameter using:    JSON文字列で利用しているエンコード
    /// - parameter template: 生成するjsonのフォーマットを指定したテンプレート
    /// - throws: `JSON.ExceptionType.encodingError` : エンコードに失敗した場合<br>
    ///           `JSON.ExceptionType.createObjectError` : 変換に失敗した場合<br>
    ///           `JSON.ExceptionType.typeUnmatch` : テンプレートと一致しなかった場合
    convenience init(string: String, using: String.Encoding = .utf8, template: ObjectDefineList) throws {
        guard let data = string.data(using: using) else {
            throw ExceptionType.encodingError
        }
        
        try self.init(data: data, template: template)
    }
    
    /// jsonデータからDataを生成する
    ///
    /// - throws: `JSON.ExceptionType.includeErrorData` : jsonデータ内にエラーデータがある場合<br>
    ///           `Error` : 変換に失敗した場合
    /// - returns: 生成されたData
    func data() throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: root.toAny(), options: [])
        //print(String(data: jsondata, encoding: .utf8)!)
        return data
    }
    
    subscript(key: JSONData.Key) -> JSONData {
        get { return root[key] }
        set { root[key] = newValue }
    }
    
    /// jsonデータの変更や操作時のエラー内容を取得したい時用
    ///
    /// - parameter block: エラーを補足したい一連の処理を記述したクロージャ
    /// - throws: 発生したエラー内容。詳細は`JSON.ExceptionType`を参照
    func update(_ block: (() -> Void)) throws {
        JSON.errorList.removeAll()
        block()
        if let error = JSON.errorList.first {
            JSON.errorList.removeAll()
            throw error
        }
    }
    
    /// jsonにobjectを追加する。データ内容が定義と一致しない場合は追加されない
    ///
    /// - parameter objectDefine: 追加するobjectの定義（キー名, フォーマット）
    /// - parameter data:         追加するデータ
    func append(objectDefine: ObjectDefine, data: Any) {
        guard let val = root.appended(define: objectDefine, newData: data as AnyObject) else {
            return
        }
        
        root.data = val
    }
    
    /// jsonから指定したキーのobjectを削除する。指定したキーが存在しない場合は何もされない
    ///
    /// - parameter forKey: 削除したいobjectのキー
    func removeValue(forKey: JSONData.Key) {
        guard let newData = root.removed(value: root.data, forKey: forKey) else { return }
        root.data = newData
    }
    
    /// jsonのobjectを全て削除する
    func removeAll() {
        root = JSONData(key: JSON.RootKey, data: .object([:]), define: .object([]))
    }
    
    // MARK: - Default
    /// 各データ型ごとの値の取得時のデフォルト値
    struct Default {
        /// Stringの値の取得時のデフォルト値
        static var stringValue = ""
        /// Intの値の取得時のデフォルト値
        static var intValue = Int(0)
        /// Floatの値の取得時のデフォルト値
        static var floatValue = Float(0)
        /// Boolの値の取得時のデフォルト値
        static var boolValue = false
    }
    
    // MARK: - Error
    /// JSONクラスで発生して通知されるエラー
    enum ExceptionType: Error {
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
        /// - parameter define: フォーマット
        /// - parameter value: データ
        case typeUnmatch(define: ObjectDefine, value: AnyObject)
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
        
        /// jsonデータに対してサポートされていない操作をした場合
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
class JSONData {
    typealias Key = String
    typealias ObjectDictionary = [Key: JSONData]
    typealias ObjectDefine = (Key, ValueDefine)
    typealias ObjectDefineList = [ObjectDefine]
    typealias ExceptionType = JSON.ExceptionType
    
    // MARK: - Property
    /// キー
    let key: Key
    fileprivate var data: Value             // 値
    private let define: ValueDefine         // フォーマット
    
    /// `null`が入っていれば`true`、入っていなければ`false`。エラーの場合も`false`
    var isNull: Bool { return data.isNull }
    /// データが存在すれば`true`、エラーデータであれば`false`
    var exists: Bool { return data.exists }
    private var objectDefine: ObjectDefine { return (key, define) }
    
    // MARK: - Method
    fileprivate init(key: Key, data: Value, define: ValueDefine) {
        self.key = key
        self.data = data
        self.define = define
    }
    
    subscript(key: Key) -> JSONData {
        get {
            if case .object(let objs) = data {
                return objs[key] ?? JSONData(key: key, data: .error(.notFound(parent: self, accessKey: key)), define: .forWrap)
            } else {
                return JSONData(key: key, data: .error(.notObject(data: self, accessKey: key)), define: .forWrap)
            }
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
            case .assignment(let valueObj as AnyObject):
                let newData: Value
                if valueObj is NSNull {
                    newData = .null
                } else if let val = Value(type: child.define, value: valueObj) {
                    newData = val
                } else {
                    JSON.errorList.append(.typeUnmatch(define: objectDefine, value: newValue))
                    return
                }
                objs[key] = JSONData(key: child.key, data: newData, define: child.define)
                data = .object(objs)
            default:
                JSON.errorList.append(.typeUnmatch(define: objectDefine, value: newValue))
                return
            }
        }
    }
    
    subscript(index: Int) -> JSONData {
        get {
            if case .array(let arr) = data {
                guard arr.indices.contains(index) else {
                    return JSONData(key: key, data: .error(.outOfRange(parent: self, index: index)), define: .forWrap)
                }
                return arr[index]
            } else {
                return JSONData(key: key, data: .error(.notArray(data: self)), define: .forWrap)
            }
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
            case .assignment(let valueObj as AnyObject):
                let newData: Value
                if valueObj is NSNull {
                    newData = .null
                } else if let val = Value(type: element.define, value: valueObj) {
                    newData = val
                } else {
                    JSON.errorList.append(.typeUnmatch(define: objectDefine, value: newValue))
                    return
                }
                arr[index] = JSONData(key: element.key, data: newData, define: element.define)
                data = .array(arr)
            default:
                JSON.errorList.append(.typeUnmatch(define: objectDefine, value: newValue))
                return
            }
        }
    }
    
    /// jsonデータからStringを取得する
    ///
    /// - throws: `JSON.ExceptionType.typeUnmatch` : 型が一致しなかった場合
    /// - returns: Stringの取得データ
    func stringValue() throws -> String {
        switch data {
        case .string(let val): return val
        case .error(let error): throw error
        default: throw ExceptionType.typeUnmatch(define: objectDefine, value: (try? data.toAny()) as AnyObject)
        }
    }
    
    /// jsonデータからIntを取得する
    ///
    /// - throws: `JSON.ExceptionType.typeUnmatch` : 型が一致しなかった場合
    /// - returns: Intの取得データ
    func intValue() throws -> Int {
        switch data {
        case .int(let val): return val
        case .error(let error): throw error
        default: throw ExceptionType.typeUnmatch(define: objectDefine, value: (try? data.toAny()) as AnyObject)
        }
    }
    
    /// jsonデータからFloatを取得する
    ///
    /// - throws: `JSON.ExceptionType.typeUnmatch` : 型が一致しなかった場合
    /// - returns: Floatの取得データ
    func floatValue() throws -> Float {
        switch data {
        case .float(let val): return val
        case .error(let error): throw error
        default: throw ExceptionType.typeUnmatch(define: objectDefine, value: (try? data.toAny()) as AnyObject)
        }
    }
    
    /// jsonデータからBoolを取得する
    ///
    /// - throws: `JSON.ExceptionType.typeUnmatch` : 型が一致しなかった場合
    /// - returns: Boolの取得データ
    func boolValue() throws -> Bool {
        switch data {
        case .bool(let val): return val
        case .error(let error): throw error
        default: throw ExceptionType.typeUnmatch(define: objectDefine, value: (try? data.toAny()) as AnyObject)
        }
    }
    
    /// jsonデータからStringを取得する。型が違うなどで取得に失敗した場合は指定されたデフォルト値を返す
    ///
    /// - parameter default: 取得失敗時に返すデフォルト値
    /// - returns: Stringの取得データ。存在しない場合はデフォルト値
    func value(default: String = JSON.Default.stringValue) -> String { return String(json: self) ?? `default` }
    
    /// jsonデータからIntを取得する。型が違うなどで取得に失敗した場合は指定されたデフォルト値を返す
    ///
    /// - parameter default: 取得失敗時に返すデフォルト値
    /// - returns: Intの取得データ。存在しない場合はデフォルト値
    func value(default: Int = JSON.Default.intValue) -> Int { return Int(json: self) ?? `default` }
    
    /// jsonデータからFloatを取得する。型が違うなどで取得に失敗した場合は指定されたデフォルト値を返す
    ///
    /// - parameter default: 取得失敗時に返すデフォルト値
    /// - returns: Floatの取得データ。存在しない場合はデフォルト値
    func value(default: Float = JSON.Default.floatValue) -> Float { return Float(json: self) ?? `default` }
    
    /// jsonデータからBoolを取得する。型が違うなどで取得に失敗した場合は指定されたデフォルト値を返す
    ///
    /// - parameter default: 取得失敗時に返すデフォルト値
    /// - returns: Boolの取得データ。存在しない場合はデフォルト値
    func value(default: Bool = JSON.Default.boolValue) -> Bool { return Bool(json: self) ?? `default` }
    
    fileprivate func appended(define: ObjectDefine, newData: AnyObject) -> Value? {
        guard case .object(var objs) = data else {
            JSON.errorList.append(.notObject(data: self, accessKey: define.0))
            return nil
        }
        
        guard let value = Value(type: define.1, value: newData as AnyObject) else {
            JSON.errorList.append(.typeUnmatch(define: define, value: newData))
            return nil
        }
        
        objs[define.0] = JSONData(key: define.0, data: value, define: define.1)
        return .object(objs)
        
    }
    
    fileprivate func toAny() throws -> Any {
        do { return try data.toAny() }
        catch { throw ExceptionType.includeErrorData(data: self) }
    }
    
    /// jsonにobjectを追加する。データ内容が定義と一致しない場合は追加されない
    ///
    /// - parameter objectDefine: 追加するobjectの定義（キー名, フォーマット）
    /// - parameter data:         追加するデータ
    func append(objectDefine: ObjectDefine, data: Any) {
        if let val = appended(define: objectDefine, newData: data as AnyObject) {
            self.data = val
        }
    }
    
    /// jsonにarrayを追加する。データ内容が定義と一致しない場合は追加されない
    ///
    /// - parameter array: 追加する配列データ
    func append(array: [Any]) {
        guard case .array(var arr) = self.data else {
            JSON.errorList.append(.notArray(data: self))
            return
        }
        
        switch define {
        case .array(let def), .arrayOrNull(let def), .arrayOrNothing(let def):
            for ele in array as [AnyObject] {
                guard let item = Value(type: def, value: ele) else {
                    JSON.errorList.append(.typeUnmatch(define: objectDefine, value: ele))
                    return
                }
                arr += [JSONData(key: "", data: item, define: def)]
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
    
    /// jsonから指定したキーのobjectを削除する。指定したキーが存在しない場合は何もされない
    ///
    /// - parameter forKey: 削除したいobjectのキー
    func removeValue(forKey: Key) {
        guard let newData = removed(value: data, forKey: forKey) else { return }
        data = newData
    }
    
    /// arrayから指定したインデックスのデータを削除する。指定したインデックスが存在しない場合は何もされない
    ///
    /// - parameter at: arrayから削除したいデータのインデックス
    @discardableResult
    func remove(at: Int) -> JSONData? {
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
    
    /// jsonのobjectを全て削除する
    func removeAll() {
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
    static func value(_ value: Any) -> JSONData {
        return JSONData(key: "", data: .assignment(value), define: .forWrap)
    }
    
    /// `null`のJSONデータを作成する。JSONデータの内容の設定時に利用
    static let null = JSONData(key: "", data: .assignment(NSNull()), define: .forWrap)
    
    // MARK: - ValueDefine
    
    /// JSONデータのフォーマット
    ///
    /// - string:                           Stringに対応
    /// - int:                              Intに対応
    /// - float:                            Floatに対応
    /// - bool:                             Boolに対応
    /// - array(ValueDefine):               [ValueDefine]に対応
    /// - object([(Key, ValueDefine)]):     [(Key, ValueDefine)]に対応
    ///
    /// # 元データに`null`が含まれている場合の動作
    /// フォーマット指定で
    /// - 何も付加されていない:                   フォーマット不一致でエラーになる
    /// - `OrNull`が付加:                      値として`null`が設定される
    /// - `OrNothing`が付加:                   オブジェクト自体が存在しない扱いとなり生成後のJSONデータには含まれない
    indirect enum ValueDefine {
        case string, stringOrNull, stringOrNothing
        case int, intOrNull, intOrNothing
        case float, floatOrNull, floatOrNothing
        case bool, boolOrNull, boolOrNothing
        case array(ValueDefine), arrayOrNull(ValueDefine), arrayOrNothing(ValueDefine)
        case object(ObjectDefineList), objectOrNull(ObjectDefineList), objectOrNothing(ObjectDefineList)
        
        case forWrap  // 子要素やエラーのラップ用
        
        /// `(フォーマット)OrNull`の場合は`true`
        var canNullable: Bool {
            switch self {
            case .stringOrNull, .intOrNull, .floatOrNull, .boolOrNull, .arrayOrNull, .objectOrNull:
                return true
            default: return false
            }
        }
        
        /// `(フォーマット)OrNothing`の場合は`true`
        var canNothing: Bool {
            switch self {
            case .stringOrNothing, .intOrNothing, .floatOrNothing,
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
        case float(Float)
        case bool(Bool)
        case array([JSONData])
        case object(ObjectDictionary)
        case null
        
        case error(ExceptionType)        // 取得時にエラーとなった場合
        case assignment(Any)             // 値を設定する時のラップ用
        
        init?(type: ValueDefine, value: AnyObject) {
            if type.canNullable && (value is NSNull || (value as? Value)?.isNull ?? false)  {
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
                
            case .float, .floatOrNull, .floatOrNothing:
                guard let val = value as? Float else { return nil }
                self = .float(val)
                
            case .bool, .boolOrNull, .boolOrNothing:
                guard let val = value as? Bool else { return nil }
                self = .bool(val)
                
            case .array(let def), .arrayOrNull(let def), .arrayOrNothing(let def):
                guard let list = value as? [AnyObject] else { return nil }
                
                var arr = [JSONData]()
                for element in list {
                    guard let item = Value(type: def, value: element) else { return nil }
                    arr += [JSONData(key: "", data: item, define: def)]
                }
                self = .array(arr)
                
            case .object(let defList), .objectOrNull(let defList), .objectOrNothing(let defList):
                guard let dic = value as? [String: AnyObject] else { return nil }
                var list = ObjectDictionary()
                for def in defList {
                    let key = def.0, type = def.1
                    
                    let data: Value
                    if let d = dic[key] {
                        guard let value = Value(type: type, value: d) else { return nil }
                        data = value
                    } else if type.canNullable {
                        data = .null
                    } else if type.canNothing {
                        continue
                    } else {
                        return nil
                    }
                    
                    list[key] = JSONData(key: key, data: data, define: type)
                }
                self = .object(list)
                
            case .forWrap: return nil
            }
        }
        
        var isNull: Bool {
            if case .null = self {
                return true
            } else {
                return false
            }
        }
        
        var exists: Bool {
            switch self {
            case .string, .int, .float, .bool, .array, .object, .null:
                return true
            default:
                return false
            }
        }
        
        enum ConvertError: Error {
            case error(ExceptionType), assignment
        }
        
        func toAny() throws -> Any {
            switch self {
            case .string(let val): return val
            case .int(let val): return val
            case .float(let val): return val
            case .bool(let val): return val
            case .array(let list): return try list.map { try $0.toAny() }
            case .object(let objs):
                var dic: [String: Any] = [:]
                try objs.forEach { dic[$0.key] = try $0.value.toAny() }
                return dic
            case .null: return NSNull()
            case .error(let error): throw ConvertError.error(error)
            case .assignment: throw ConvertError.assignment
            }
        }
    }
}

//
//  Logger.swift
//  FuriganaApp
//
//  Created by 出店 純一 on 2019/02/17.
//  Copyright © 2019年 出店 純一. All rights reserved.
//

import Foundation

public func logI(_ message: String = "", function: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
    
    Logger.shared.outputLog("[i][\(Logger.shared.getDateString())][\(Logger.shared.createFunctionName(file, line: line, function: function))] \(message)")
}

public func logE(_ message: String = "", function: StaticString = #function, file: StaticString = #file, line: UInt = #line)  {
    
    Logger.shared.outputLog("[e][\(Logger.shared.getDateString())][\(Logger.shared.createFunctionName(file, line: line, function: function))] \(message)")
}

/// Log出力の制御クラス
class Logger {
    
    static let shared: Logger = {
        let instance = Logger()
        return instance
    }()
    
    /// ログファイルに指定文字列を出力
    ///
    /// - Parameter message: メッセージ
    fileprivate func outputLog(_ message: String) {
        // コンソールログ出力
        print(message)
    }
    
    /// ログ出力用のフォーマットを行う
    ///
    /// - Parameters:
    ///   - file: ファイル
    ///   - line: ライン番号
    ///   - function: ファンクション名
    /// - Returns: フォーマット文字列
    fileprivate func createFunctionName(_ file: StaticString, line: UInt, function: StaticString) -> String {
        let fileName = URL(fileURLWithPath: String(describing: file)).lastPathComponent
        return "\(fileName) L.\(line) \(function)"
    }
    
    /// 現在の日付文字列を取得
    ///
    /// - Parameter format: 日付フォーマット
    /// - Returns: 日付文字列
    fileprivate func getDateString(_ format: String = "yyyy-MM-dd-HH-mm-ss") -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = format
        return formatter.string(from: now)
    }
}

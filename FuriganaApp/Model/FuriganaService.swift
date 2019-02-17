//
//  FuriganaService.swift
//  FuriganaApp
//
//  Created by 出店 純一 on 2019/02/17.
//  Copyright © 2019年 出店 純一. All rights reserved.
//

import Foundation

protocol FuriganaServiceDelegate {
    
    /// ルビ変換成功
    ///
    /// - Parameter text: ルビ変換した文字列
    func furiganaServiceSuccess(_ sentence: String)
    
    /// ルビ変換エラー
    ///
    /// - Parameter error: エラーメッセージ
    func furiganaServiceError(_ error: String)
}

/// ルビ変換処理クラス
class FuriganaService: NSObject {
    
    // アプリID
    private let appid = "dj00aiZpPVNscXpDcDBKd0Z6USZzPWNvbnN1bWVyc2VjcmV0Jng9YzY-"
    // ルビ変換レベル
    private let grade = 1
    
    // デリゲート
    var delegate: FuriganaServiceDelegate!
    private var furigana = ""
    private let wordTag = "Word"
    private let surfaceTag = "Surface"
    private let furiganaTag = "Furigana"
    private let subWordListTag = "SubWordList"
    private var isWord: Bool = false
    private var isSurface: Bool = false
    private var isFurigana: Bool = false
    private var isSubWordList: Bool = false
    private var tmpSurface = ""
    private var hasFurigana: Bool = false
    
    /// ルビ振りリクエスト送信
    /// 参照:https://developer.yahoo.co.jp/webapi/jlp/furigana/v1/furigana.html
    ///
    /// - Parameter sentence: ルビ変換する文字列
    func post(sentence: String) {
        logI("START sentence\(sentence)")
        
        // URLエンコード
        let encordSentence = sentence.urlEncoded
        
        if let url = URL(string: "https://jlp.yahooapis.jp/FuriganaService/V1/furigana?appid=\(appid)&grade=\(grade)&sentence=\(encordSentence)") {
            
            logI("url:\(url.absoluteString)")
            let request = URLRequest(url: url)
            
            // 非同期通信
            DispatchQueue.global(qos: .default).async {
                let responseData = HttpClient.getResponseData(request)
                
                if responseData.error != nil {
                    // エラー
                    logE("Error: \(responseData.error!.localizedDescription)")
                    if self.delegate != nil {
                        self.delegate.furiganaServiceError("変換に失敗しました。\n通信状態をご確認ください。")
                    }
                    return
                }
                
                if responseData.data != nil {
                    // 解析
                    let xml = XMLParser(data: responseData.data!)
                    xml.delegate = self
                    xml.parse()
                }
            }
        }
        logI("END")
    }
}

extension FuriganaService: XMLParserDelegate {
    // XML解析開始
    func parserDidStartDocument(_ parser: XMLParser) {
        logI("XMLParser START")
        // 初期化
        furigana = ""
        isWord = false
        isSurface = false
        isFurigana = false
        isSubWordList = false
        hasFurigana = false
        tmpSurface = ""
    }
    
    // 開始タグ
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        logI("START tag:\(elementName)")
        
        isWord = elementName == wordTag ? true : isWord
        isSurface = elementName == surfaceTag ? true : isSurface
        if elementName == furiganaTag {
            isFurigana = true
            // Furiganaがあった時にフラグを立てる
            hasFurigana = true
        }
        isSubWordList = elementName == subWordListTag ? true : isSubWordList
    }
    
    // 値
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        logI("value:\(string)")
        if isSurface && !isSubWordList {
            // Furiganaがなかった時使用するため保持
            tmpSurface = string
        }
        
        if isFurigana && !isSubWordList {
            // Furiganaを追加
            furigana += string
        }
    }
    
    // 終了タグ
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        logI("END tag:\(elementName)")
        if elementName == wordTag {
            isWord = false
            
            if !hasFurigana {
                // Furiganaがなかった場合はSurfaceを追加
                furigana += tmpSurface
            }
            
            // Wordタグ終了のタイミングで元に戻す
            hasFurigana = false
        }
        
        isFurigana = elementName == furiganaTag ? false : isFurigana
        isSurface = elementName == surfaceTag ? false : isSurface
        isSubWordList = elementName == subWordListTag ? false : isSubWordList
    }
    
    // XML解析終了
    func parserDidEndDocument(_ parser: XMLParser) {
        logI("XMLParser END  result:\(furigana)")
        if delegate != nil {
            self.delegate.furiganaServiceSuccess(furigana)
        }
    }
    
    // 解析エラー
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        logE("XMLParser Error \(parseError.localizedDescription)")
        if delegate != nil {
            self.delegate.furiganaServiceError("変換中にエラーが発生しました。")
        }
    }
}

//
//  HttpClient.swift
//  FuriganaApp
//
//  Created by 出店 純一 on 2019/02/17.
//  Copyright © 2019年 出店 純一. All rights reserved.
//

import Foundation
import UIKit

class ResponseData {
    var data: Data?
    var response: URLResponse?
    var error: Error?
}

class HttpClient {
    /// リクエストを同期で送信
    ///
    /// - Parameter request: リクエストデータ
    /// - Returns: レスポンスデータ
    static func getResponseData(_ request: URLRequest) -> ResponseData {
        let responseData = ResponseData()
        let condition = NSCondition()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            responseData.data = data
            responseData.response = response
            responseData.error = error
            
            session.invalidateAndCancel()
            
            condition.signal()
        })
        condition.lock()
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }

        task.resume()
        condition.wait()
        condition.unlock()
        
        return responseData
    }
}

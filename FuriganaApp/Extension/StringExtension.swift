//
//  StringExtension.swift
//  FuriganaApp
//
//  Created by 出店 純一 on 2019/02/17.
//  Copyright © 2019年 出店 純一. All rights reserved.
//

import Foundation

extension String {
    /// URLエンコード(エスケープ有)
    var urlEncoded: String {
        let charset = CharacterSet.alphanumerics.union(.init(charactersIn: "/?-._~"))
        // URLデコード
        let removed = removingPercentEncoding ?? self
        // URLエンコード
        return removed.addingPercentEncoding(withAllowedCharacters: charset) ?? removed
    }
}

//
//  FuriganaViewController.swift
//  FuriganaApp
//
//  Created by 出店 純一 on 2019/02/16.
//  Copyright © 2019年 出店 純一. All rights reserved.
//

import UIKit

class FuriganaViewController: UIViewController {

    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private let furiganaService = FuriganaService()
    private var timer: Timer?
    private let timeInterval: Double = 1.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ルビ振りデリゲート登録
        furiganaService.delegate = self
        // TextViewデリゲート登録
        inputTextView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // キーボード外タッチでキーボードを閉じる
        self.view.endEditing(true)
    }
    
    /// ルビ振り開始
    @objc func startFuriganaService() {
        if !inputTextView.text.isEmpty {
            indicator.isHidden = false
            indicator.startAnimating()
            // ルビ振り開始
            furiganaService.post(sentence: inputTextView.text)
        }
    }
}

extension FuriganaViewController: UITextViewDelegate {
    // 入力文字変更時通知
    func textViewDidChange(_ textView: UITextView) {
        // タイマー停止
        timer?.invalidate()
        // タイマー起動(インターバル後ルビ振り処理発火)
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(startFuriganaService), userInfo: nil, repeats: false)
    }
}

extension FuriganaViewController: FuriganaServiceDelegate {
    // ルビ変換成功通知
    func furiganaServiceSuccess(_ sentence: String) {
        DispatchQueue.main.async {
            self.indicator.isHidden = true
            self.outputTextView.text = sentence
        }
    }
    
    // ルビ変換失敗通知
    func furiganaServiceError(_ error: String) {
        DispatchQueue.main.async {
            self.indicator.isHidden = true
            self.outputTextView.text = error
        }
    }
}

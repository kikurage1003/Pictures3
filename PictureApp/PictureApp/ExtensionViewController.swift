//
//  ExtensionViewController.swift
//  PictureApp
//
//  Created by keisuke on 2018/06/04.
//  Copyright © 2018年 くら〜〜く. All rights reserved.
//

import Photos

// デリゲート部分を拡張する
extension CamViewController:AVCapturePhotoCaptureDelegate {
    
    // 映像をキャプチャする
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // 写真のプライバシー認証をチェックする
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied {
            showAlert(appName: "写真")
            return
        }
        
        // Dataを取り出す
        guard let photoData = photo.fileDataRepresentation() else {
            return
        }
        // Dataから写真イメージを作る
        if let stillImage = UIImage(data: photoData) {
            // アルバムに追加する
            UIImageWriteToSavedPhotosAlbum(stillImage, self, nil, nil)
            //シェアするイメージに代入する
            shareImage = stillImage
        }
    }
}

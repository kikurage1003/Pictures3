//
//  CameraViewController.swift
//  PictureApp
//
//  Created by keisuke on 2018/06/04.
//  Copyright © 2018年 くら〜〜く. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import Photos
import MobileCoreServices
import CoreLocation

class CamViewController: UIViewController, CLLocationManagerDelegate{
    
    // プレビュー用のビューとOutlet接続しておく
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var shutterButton: UIButton!
    
    var toggle:Bool = true
    
    // インスタンスの作成
    var session = AVCaptureSession()
    var photoOutputObj = AVCapturePhotoOutput()
    // 通知センターを作る
    let notification = NotificationCenter.default
    // プライバシーと入出力のステータス
    var authStatus:AuthorizedStatus = .authorized
    var inOutStatus:InputOutputStatus = .ready
    //シェアするイメージ
    var shareImage:UIImage?
    
    var stillImage2:CGImage?
    var locationManager:CLLocationManager!
    //exif情報を準備する
    var gps  = NSMutableDictionary()
    var exif = NSMutableDictionary()
    var meta = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        exifSetup()
    }
    
    // 認証のステータス
    enum AuthorizedStatus {
        case authorized
        case notAuthorized
        case failed
    }
    // 入出力のステータス
    enum InputOutputStatus {
        case ready
        case notReady
        case failed
    }
    
    // ビューが表示された直後に実行
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // セッション実行中ならば中断する
        guard !session.isRunning else {
            return
        }
        // カメラのプライバシー認証確認
        cameraAuth()
        // 入出力の設定
        setupInputOutput()
        // カメラの準備ができているかどうか
        if (authStatus == .authorized)&&(inOutStatus == .ready){
            // プレビューレイヤの設定
            setPreviewLayer()
            // セッション開始
            session.startRunning()
            shutterButton.isEnabled = true
        } else {
            // アラートを出す
            showAlert(appName: "カメラ")
        }
        // デバイスが回転したときに通知するイベントハンドラを設定する
        notification.addObserver(self,
                                 selector: #selector(self.changedDeviceOrientation(_:)),
                                 name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @IBAction func takephoto(_ sender: Any) {
        if (authStatus == .authorized)&&(inOutStatus == .ready){
            let captureSetting = AVCapturePhotoSettings()
            captureSetting.flashMode = .off
            captureSetting.isAutoStillImageStabilizationEnabled = true
            captureSetting.isHighResolutionPhotoEnabled = false
            // キャプチャのイメージ処理はデリゲートに任せる
            photoOutputObj.capturePhoto(with: captureSetting, delegate: self)
        } else {
            // カメラの利用を許可しなかったにも関わらずボタンをタップした（初回起動時のみ）
            showAlert(appName: "カメラ")
        }
    }
    
    // 位置情報関連
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            // 許可を求めるコードを記述する（後述）
            locationManager.requestWhenInUseAuthorization() // 起動中のみ
//            locationManager.requestAlwaysAuthorization() // 常時
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation() // どちらか一方でのみ関数を呼び出せる
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            //            print("緯度:\(location.coordinate.latitude) 経度:\(location.coordinate.longitude) 取得時刻:\(location.timestamp.description)")
            // 位置情報
            gps.setObject(location.timestamp,   forKey: kCGImagePropertyGPSDateStamp as! NSCopying)
            gps.setObject(location.timestamp,   forKey: kCGImagePropertyGPSTimeStamp as! NSCopying)
            
            // 経度の設定
            
            // 緯度情報を取得
            var latitude = location.coordinate.latitude
            var gpsLatitudeRef = "N"        // 北緯
            if latitude < 0
            {
                latitude = -latitude;       // マイナス値はプラス値に反転
                gpsLatitudeRef = "S"        // 南緯
            }
            gps.setObject(gpsLatitudeRef,   forKey: kCGImagePropertyGPSLatitudeRef as! NSCopying)
            gps.setObject(latitude,         forKey: kCGImagePropertyGPSLatitude as! NSCopying)
            
            // 経度情報を取得
            var longitude = location.coordinate.longitude
            var gpsLongitudeRef = "E"       // 東経
            if longitude < 0
            {
                longitude = -longitude;     // マイナス値はプラス値に反転
                gpsLongitudeRef = "W"       // 西経
            }
            gps.setObject(gpsLongitudeRef,  forKey: kCGImagePropertyGPSLongitudeRef as! NSCopying)
            gps.setObject(longitude,        forKey: kCGImagePropertyGPSLongitude as! NSCopying)
            
            gps.setObject(0,                forKey: kCGImagePropertyGPSAltitudeRef as! NSCopying)
            gps.setObject(0,                forKey: kCGImagePropertyGPSAltitude as! NSCopying)
            
        }
        meta.setObject(gps, forKey: kCGImagePropertyGPSDictionary as! NSCopying)
        print("meta2",meta)
    }
    
    //シェアボタンで実行する
    @IBAction func shareAction(_ sender: Any) {
        guard let shareImage = shareImage else {
            return
        }
        //共有する内容
        let activities = [shareImage] as [Any]
        let activityVC = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // カメラのプライバシー認証確認
    func cameraAuth(){
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .notDetermined:
            // 初回起動時
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                          completionHandler: { [unowned self] authorized in
                                            print("初回", authorized.description)
                                            if authorized {
                                                self.authStatus = .authorized
                                            } else {
                                                self.authStatus = .notAuthorized
                                            }})
        case .restricted, .denied:
            authStatus = .notAuthorized
        case .authorized:
            authStatus = .authorized
        }
    }
    
    // 入出力の設定
    func setupInputOutput(){
        //解像度の指定
        session.sessionPreset = AVCaptureSession.Preset.photo
        // 入力の設定
        do {
            //デバイスの取得
            let device = AVCaptureDevice.default(
                AVCaptureDevice.DeviceType.builtInWideAngleCamera,
                for: AVMediaType.video, // ビデオ入力
                position: AVCaptureDevice.Position.back) // バックカメラ
            
            // 入力元
            let input = try AVCaptureDeviceInput(device: device!)
            if session.canAddInput(input){
                session.addInput(input)
            } else {
                print("セッションに入力を追加できなかった")
                return
            }
        } catch  let error as NSError {
            print("カメラがない \(error)")
            return
        }
        
        // 出力の設定
        if session.canAddOutput(photoOutputObj) {
            session.addOutput(photoOutputObj)
        } else {
            print("セッションに出力を追加できなかった")
            return
        }
    }
    
    // プレビューレイヤの設定
    func setPreviewLayer(){
        // プレビューレイヤを作る
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.masksToBounds = true
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        // previewViewに追加する
        previewView.layer.addSublayer(previewLayer)
    }
    
    //フラッシュのon,off
    @IBAction func changedevice(_ sender: Any) {
        if(toggle){
            ledFlash(flg: true)
            toggle = false
            
        }
        else{
            ledFlash(flg: false)
            toggle = true
        }
    }
    
    func ledFlash(flg: Bool){
        
        let avDevice = AVCaptureDevice.default(for: AVMediaType.video)!
        
        if avDevice.hasTorch {
            do {
                // torch device lock on
                try avDevice.lockForConfiguration()
                
                if (flg){
                    // フラッシュ LED ON
                    avDevice.torchMode = AVCaptureDevice.TorchMode.on
                } else {
                    // フラッシュ LED OFF
                    avDevice.torchMode = AVCaptureDevice.TorchMode.off
                }
                
                // torch device unlock
                avDevice.unlockForConfiguration()
                
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    // デバイスの向きが変わったときに呼び出すメソッド
    @objc func changedDeviceOrientation(_ notification :Notification) {
        // photoOutputObj.connectionの回転向きをデバイスと合わせる
        if let photoOutputConnection = self.photoOutputObj.connection(with: AVMediaType.video) {
            switch UIDevice.current.orientation {
            case .portrait:
                photoOutputConnection.videoOrientation = .portrait
            case .portraitUpsideDown:
                photoOutputConnection.videoOrientation = .portraitUpsideDown
            case .landscapeLeft:
                photoOutputConnection.videoOrientation = .landscapeRight
            case .landscapeRight:
                photoOutputConnection.videoOrientation = .landscapeLeft
            default:
                break
            }
        }
    }
    
    
    // プライバシー認証のアラートを表示する
    func showAlert(appName:String){
        let aTitle = appName + "のプライバシー認証"
        let aMessage = "設定＞プライバシー＞" + appName + "で利用を許可してください。"
        let alert = UIAlertController(title: aTitle, message: aMessage, preferredStyle: .alert)
        // OKボタン（何も実行しない）
        alert.addAction(
            UIAlertAction(title: "OK",style: .default,handler: nil)
        )
        // 設定を開くボタン
        alert.addAction(
            UIAlertAction(
                title: "設定を開く",style: .default,
                handler:  { action in
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            })
        )
        // アラートを表示する
        self.present(alert, animated: false, completion:nil)
    }
    
    func exifSetup(){
        exif.setObject("TDURD_PictureApp", forKey: kCGImagePropertyExifUserComment as! NSCopying)
        
        meta.setObject(exif,forKey:kCGImagePropertyExifDictionary as! NSCopying)
//        meta.setObject(gps, forKey: kCGImagePropertyGPSDictionary as! NSCopying)//
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


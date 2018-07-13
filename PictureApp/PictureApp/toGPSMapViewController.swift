//
//  toGPSMapViewController.swift
//  PictureApp
//
//  Created by 堤健太 on 2018/07/13.
//  Copyright © 2018年 keisuke. All rights reserved.
//

import UIKit
import ImageIO
import Photos
import AssetsLibrary
import Foundation
import MapKit


class toGPSMapViewController: UIViewController, UINavigationControllerDelegate ,UIImagePickerControllerDelegate{
    let BoundSize_w: CGFloat = UIScreen.main.bounds.width //横幅
    let BoundSize_h: CGFloat = UIScreen.main.bounds.height //縦幅
    
    // labelが表示されているかを確認するタグ
    var tag = 0
    
    //カメラロールを表示する imagePicker
    var imagePicker: UIImagePickerController!
    
    // Labelを作成.
    let myLabel: UILabel = UILabel(frame: CGRect(x:0 ,y:500, width:UIScreen.main.bounds.width - 50, height:50))
    
    //MapViewの生成
    let myMapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        //mapviewの設定    .frameでサイズと位置を指定する
        myMapView.frame = CGRect(x: 0,y: 0,width: BoundSize_w,height: BoundSize_h+100)
        self.view.addSubview(myMapView)
        
        //        initLabelView()
        initButton()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 選択したアイテムの元のバージョンのAssets Library URL
        let assetUrl = info[UIImagePickerControllerReferenceURL] as! URL
        // PHAsset = Photo Library上の画像、ビデオ、ライブフォト用の型
        let result = PHAsset.fetchAssets(withALAssetURLs: [assetUrl], options: nil)
        let asset = result.firstObject
        // コンテンツ編集セッションを開始するためのアセットの要求
        asset?.requestContentEditingInput(with: nil, completionHandler: { contentEditingInput, info in
            // contentEditingInput = 編集用のアセットに関する情報を提供するコンテナ
            let url = contentEditingInput?.fullSizeImageURL
            
            
            // 対象アセットのURLからCIImageを生成
            let inputImage = CIImage(contentsOf: url!)!
            // CIImageのpropertiesから画像のメタデータのなかのGPSを取得する
            if inputImage.properties["{GPS}"] as? Dictionary<String,Any> == nil {
                print("この写真にはGPS情報がありません")
                self.initLabelView()
                self.tag = 1
            } else {
                if self.tag == 1 {
                    self.myLabel.removeFromSuperview()
                    self.tag = 0
                }
                let gps = inputImage.properties["{GPS}"] as? Dictionary<String,Any>
                var latitude = gps!["Latitude"] as! Double
                let latitudeRef = gps!["LatitudeRef"] as! String
                var longitude = gps!["Longitude"] as! Double
                let longitudeRef = gps!["LongitudeRef"] as! String
                if latitudeRef == "S" {
                    latitude = latitude * -1
                }
                if longitudeRef == "W" {
                    longitude = longitude * -1
                }
                print(latitude)
                print(longitude)
                
                let currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longitude)
                //ピンの生成と配置
                let pin = MKPointAnnotation()
                pin.coordinate = currentLocation
                pin.title = "撮影地"
                self.myMapView.addAnnotation(pin)
                
                //アプリ起動時の表示領域の設定
                //delta数字を大きくすると表示領域も広がる。数字を小さくするとより詳細な地図が得られる。
                let mySpan = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                let myRegion = MKCoordinateRegionMake(currentLocation, mySpan)
                self.myMapView.region = myRegion
            }
        })
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // ボタンを追加する
    private func initButton(){
        let button1: UIButton = UIButton(frame: CGRect(x: 0,y: 0,width: 200,height: 30))
        // Buttonのスクリーンの横縦幅
        let screenWidth:CGFloat = self.view.frame.width
        let screenHeight:CGFloat = self.view.frame.height
        
        let setText = "位置情報を確認する"
        
        button1.frame = CGRect(x:screenWidth/4, y:screenHeight*4/5, width:screenWidth/2, height:50)
        button1.setTitle(setText, for:UIControlState.normal)
        button1.titleLabel?.font =  UIFont.systemFont(ofSize: 20)
        
        button1.setTitleColor(UIColor.black, for: .normal)
        
        button1.layer.borderColor = UIColor.black.cgColor
        button1.layer.borderWidth = 2
        button1.layer.cornerRadius = 10.0
        
        button1.backgroundColor = UIColor.init( red:0.9, green: 0.9, blue: 0.9, alpha: 1)
        button1.addTarget(self, action: #selector(toGPSMapViewController.buttonTapped(sender:)), for: .touchUpInside)//
        // Viewにボタンを追加
        self.view.addSubview(button1)
    }
    
    // labelを追加する
    func initLabelView(){
        // 背景を灰色にする.
        myLabel.backgroundColor = UIColor.gray
        // 枠を丸くする.
        myLabel.layer.masksToBounds = true
        
        // コーナーの半径.
        myLabel.layer.cornerRadius = 2.0
        
        // Label内の改行の限界を超える
        myLabel.numberOfLines = 0;
        
        // 文字の色を白にする.
        myLabel.textColor = UIColor.white
        
        // 文字の影の色をグレーにする.
        myLabel.shadowColor = UIColor.gray
        
        self.myLabel.text = "この写真にはGPS情報がありません"
        
        // Textを中央寄せにする.
        myLabel.textAlignment = NSTextAlignment.center
        
        // 配置する座標を設定する.
        myLabel.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2);
        
        // ViewにLabelを追加.
        self.view.addSubview(self.myLabel)
        // sc.addSubview(self.myLabel)
    }
    
    @objc func buttonTapped(sender : AnyObject) {
        //カメラロールを表示する
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

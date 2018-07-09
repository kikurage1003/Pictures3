//
//  ViewController.swift
//  ImageChange
//
//  Created by 早川　侑輝 on 2018/05/08.
//  Copyright © 2018年 早川　侑輝. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var brightslider: UISlider!
    var originalImage: UIImage?
    var earliestImage: UIImage?
    var nawrote: CGFloat = 0
    
    //モノクロボタンが押された時、呼び出し
    @IBAction func pushedMonochrome(_ sender: Any) {
        guard let image = imageView.image else{
            return
        }
        
        let monochroImage = monochromeImage(srcImage: image)
        
        imageView.image = monochroImage
        originalImage = monochroImage
    }
    
    //セピアボタンが押された時、呼び出し
    @IBAction func pushedSepia(_ sender: UIButton) {
        guard let image = imageView.image else{
            return
        }
        
        let sepiaImage = sepiacollerImage(srcImage: image)
        
        imageView.image = sepiaImage
        originalImage = sepiaImage
    }
    
    //ネガボタンが押された時、呼び出し
    @IBAction func pushedNegative(_ sender: UIButton) {
        guard let image = imageView.image else{
            return
        }
        
        let negaImage = negativeImage(srcImage: image)
        
        imageView.image = negaImage
        originalImage = negaImage
    }
    
    //引数のUIImageの画面の輝度を調整したUIImageを返す
    func brightnessImage(srcImage: UIImage, brightness: CGFloat) -> UIImage{
        //UIImageからCIImageを作成する
        let ciImage:CIImage = CIImage(image:srcImage)!;
        
        //コンテキストを作成する
        let ciContext:CIContext = CIContext(options: nil)
        
        //フィルターを作成する
        let ciFilter:CIFilter = CIFilter(name: "CIColorControls")!
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(brightness, forKey: kCIInputBrightnessKey)
        
        //フィルターを通した画像を生成する
        let cgimg:CGImage = ciContext.createCGImage(ciFilter.outputImage!, from:ciFilter.outputImage!.extent)!
        
        //CGImageRefからUIImageを生成して返す
        return UIImage(cgImage: cgimg, scale: 1.0, orientation: UIImageOrientation.up)
    }
    
    //引数のUIImageの画面をモノクロ化したUIImageを返す
    func monochromeImage(srcImage: UIImage) -> UIImage{
        let ciImage:CIImage = CIImage(image:srcImage)!;
        
        //コンテキストを作成する
        let ciContext:CIContext = CIContext(options: nil)
        
        //フィルターを作成する
        let ciFilter:CIFilter = CIFilter(name: "CIMinimumComponent")!
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        //フィルターを通した画像を生成する
        let cgimg:CGImage = ciContext.createCGImage(ciFilter.outputImage!, from:ciFilter.outputImage!.extent)!
        
        //CGImageRefからUIImageを生成して返す
        return UIImage(cgImage: cgimg, scale: 1.0, orientation: UIImageOrientation.up)
    }
    
    //引数のUIImageの画面をセピア化したUIImageを返す
    func sepiacollerImage(srcImage: UIImage) -> UIImage{
        let ciImage:CIImage = CIImage(image:srcImage)!;
        
        //コンテキストを作成する
        let ciContext:CIContext = CIContext(options: nil)
        
        //フィルターを作成する
        let ciFilter:CIFilter = CIFilter(name: "CISepiaTone")!
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        //フィルターを通した画像を生成する
        let cgimg:CGImage = ciContext.createCGImage(ciFilter.outputImage!, from:ciFilter.outputImage!.extent)!
        
        //CGImageRefからUIImageを生成して返す
        return UIImage(cgImage: cgimg, scale: 1.0, orientation: UIImageOrientation.up)
    }
    
    //引数のUIImageの画面を色相反転したUIImageを返す
    func negativeImage(srcImage: UIImage) -> UIImage{
        let ciImage:CIImage = CIImage(image:srcImage)!;
        
        //コンテキストを作成する
        let ciContext:CIContext = CIContext(options: nil)
        
        //フィルターを作成する
        let ciFilter:CIFilter = CIFilter(name: "CIColorInvert")!
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        //フィルターを通した画像を生成する
        let cgimg:CGImage = ciContext.createCGImage(ciFilter.outputImage!, from:ciFilter.outputImage!.extent)!
        
        //CGImageRefからUIImageを生成して返す
        return UIImage(cgImage: cgimg, scale: 1.0, orientation: UIImageOrientation.up)
    }
    
    //スライダーの値が変わった時に呼び出し
    @IBAction func valueChanged(_ sender: UISlider) {
        guard let image = originalImage else {
            return
        }
            imageView.image = brightnessImage(srcImage: image, brightness: CGFloat(sender.value))
    }
    
    //保存ボタンが押された時の処理
    @IBAction func save(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, Selector(("image:didFinishSavingWithError:contextInfo:")), nil)
    }
    
    
    @IBAction func savekari(_ sender: UIButton) {
    UIImageWriteToSavedPhotosAlbum(imageView.image!, self,
                                   nil, nil)
    }
    
    
    
    
    
    //カメラロールへ保存が完了した時に呼ばれる
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer){
        //UIAlertControllerのインスタンスを生成する
        let alert:UIAlertController = UIAlertController(title: "完了", message: "カメラロールに保存完了", preferredStyle:UIAlertControllerStyle.alert)
        
        //Cancel 1つのみ指定可能
        //今回はキャンセルは特に意味をなさない
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (action:UIAlertAction!) -> Void in
            print("cancel")
        })
        
        //Default 複数指定可
        let defaultAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            (action:UIAlertAction!) ->Void in
            print("OK")
        })
        
        //UIAlertControllerにActionを指定する
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        //Alertを表示する
        present(alert, animated: true, completion: nil)
    }
    
    var param : UIImage?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.param
        self.originalImage = self.param
        self.earliestImage = self.param
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /*
    // UIImageViewがタップされた時に呼ばれる。ImagePickerを表示させる
    @IBAction func handletap(_ sender: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
        {
            let ipc:UIImagePickerController = UIImagePickerController();
            ipc.delegate = self
            ipc.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(ipc, animated: true, completion: nil)
        }
    }
    
    // ImagePickerで画像が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerOriginalImage] != nil{
            
            //選択した画像をUIImageViewに設定する
            imageView.image = info[UIImagePickerControllerOriginalImage]as? UIImage
            
            
            //加工用にメンバ変数に保持しておく
            originalImage = info[UIImagePickerControllerOriginalImage]as? UIImage
        }
        
        //imagePickerを閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    */
    
    
    
    @IBAction func rightRotation(_ sender: UIButton) {
        var transRotate = CGAffineTransform()
        
        // 画像を90度回転
        let angle = (90+nawrote) * CGFloat.pi / 180
        transRotate = CGAffineTransform(rotationAngle: CGFloat(angle));
        imageView.transform = transRotate
        nawrote += 90
    }
    
    
    @IBAction func leftRotation(_ sender: UIButton) {
      var transRotate = CGAffineTransform()
        
        // 画像を-90度回転
        let angle = (-90+nawrote) * CGFloat.pi / 180
        transRotate = CGAffineTransform(rotationAngle: CGFloat(angle));
        imageView.transform = transRotate
        nawrote -= 90
 
        
       /* var kariimage: CGImage
        kariimage = (originalImage?.cgImage!)!;
        let Width:Int
        Width = (kariimage.width)
        let Height:Int
        Height = (kariimage.height)*/
        
        //  let angle = (-90+nawrote) * CGFloat.pi / 180
       /* kariimage = CGRect(x:CGFloat(Width/2), y:CGFloat(Height/2), width:CGFloat(Width), height:CGFloat(Height)) as! CGImage
         originalImage = kariimage */
        
        //var crateimage: UIImage
           // createimage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
        
        
       /* guard let image = imageView.image else{
            return
        }
        
        let R_Image = RotationR(srcImage: image)
        
        imageView.image = R_Image
        originalImage = R_Image
        */
    }
    
    func RotationR(srcImage: UIImage) -> UIImage{
        let ciImage:CIImage = CIImage(image:srcImage)!;
        
        //フィルターを作成する
        let ciFilter:CIFilter = CIFilter(name: "CIStraightenFilter")!
        ciFilter.setDefaults()
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue((90*CGFloat.pi) / 180, forKey: kCIInputImageKey)
        
        //コンテキストを作成する
        let ciContext:CIContext = CIContext(options: nil)
        //フィルターを通した画像を生成する
        let cgimg:CGImage = ciContext.createCGImage(ciFilter.outputImage!, from:ciFilter.outputImage!.extent)!
        //CGImageRefからUIImageを生成して返す
        return UIImage(cgImage: cgimg, scale: 1.0, orientation: UIImageOrientation.up)
        
        /*
        //フィルターを通した画像を生成する
        let output = ciFilter.outputImage
        //CGImageRefからUIImageを生成して返す
        return UIImage(ciImage: output!)
 */
        
        
        /*
         let ciImage:CIImage = CIImage(image:srcImage)!;
         
         //コンテキストを作成する
         let ciContext:CIContext = CIContext(options: nil)
         
         //フィルターを作成する
         let ciFilter:CIFilter = CIFilter(name: "CISepiaTone")!
         ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
         
         //フィルターを通した画像を生成する
         let cgimg:CGImage = ciContext.createCGImage(ciFilter.outputImage!, from:ciFilter.outputImage!.extent)!
         
         //CGImageRefからUIImageを生成して返す
         return UIImage(cgImage: cgimg, scale: 1.0, orientation: UIImageOrientation.up)
 */
    }
    
    
    @IBAction func ResetImage(_ sender: Any) {
        //画像データを最初期のものに戻す
        imageView.image = earliestImage
        //輝度を初期値(0)に戻す
        brightslider.value = 0
        //回転を変更前に戻す
        var transRotate = CGAffineTransform()
        nawrote = 0
        let angle = (nawrote) * CGFloat.pi / 180
        transRotate = CGAffineTransform(rotationAngle: CGFloat(angle));
        imageView.transform = transRotate
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


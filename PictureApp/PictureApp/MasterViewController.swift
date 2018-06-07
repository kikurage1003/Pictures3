
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Manages the top-level table view, a list of photo collections.
 */


import UIKit
import Photos

class MasterViewController: UITableViewController{
    
    // MARK: Types for managing sections, cell and segue identifiers
    enum Section: Int {
        case allPhotos = 0
        case smartAlbums
        case userCollections
        
        static let count = 3
    }
    
    
    //せるのIDを定義
    enum CellIdentifier: String {
        case allPhotos, collection
    }
    
    //セグエのIDを定義
    enum SegueIdentifier: String {
        case showAllPhotos
        case showCollection
    }
    
    // MARK: Properties
    //使う要素の定義
    var allPhotos: PHFetchResult<PHAsset>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!
    let sectionLocalizedTitles = ["", NSLocalizedString("Smart Albums", comment: ""), NSLocalizedString("Albums", comment: "")]
    var thumbnail:CGSize!
    // MARK: UIViewController / Lifecycle
    //ロード時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = UIScreen.main.scale;
        
        thumbnail = CGSize(width:120, height: 120)
        
        //ボタン機能のインスタンス化？
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addAlbum))
        //右上にaddボタンを追加
        self.navigationItem.rightBarButtonItem = addButton
        
        
        // Create a PHFetchResult object for each section in the table view.
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        PHPhotoLibrary.shared().register(self)
        
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc func addAlbum(_ sender: AnyObject) {
        let alertController = UIAlertController(title: NSLocalizedString("New Album", comment: ""), message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Album Name", comment: "")
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Create", comment: ""), style: .default) { action in
            let textField = alertController.textFields!.first!
            if let title = textField.text, !title.isEmpty {
                // Create a new album with the title entered.
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                }, completionHandler: { success, error in
                    if !success { print("error creating album: \(error)") }
                })
            }
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: Segues
    //画面遷移行う関数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = (segue.destination as? UINavigationController)?.topViewController as? AssetGridViewController
            else { fatalError("unexpected view controller for segue") }
        let cell = sender as! UITableViewCell
        
        destination.title = cell.textLabel?.text
        switch SegueIdentifier(rawValue: segue.identifier!)! {
        case .showAllPhotos:
            destination.fetchResult = allPhotos
        case .showCollection:
            
            // get the asset collection for the selected row
            let indexPath = tableView.indexPath(for: cell)!
            let collection: PHCollection
            switch Section(rawValue: indexPath.section)! {
            case .smartAlbums:
                collection = smartAlbums.object(at: indexPath.row)
            case .userCollections:
                collection = userCollections.object(at: indexPath.row)
            default: return // not reached; all photos section already handled by other segue
            }
            
            // configure the view controller with the asset collection
            guard let assetCollection = collection as? PHAssetCollection
                else { fatalError("expected asset collection") }
            destination.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
            destination.assetCollection = assetCollection
        }
    }
    
    // MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .allPhotos: return 1
        case .smartAlbums: return smartAlbums.count
        case .userCollections: return userCollections.count
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .allPhotos:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.allPhotos.rawValue, for: indexPath)
            cell.textLabel!.text = NSLocalizedString("All Photos", comment: "")
            let options = PHFetchOptions();
            options.sortDescriptors = [NSSortDescriptor(key:("creationDate"),ascending:false)]
            let result = PHAsset.fetchAssets(with: .image, options: options);
            if let asset = result.firstObject {
                let manager: PHImageManager = PHImageManager()
                manager.requestImage(for: asset,
                                     targetSize: thumbnail,
                                     contentMode: .aspectFill, options: nil,
                                     resultHandler:{image,options in
                                        cell.imageView?.contentMode = UIViewContentMode.scaleAspectFill;
                                        let temp = image;
                                        
                                        cell.imageView!.image = temp!.resize(size: CGSize(width: 120, height: 120));
                })
            }
            return cell
            
        case .smartAlbums:
            let collection = smartAlbums.object(at: indexPath.row)
            let cell = tableView.dequeueReusableCell(withIdentifier: "collection", for: indexPath);
            cell.textLabel!.text = collection.localizedTitle;
            //画像を全て取得
            let options = PHFetchOptions();
            options.sortDescriptors = [NSSortDescriptor(key:("creationDate"),ascending:false)]
            let assets = PHAsset.fetchAssets(in: collection, options: options)
            
            if let asset = assets.firstObject {
                let manager: PHImageManager = PHImageManager()
                manager.requestImage(for: asset,
                                     targetSize: thumbnail,
                                     contentMode: .aspectFill, options: nil,
                                     resultHandler:{image,options in
                                        
                                        cell.imageView?.contentMode = UIViewContentMode.scaleAspectFill;
                                        let temp = image;
                                        
                                        cell.imageView!.image = temp!.resize(size: CGSize(width: 120, height: 120));
                                        
                })
            }
            return cell
            
        case .userCollections:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue,for : indexPath);
            let collection = userCollections.object(at: indexPath.row)
            cell.textLabel!.text = collection.localizedTitle
            //画像を全て取得
            let options = PHFetchOptions();
            options.sortDescriptors = [NSSortDescriptor(key:("creationDate"),ascending:false)]
            let assets = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: options)
            if let asset = assets.firstObject {
                let manager: PHImageManager = PHImageManager()
                manager.requestImage(for: asset,
                                     targetSize: thumbnail,
                                     contentMode: .aspectFill, options: nil,
                                     resultHandler:{image,options in
                                        cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit;
                                        let temp = image;
                                        cell.imageView!.image = temp!.resize(size: CGSize(width: 120, height: 120));
                })
            }
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLocalizedTitles[section]
    }
    
    
}


// MARK: PHPhotoLibraryChangeObserver
extension MasterViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Check each of the three top-level fetches for changes.
            
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                // Update the cached fetch result.
                allPhotos = changeDetails.fetchResultAfterChanges
                // (The table row for this one doesn't need updating, it always says "All Photos".)
            }
            
            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
                tableView.reloadSections(IndexSet(integer: Section.smartAlbums.rawValue), with: .automatic)
            }
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
                tableView.reloadSections(IndexSet(integer: Section.userCollections.rawValue), with: .automatic)
            }
            
        }
    }
    
}

extension UIImage{
    func resize(size: CGSize) -> UIImage {
        /*
         let widthRatio = size.width / self.size.width
         let heightRatio = size.height / self.size.height
         //let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
         let ratio = widthRatio;
         */
        let resizedSize =  size;
        // 画質を落とさないように以下を修正
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
}


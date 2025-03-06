//
//  PhotoDetailViewController.swift
//  PrivatePhotoVault
//
//  Created by Vishwajeet Sarkar on 06/03/25.
//

import UIKit
import CryptoKit

class PhotoDetailViewController: UIViewController {
    private let photoItem: PhotoItem
    private let storageManager = PhotoStorageManager()
    private let securityManager = SecurityManager()
    private let encryptionKey: SymmetricKey
    
    init(photoItem: PhotoItem, encryptionKey: SymmetricKey) {
        self.photoItem = photoItem
        self.encryptionKey = encryptionKey
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        do {
            let data = try storageManager.loadPhoto(for: photoItem, key: encryptionKey)
            let image = UIImage(data: data)
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = view.bounds
            view.addSubview(imageView)
        } catch {
            let alert = UIAlertController(title: "Error", message: "Failed to load photo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

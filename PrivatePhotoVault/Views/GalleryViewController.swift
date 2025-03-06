//
//  GalleryViewController.swift
//  PrivatePhotoVault
//
//  Created by Vishwajeet Sarkar on 06/03/25.
//

import UIKit
import Photos
import CryptoKit

class GalleryViewController: UIViewController {
    private let storageManager = PhotoStorageManager()
    private let securityManager = SecurityManager()
    private var photos: [PhotoItem] = []
    private var encryptionKey: SymmetricKey?
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Photo Vault"
        setupCollectionView()
        setupNavigation()
        
        // Initialize encryption key and load photos
        do {
            encryptionKey = try securityManager.retrieveEncryptionKey()
            loadPhotos()
        } catch {
            showAlert(message: "Failed to load encryption key.")
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhotoTapped))
    }
    
    private func loadPhotos() {
        let photoIDs = storageManager.getAllPhotoIDs()  // Returns [UUID]
        photos = photoIDs.map { PhotoItem(id: $0) }     // Create PhotoItems with image as nil
        collectionView.reloadData()
    }
    
    @objc private func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
        var photo = photos[indexPath.item]  // Get the PhotoItem (mutable copy)
        
        // Load the image if it’s not already loaded
        if photo.image == nil {
            do {
                guard let key = encryptionKey else {
                    print("Encryption key is nil")
                    return cell
                }
                let imageData = try storageManager.loadPhoto(for: photo, key: key)
                if let loadedImage = UIImage(data: imageData) {
                    photo.image = loadedImage               // Assign the loaded image
                    photos[indexPath.item] = photo          // Update the array to cache the image
                }
            } catch {
                print("Failed to load photo: \(error)")
            }
        }
        
        // Configure the cell with the image
        if let image = photo.image {
            // Clear any existing subviews (to handle cell reuse)
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            cell.contentView.addSubview(imageView)
            imageView.frame = cell.contentView.bounds
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let key = encryptionKey else {
            showAlert(message: "Encryption key not available.")
            return
        }
        let photo = photos[indexPath.item]
        let detailVC = PhotoDetailViewController(photoItem: photo, encryptionKey: key)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage,
              let key = encryptionKey,
              let imageData = image.jpegData(compressionQuality: 1.0) else {
            dismiss(animated: true)
            return
        }
        
        let photo = PhotoItem(image: image)  // Temporary PhotoItem for saving
        do {
            try storageManager.savePhoto(imageData, for: photo, key: key)  // Save to disk
            photos.append(PhotoItem(id: photo.id))                        // Append with image as nil
            collectionView.reloadData()
        } catch {
            showAlert(message: "Failed to save photo.")
        }
        
        dismiss(animated: true)
    }
}

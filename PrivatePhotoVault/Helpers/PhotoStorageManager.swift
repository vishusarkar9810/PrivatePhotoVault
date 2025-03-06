//
//  PhotoStorageManager.swift
//  PrivatePhotoVault
//
//  Created by Vishwajeet Sarkar on 06/03/25.
//

import Foundation
import CryptoKit

class PhotoStorageManager {
    private let fileManager = FileManager.default
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let securityManager = SecurityManager()
    
    // Save photo to disk
    func savePhoto(_ imageData: Data, for photoItem: PhotoItem, key: SymmetricKey) throws {
        let fileURL = documentsURL.appendingPathComponent(photoItem.id.uuidString)
        let encryptedData = try securityManager.encrypt(data: imageData, key: key)
        try encryptedData.write(to: fileURL)
    }
    
    // Load photo
    func loadPhoto(for photoItem: PhotoItem, key: SymmetricKey) throws -> Data {
        let fileURL = documentsURL.appendingPathComponent(photoItem.id.uuidString)
        let encryptedData = try Data(contentsOf: fileURL)
        return try securityManager.decrypt(data: encryptedData, key: key)
    }
    
    // Delete photo from disk
    func deletePhoto(_ photoItem: PhotoItem) throws {
        let fileURL = documentsURL.appendingPathComponent(photoItem.id.uuidString)
        try fileManager.removeItem(at: fileURL)
    }
    
    // Get all photo IDs
    func getAllPhotoIDs() -> [UUID] {
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentsURL.path)
            return files.compactMap { UUID(uuidString: $0) }
        } catch {
            return []
        }
    }
}

//
//  BackupManager.swift
//  PrivatePhotoVault
//
//  Created by Vishwajeet Sarkar on 06/03/25.
//

import Zip
import Foundation

class BackupManager {
    private let fileManager = FileManager.default
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // Backup photos to a zip file
    func backupPhotos(to url: URL) throws {
        try Zip.zipFiles(paths: [documentsURL], zipFilePath: url, password: nil, progress: nil)
    }
    
    // Restore photos from a zip file
    func restorePhotos(from url: URL) throws {
        try Zip.unzipFile(url, destination: documentsURL, overwrite: true, password: nil)
    }
}

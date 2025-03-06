//
//  SecurityManager.swift
//  PrivatePhotoVault
//
//  Created by Vishwajeet Sarkar on 06/03/25.
//

import CryptoKit
import Security
import Foundation

class SecurityManager {
    private let keychainKey = "com.yourapp.encryptionKey"
    private let passcodeKey = "com.yourapp.passcode"
    
    // Save passcode to Keychain
    func savePasscode(_ passcode: String) throws {
        let data = passcode.data(using: .utf8)!
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: passcodeKey,
            kSecValueData: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw VaultError.keychainError
        }
    }
    
    // Retrieve passcode from Keychain
    func retrievePasscode() throws -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: passcodeKey,
            kSecReturnData: true
        ] as [String: Any]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    // Generate and save encryption key
    func generateAndSaveEncryptionKey() throws {
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey,
            kSecValueData: keyData
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw VaultError.keychainError
        }
    }
    
    // Retrieve encryption key
    func retrieveEncryptionKey() throws -> SymmetricKey? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keychainKey,
            kSecReturnData: true
        ] as [String: Any]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let keyData = item as? Data else {
            return nil
        }
        return SymmetricKey(data: keyData)
    }
    
    // Encrypt data
    func encrypt(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }
    
    // Decrypt data
    func decrypt(data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }
}

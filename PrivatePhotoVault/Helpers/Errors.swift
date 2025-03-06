//
//  Errors.swift
//  PrivatePhotoVault
//
//  Created by Vishwajeet Sarkar on 06/03/25.
//

import Foundation

enum VaultError: Error {
    case keychainError
    case encryptionError
    case fileError
    case invalidPasscode
}

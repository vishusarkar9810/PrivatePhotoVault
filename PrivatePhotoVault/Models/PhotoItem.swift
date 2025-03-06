//
//  PhotoItem.swift
//  PrivatePhotoVault
//
//  Created by Vishwajeet Sarkar on 06/03/25.
//

import Foundation
import UIKit

struct PhotoItem: Identifiable {
    let id: UUID
    var image: UIImage?
    
    init(id: UUID, image: UIImage? = nil) {
        self.id = id
        self.image = image
    }
    
    init(image: UIImage) {
        self.id = UUID()
        self.image = image
    }
}

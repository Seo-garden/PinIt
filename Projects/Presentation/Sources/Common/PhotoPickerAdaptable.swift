//
//  PhotoPickerAdaptable.swift
//  Presentation
//
//  Created by 서정원 on 3/13/26.
//

import Domain
import UIKit

public protocol PhotoPickerAdaptable: AnyObject {
    func presentCamera(from controller: UIViewController, completion: @escaping (Result<[PhotoData], PhotoError>) -> Void)
    func presentGallery(from controller: UIViewController, maxAdditionalCount: Int, completion: @escaping (Result<[PhotoData], PhotoError>) -> Void)
}

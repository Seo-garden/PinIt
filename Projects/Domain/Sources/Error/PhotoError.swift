//
//  PhotoError.swift
//  Domain
//
//  Created by 서정원 on 3/13/26.
//

import Foundation

public enum PhotoError: LocalizedError {
    case accessDenied
    case unavailable
    case loadFailed

    public var errorDescription: String? {
        switch self {
        case .accessDenied: return "Access to the requested resource was denied."
        case .unavailable: return "The requested resource is not available on this device."
        case .loadFailed: return "Could not load the selected photo."
        }
    }
}

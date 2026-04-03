//
//  RecordCaptionValidator.swift
//  Domain
//
//  Created by 서정원 on 3/14/26.
//

import Foundation

public enum RecordCaptionValidator {
    public static let maxLength = 300
    
    public static func truncate(_ text: String) -> String {
        String(text.prefix(maxLength))
    }
    
    public static func isValid(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public static func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

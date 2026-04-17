//
//  FeedSortOption.swift
//  Presentation
//
//  Created by 서정원 on 4/17/26.
//

import Domain
import Foundation

public enum FeedSortOption: CaseIterable {
    case dateDescending
    case nameAscending

    public var title: String {
        switch self {
        case .dateDescending: return "날짜순"
        case .nameAscending: return "이름순"
        }
    }

    public func sort(_ records: [Record]) -> [Record] {
        switch self {
        case .dateDescending:
            return records.sorted { $0.createdAt > $1.createdAt }
        case .nameAscending:
            return records.sorted {
                $0.locationTitle.localizedCaseInsensitiveCompare($1.locationTitle) == .orderedAscending
            }
        }
    }
}

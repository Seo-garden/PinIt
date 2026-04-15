//
//  MapCoordinator.swift
//  Presentation
//
//  Created by 서정원 on 4/15/26.
//

import Domain
import UIKit

public final class MapCoordinator {
    private let makeDetailViewController: (Record) -> DetailRecordViewController

    public init(makeDetailViewController: @escaping (Record) -> DetailRecordViewController) {
        self.makeDetailViewController = makeDetailViewController
    }

    func pushDetail(record: Record, from controller: UIViewController) {
        let detailVC = makeDetailViewController(record)
        controller.navigationController?.pushViewController(detailVC, animated: true)
    }
}

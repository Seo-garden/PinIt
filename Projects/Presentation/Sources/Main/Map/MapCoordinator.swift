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
    private let makeBottomSheetViewController: () -> MapBottomSheetViewController

    public init(
        makeDetailViewController: @escaping (Record) -> DetailRecordViewController,
        makeBottomSheetViewController: @escaping () -> MapBottomSheetViewController
    ) {
        self.makeDetailViewController = makeDetailViewController
        self.makeBottomSheetViewController = makeBottomSheetViewController
    }

    func pushDetail(record: Record, from controller: UIViewController) {
        let detailVC = makeDetailViewController(record)
        controller.navigationController?.pushViewController(detailVC, animated: true)
    }

    func makeBottomSheet() -> MapBottomSheetViewController {
        makeBottomSheetViewController()
    }
}

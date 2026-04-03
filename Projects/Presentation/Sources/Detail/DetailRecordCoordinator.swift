//
//  DetailRecordCoordinator.swift
//  Presentation
//
//  Created by 서정원 on 4/2/26.
//

import UIKit

public final class DetailRecordCoordinator {
    public init() {}
    func showAlert(from controller: UIViewController, title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AppStrings.Common.confirm, style: .default) { _ in completion?() })
        controller.present(alert, animated: true)
    }

    func showDeleteConfirmation(from controller: UIViewController, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: AppStrings.Detail.deleteTitle,
            message: AppStrings.Detail.deleteMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppStrings.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: AppStrings.Detail.delete, style: .destructive) { _ in onConfirm() })
        controller.present(alert, animated: true)
    }
}

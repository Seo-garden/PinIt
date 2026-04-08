//
//  SettingViewController.swift
//  Presentation
//
//  Created by 서정원 on 4/7/26.
//

import UIKit
import RxCocoa
import RxSwift

public final class SettingViewController: BaseViewController<SettingViewModel> {
    private let onLogout: (() -> Void)?
    private let settingView = SettingView()

    private let notificationSwitch = UISwitch()
    private let logoutTapRelay = PublishRelay<Void>()
    private let deleteAccountTapRelay = PublishRelay<Void>()

    private var displayName: String = "User"
    private var email: String = ""

    public init(viewModel: SettingViewModel, onLogout: (() -> Void)? = nil) {
        self.onLogout = onLogout
        super.init(viewModel: viewModel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "설정"
        navigationItem.largeTitleDisplayMode = .never

        settingView.tableView.dataSource = self
        settingView.tableView.delegate = self

        view.addSubview(settingView)
    }

    public override func setupLayout() {
        settingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            settingView.topAnchor.constraint(equalTo: view.topAnchor),
            settingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    public override func bind() {
        let viewDidLoadSignal = Observable.just(()).asSignal(onErrorSignalWith: .empty())

        let input = SettingViewModel.Input(
            viewDidLoad: viewDidLoadSignal,
            logoutTap: logoutTapRelay.asSignal(),
            deleteAccountTap: deleteAccountTapRelay.asSignal()
        )

        let output = viewModel.transform(input: input)

        Driver.combineLatest(output.displayName, output.email)
            .drive(onNext: { [weak self] name, email in
                guard let self else { return }
                self.displayName = name
                self.email = email
                self.settingView.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        output.logoutSucceeded
            .emit(onNext: { [weak self] in
                self?.onLogout?()
            })
            .disposed(by: disposeBag)

        output.deleteAccountSucceeded
            .emit(onNext: { [weak self] in
                self?.onLogout?()
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .emit(onNext: { [weak self] message in
                self?.presentAlert(title: AppStrings.Setting.errorTitle, message: message)
            })
            .disposed(by: disposeBag)
    }

    private func showDeleteConfirmation() {
        let alert = UIAlertController(
            title: AppStrings.Setting.deleteAccountConfirmTitle,
            message: AppStrings.Setting.deleteAccountConfirmMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppStrings.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: AppStrings.Setting.deleteAccount, style: .destructive) { [weak self] _ in
            self?.deleteAccountTapRelay.accept(())
        })
        present(alert, animated: true)
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AppStrings.Common.confirm, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        SettingSection.allCases.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let settingSection = SettingSection(rawValue: section) else { return 0 }
        return SettingRow.rows(for: settingSection).count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SettingSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        let row = SettingRow.rows(for: section)[indexPath.row]

        switch row {
        case .profile:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingProfileCell.reuseIdentifier,
                for: indexPath
            ) as? SettingProfileCell else { return UITableViewCell() }
            cell.nameLabel.text = displayName
            cell.emailLabel.text = email
            return cell

        case .notification:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = AppStrings.Setting.pushNotifications
            config.image = UIImage(systemName: "bell.fill")
            cell.contentConfiguration = config
            cell.accessoryView = notificationSwitch
            cell.selectionStyle = .none
            return cell

        case .privacyPolicy:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = AppStrings.Setting.privacyPolicy
            config.image = UIImage(systemName: "lock.shield")
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell

        case .termsOfService:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = AppStrings.Setting.termsOfService
            config.image = UIImage(systemName: "doc.text")
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell

        case .changePassword:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = AppStrings.Setting.changePassword
            config.image = UIImage(systemName: "key.horizontal")
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell

        case .logout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = AppStrings.Setting.logout
            config.textProperties.alignment = .center
            config.textProperties.color = UIColor(red: 55/255, green: 48/255, blue: 107/255, alpha: 1)
            config.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
            cell.contentConfiguration = config
            cell.accessoryType = .none
            return cell

        case .deleteAccount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = AppStrings.Setting.deleteAccount
            config.textProperties.alignment = .center
            config.textProperties.color = .systemRed
            config.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
            cell.contentConfiguration = config
            cell.accessoryType = .none
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = SettingSection(rawValue: indexPath.section) else { return }
        let row = SettingRow.rows(for: section)[indexPath.row]

        switch row {
        case .logout:
            logoutTapRelay.accept(())
        case .deleteAccount:
            showDeleteConfirmation()
        default:
            break
        }
    }
}

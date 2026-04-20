//
//  SettingView.swift
//  Presentation
//

import UIKit

enum SettingSection: Int, CaseIterable {
    case general
    case account
    case danger
}

enum SettingRow {
    case profile
    case privacyPolicy
    case termsOfService
    case changePassword
    case logout
    case deleteAccount

    static func rows(for section: SettingSection) -> [SettingRow] {
        switch section {
        case .general:
            return [.profile, .privacyPolicy, .termsOfService]
        case .account:
            return [.changePassword]
        case .danger:
            return [.logout, .deleteAccount]
        }
    }
}

final class SettingView: UIView {
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SettingProfileCell.self, forCellReuseIdentifier: SettingProfileCell.reuseIdentifier)
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(tableView)

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let footerLabel = UILabel()
        footerLabel.text = "APP VERSION v\(version)"
        footerLabel.font = .systemFont(ofSize: 12, weight: .regular)
        footerLabel.textColor = .tertiaryLabel
        footerLabel.textAlignment = .center
        footerLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
        tableView.tableFooterView = footerLabel
    }

    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Profile Cell

final class SettingProfileCell: UITableViewCell {
    static let reuseIdentifier = "SettingProfileCell"

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = "User"
        return label
    }()

    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

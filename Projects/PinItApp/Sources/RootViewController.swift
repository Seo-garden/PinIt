import UIKit
import RxSwift
import RxCocoa

final class RootViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PinIt"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "사진 + 캡션 + 장소를 기록하는 앱"
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let loginButton = UIButton(type: .system)
    private let mapButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "홈"

        configureButtons()
        configureLayout()
        bindActions()
    }

    private func configureButtons() {
        loginButton.configuration = .filled()
        loginButton.configuration?.title = "로그인 화면"

        mapButton.configuration = .bordered()
        mapButton.configuration?.title = "지도 화면"
    }

    private func configureLayout() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, loginButton, mapButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func bindActions() {
        loginButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.pushViewController(LoginViewController(), animated: true)
            }
            .disposed(by: disposeBag)

        mapButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.pushViewController(MapViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
}

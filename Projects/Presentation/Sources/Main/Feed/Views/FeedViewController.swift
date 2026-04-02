//
//  FeedViewController.swift
//  Presentation
//
//  Created by 서정원 on 3/20/26.
//

import Domain
import RxCocoa
import RxSwift
import UIKit

public final class FeedViewController: BaseViewController<FeedViewModel> {
    private let coordinator: FeedCoordinator
    private let viewDidAppearRelay = PublishRelay<Void>()
    private let selectRecordRelay = PublishRelay<Int>()
    private var records: [Record] = []

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        return table
    }()

    public init(viewModel: FeedViewModel, coordinator: FeedCoordinator) {
        self.coordinator = coordinator
        super.init(viewModel: viewModel)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearRelay.accept(())
    }

    public override func setupUI() {
        title = "기록 목록"
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
    }

    public override func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    public override func bind() {
        let input = FeedViewModel.Input(
            viewDidAppear: viewDidAppearRelay.asSignal(onErrorSignalWith: .empty()),
            selectRecord: selectRecordRelay.asSignal(onErrorSignalWith: .empty())
        )

        let output = viewModel.transform(input: input)

        output.records
            .drive(onNext: { [weak self] records in
                self?.records = records
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        output.navigateToDetail
            .emit(onNext: { [weak self] record in
                guard let self else { return }
                self.coordinator.pushDetail(record: record, from: self)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let record = records[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = record.caption.isEmpty ? "(캡션 없음)" : record.caption
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        content.secondaryText = "\(formatter.string(from: record.createdAt))  ·  사진 \(record.photoDataList.count)장"
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectRecordRelay.accept(indexPath.row)
    }
}

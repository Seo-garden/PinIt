//
//  FeedViewController.swift
//  Presentation
//
//  Created by 서정원 on 3/20/26.
//

import Domain
import RxCocoa
import RxRelay
import RxSwift
import UIKit

public final class FeedViewController: BaseViewController<FeedViewModel> {
    private let coordinator: FeedCoordinator
    private let viewDidAppearRelay = PublishRelay<Void>()
    private let selectRecordRelay = PublishRelay<Int>()
    private let searchTextRelay = BehaviorRelay<String>(value: "")
    private let sortOptionRelay = BehaviorRelay<FeedSortOption>(value: .dateDescending)
    private var records: [Record] = []

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(FeedCell.self, forCellReuseIdentifier: FeedCell.reuseIdentifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 96
        return table
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "제목으로 검색하세요!"
        controller.searchResultsUpdater = self
        return controller
    }()

    private lazy var sortButton: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            style: .plain,
            target: nil,
            action: nil
        )
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
        title = "피드"
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem = sortButton
        updateSortMenu()
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
            selectRecord: selectRecordRelay.asSignal(onErrorSignalWith: .empty()),
            searchText: searchTextRelay.asDriver(),
            sortOption: sortOptionRelay.asDriver()
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

    private func updateSortMenu() {
        let current = sortOptionRelay.value
        let actions = FeedSortOption.allCases.map { option in
            UIAction(
                title: option.title,
                state: option == current ? .on : .off
            ) { [weak self] _ in
                self?.sortOptionRelay.accept(option)
                self?.updateSortMenu()
            }
        }
        sortButton.menu = UIMenu(title: "정렬", children: actions)
    }
}

// MARK: - UISearchResultsUpdating

extension FeedViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        guard text != searchTextRelay.value else { return }
        searchTextRelay.accept(text)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.reuseIdentifier, for: indexPath) as? FeedCell else {
            return UITableViewCell()
        }
        cell.configure(with: records[indexPath.row])
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectRecordRelay.accept(indexPath.row)
    }
}

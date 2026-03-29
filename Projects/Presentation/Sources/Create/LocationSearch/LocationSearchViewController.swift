//
//  LocationSearchViewController.swift
//  Presentation
//
//  Created by 서정원 on 3/24/26.
//

import MapKit
import RxCocoa
import RxRelay
import RxSwift
import UIKit

public final class LocationSearchViewController: BaseViewController<LocationSearchViewModel> {
    private let searchView = LocationSearchView()
    private let searchTextRelay = PublishRelay<String>()
    private let selectItemRelay = PublishRelay<Int>()
    private let selectTapRelay = PublishRelay<Void>()
    private var currentResults: [LocationSearchItem] = []
    private var selectedItem: LocationSearchItem?
    var onLocationSelected: ((LocationSearchItem) -> Void)?

    public override init(viewModel: LocationSearchViewModel) {
        super.init(viewModel: viewModel)
    }

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = AppStrings.Search.title
    }

    // MARK: - Setup
    public override func setupUI() {
        super.setupUI()
        view.addSubview(searchView)
        searchView.translatesAutoresizingMaskIntoConstraints = false

        searchView.tableView.dataSource = self
        searchView.tableView.delegate = self
        searchView.tableView.register(
            LocationSearchResultCell.self,
            forCellReuseIdentifier: LocationSearchResultCell.reuseIdentifier
        )

        searchView.searchBar.delegate = self
        searchView.selectButton.addTarget(self, action: #selector(didTapSelect), for: .touchUpInside)
    }

    public override func setupLayout() {
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    public override func bind() {
        let searchText = searchTextRelay
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asSignal(onErrorJustReturn: "")

        let selectItem = selectItemRelay.asSignal(onErrorSignalWith: .empty())
        let selectTap = selectTapRelay.asSignal(onErrorSignalWith: .empty())

        let input = LocationSearchViewModel.Input(
            searchText: searchText,
            selectItem: selectItem,
            selectTap: selectTap
        )

        let output = viewModel.transform(input: input)

        output.searchResults
            .drive(onNext: { [weak self] results in
                guard let self else { return }
                self.currentResults = results
                self.searchView.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        output.selectedItem
            .drive(onNext: { [weak self] item in
                guard let self else { return }
                let hasSelection = item != nil
                self.searchView.selectButton.isEnabled = hasSelection
                self.searchView.selectButton.alpha = hasSelection ? 1.0 : 0.5

                self.selectedItem = item
                self.searchView.searchBar.text = item?.name
                self.searchView.mapView.removeAnnotations(self.searchView.mapView.annotations)
                if let item {
                    let coordinate = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = item.name
                    self.searchView.mapView.addAnnotation(annotation)
                    let region = MKCoordinateRegion(
                        center: coordinate,
                        latitudinalMeters: 500,
                        longitudinalMeters: 500
                    )
                    self.searchView.mapView.setRegion(region, animated: true)
                }
            })
            .disposed(by: disposeBag)

        output.errorMessage
            .emit(onNext: { [weak self] message in
                let alert = UIAlertController(title: AppStrings.Search.errorTitle, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: AppStrings.Common.confirm, style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)

        output.dismiss
            .emit(onNext: { [weak self] in self?.navigationController?.popViewController(animated: true) })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    @objc private func didTapSelect() {
        if let selectedItem {
            onLocationSelected?(selectedItem)
        }
        selectTapRelay.accept(())
    }
}

// MARK: - UISearchBarDelegate
extension LocationSearchViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextRelay.accept(searchText)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension LocationSearchViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentResults.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LocationSearchResultCell.reuseIdentifier,
            for: indexPath
        ) as? LocationSearchResultCell else {
            return UITableViewCell()
        }
        if indexPath.row < currentResults.count {
            cell.configure(item: currentResults[indexPath.row])
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchView.searchBar.resignFirstResponder()
        selectItemRelay.accept(indexPath.row)
    }
}

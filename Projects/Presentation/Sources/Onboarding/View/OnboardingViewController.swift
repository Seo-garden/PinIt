//
//  OnboardingViewController.swift
//  Presentation
//
//  Created by 김민우 on 3/12/26.
//

import UIKit
import SwiftUI
import RxSwift
import RxCocoa


// MARK: viewcontroller
@MainActor
public final class OnboardingViewController: UIViewController {
    // MARK: core
    private let viewModel: OnboardingViewModel
    private let disposeBag = DisposeBag()
    private var pageWidthConstraints: [NSLayoutConstraint] = []
    private var currentPageIndex = 0
    
    
    // MARK: view
    private let pagingScrollView = UIScrollView()
    private let pageStackView = UIStackView()
    private let pageControl = UIPageControl()
    private let nextButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system)
    
    
    // MARK: lifecycle
    public init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureStyle()
        configureLayout()
        bindActions()
        bindState()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task { [weak self] in
            guard let self else { return }
            
            guard self.viewModel.isContentFetched == false else { return }
            await self.viewModel.fetchContent()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCurrentPageIfNeeded()
    }
    
    
    // MARK: configure
    private func configureHierarchy() {
        view.addSubview(skipButton)
        view.addSubview(pagingScrollView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        
        pagingScrollView.addSubview(pageStackView)
    }
    
    private func configureStyle() {
        view.backgroundColor = UIColor(red: 245 / 255, green: 246 / 255, blue: 250 / 255, alpha: 1)
        
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.delegate = self
        pagingScrollView.contentInsetAdjustmentBehavior = .never
        
        pageStackView.axis = .horizontal
        pageStackView.alignment = .fill
        pageStackView.distribution = .fill
        pageStackView.spacing = 0
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = 0
        pageControl.currentPageIndicatorTintColor = UIColor(red: 24 / 255, green: 119 / 255, blue: 242 / 255, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor(white: 0.82, alpha: 1)
        pageControl.hidesForSinglePage = true
        
        var nextConfiguration = UIButton.Configuration.filled()
        nextConfiguration.title = "다음"
        nextConfiguration.baseBackgroundColor = UIColor(red: 24 / 255, green: 119 / 255, blue: 242 / 255, alpha: 1)
        nextConfiguration.baseForegroundColor = .white
        nextConfiguration.cornerStyle = .capsule
        nextConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 20)
        nextButton.configuration = nextConfiguration
        nextButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        
        var skipConfiguration = UIButton.Configuration.plain()
        skipConfiguration.title = "건너뛰기"
        skipConfiguration.baseForegroundColor = UIColor(white: 0.45, alpha: 1)
        skipButton.configuration = skipConfiguration
        skipButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
    }
    
    private func configureLayout() {
        [
            skipButton,
            pagingScrollView,
            pageStackView,
            pageControl,
            nextButton
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pagingScrollView.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 8),
            pagingScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            pageStackView.topAnchor.constraint(equalTo: pagingScrollView.contentLayoutGuide.topAnchor),
            pageStackView.leadingAnchor.constraint(equalTo: pagingScrollView.contentLayoutGuide.leadingAnchor),
            pageStackView.trailingAnchor.constraint(equalTo: pagingScrollView.contentLayoutGuide.trailingAnchor),
            pageStackView.bottomAnchor.constraint(equalTo: pagingScrollView.contentLayoutGuide.bottomAnchor),
            pageStackView.heightAnchor.constraint(equalTo: pagingScrollView.frameLayoutGuide.heightAnchor),
            
            pageControl.topAnchor.constraint(equalTo: pagingScrollView.bottomAnchor, constant: 16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 58),
            
            pagingScrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -16)
        ])
    }
    
    private func bindActions() {
        pageControl.rx.controlEvent(.valueChanged)
            .bind(with: self) { owner, _ in
                owner.scrollToPage(
                    index: owner.pageControl.currentPage, animated: true)
            }
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                guard owner.pageControl.numberOfPages > 0 else { return }
                
                if owner.currentPageIndex < owner.pageControl.numberOfPages - 1 {
                    owner.scrollToPage(
                        index: owner.currentPageIndex + 1,
                        animated: true
                    )
                }
            }
            .disposed(by: disposeBag)
        
        skipButton.rx.tap
            .bind(with: self) { owner, _ in
                guard owner.pageControl.numberOfPages > 0 else { return }
                owner.scrollToPage(
                    index: owner.pageControl.numberOfPages - 1,
                    animated: true
                )
            }
            .disposed(by: disposeBag)
    }
    
    private func bindState() {
        viewModel.$pageContents.driver
            .compactMap { $0 }
            .drive(with: self) { owner, content in
                owner.reloadPages()
            }
            .disposed(by: disposeBag)
    }
    
    
    // MARK: action
    private func reloadPages() {
        pageStackView.arrangedSubviews.forEach { arrangedSubview in
            pageStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        NSLayoutConstraint.deactivate(pageWidthConstraints)
        pageWidthConstraints.removeAll()
        
        let pageViews = self.viewModel.pageContents.enumerated().map(makePageView)
        pageViews.forEach { pageView in
            pageStackView.addArrangedSubview(pageView)
            let widthConstraint = pageView.widthAnchor.constraint(equalTo: pagingScrollView.frameLayoutGuide.widthAnchor)
            widthConstraint.isActive = true
            pageWidthConstraints.append(widthConstraint)
        }
        
        pageControl.numberOfPages = pageViews.count
        currentPageIndex = 0
        pageControl.currentPage = 0
        updateNextButtonTitle()
    }
    
    private func makePageView(index: Int, viewModel: OnboardingContent.Page) -> UIView {
        let containerView = UIView()
        let illustrationView = UIView()
        let symbolImageView = UIImageView()
        let headlineLabel = UILabel()
        
        [illustrationView, headlineLabel].forEach(containerView.addSubview)
        illustrationView.addSubview(symbolImageView)
        
        [containerView, illustrationView, symbolImageView, headlineLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        illustrationView.backgroundColor = UIColor(red: 24 / 255, green: 119 / 255, blue: 242 / 255, alpha: 1)
        illustrationView.layer.cornerRadius = 54
        illustrationView.layer.shadowColor = UIColor.systemBlue.cgColor
        illustrationView.layer.shadowOpacity = 0.16
        illustrationView.layer.shadowRadius = 18
        illustrationView.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        symbolImageView.image = UIImage(systemName: symbolName(for: index))
        symbolImageView.tintColor = .white
        symbolImageView.contentMode = .scaleAspectFit
        symbolImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 40, weight: .semibold)
        
        headlineLabel.text = viewModel.headline
        headlineLabel.numberOfLines = 0
        headlineLabel.textAlignment = .center
        headlineLabel.font = .systemFont(ofSize: 30, weight: .bold)
        headlineLabel.textColor = .black
        
        NSLayoutConstraint.activate([
            illustrationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            illustrationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -72),
            illustrationView.widthAnchor.constraint(equalToConstant: 108),
            illustrationView.heightAnchor.constraint(equalToConstant: 108),
            
            symbolImageView.centerXAnchor.constraint(equalTo: illustrationView.centerXAnchor),
            symbolImageView.centerYAnchor.constraint(equalTo: illustrationView.centerYAnchor),
            
            
            headlineLabel.topAnchor.constraint(equalTo: illustrationView.bottomAnchor, constant: 14),
            headlineLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            headlineLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32)
        ])
        
        return containerView
    }
    
    private func updateCurrentPageIfNeeded() {
        guard pagingScrollView.bounds.width > 0, pageControl.numberOfPages > 0 else { return }
        let index = Int(round(pagingScrollView.contentOffset.x / pagingScrollView.bounds.width))
        let clampedIndex = max(0, min(index, pageControl.numberOfPages - 1))
        
        guard currentPageIndex != clampedIndex else { return }
        currentPageIndex = clampedIndex
        pageControl.currentPage = clampedIndex
        updateNextButtonTitle()
    }
    
    private func updateNextButtonTitle() {
        var configuration = nextButton.configuration ?? .filled()
        configuration.title = currentPageIndex == max(pageControl.numberOfPages - 1, 0) ? "시작하기" : "다음"
        nextButton.configuration = configuration
    }
    
    private func scrollToPage(index: Int, animated: Bool) {
        guard pagingScrollView.bounds.width > 0 else { return }
        let targetOffset = CGPoint(x: pagingScrollView.bounds.width * CGFloat(index), y: 0)
        pagingScrollView.setContentOffset(targetOffset, animated: animated)
        currentPageIndex = index
        pageControl.currentPage = index
        updateNextButtonTitle()
    }
    
    private func symbolName(for index: Int) -> String {
        switch index {
        case 0:
            return "person.crop.circle.badge.checkmark"
        case 1:
            return "camera.aperture"
        case 2:
            return "location.magnifyingglass"
        case 3:
            return "map"
        default:
            return "sparkles"
        }
    }
}


// MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPageIfNeeded()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentPageIfNeeded()
    }
}


// MARK: preview
#Preview {
    OnboardingViewController(viewModel: .init())
}

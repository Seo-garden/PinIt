//
//  TabBarViewController.swift
//  Presentation
//
//  Created by 서정원 on 3/20/26.
//

import UIKit

public final class TabBarViewController: UITabBarController {
    private let createRecordViewController: CreateRecordViewController

    public init(
        mapViewController: MapViewController,
        feedViewController: FeedViewController,
        createRecordViewController: CreateRecordViewController
    ) {
        self.createRecordViewController = createRecordViewController
        super.init(nibName: nil, bundle: nil)

        let mapNav = UINavigationController(rootViewController: mapViewController)
        mapNav.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map"), tag: 0)
        
        let placeholderVC = UIViewController()
        placeholderVC.tabBarItem = UITabBarItem(title: "기록", image: UIImage(systemName: "plus.circle"), tag: 1)

        let feedNav = UINavigationController(rootViewController: feedViewController)
        feedNav.tabBarItem = UITabBarItem(title: "피드", image: UIImage(systemName: "list.bullet"), tag: 2)

        self.viewControllers = [mapNav, placeholderVC, feedNav]
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarViewController: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard viewController == viewControllers?[1] else { return true }
        let nav = UINavigationController(rootViewController: createRecordViewController)
        nav.view.backgroundColor = .systemBackground
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
        return false
    }
}

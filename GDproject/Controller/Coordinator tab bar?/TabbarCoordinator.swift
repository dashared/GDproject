import UIKit

class TabbarCoordinator{
    var window: UIWindow!
    static let tabBar: UITabBarController = UIStoryboard.tabBarController()
    
    // MARK: - Properties
    //private var user: Model.Users { didSet { updateInterfaces() } }
    
    func start(){
        window.rootViewController = TabbarCoordinator.tabBar
        TabbarCoordinator.tabBar.selectedIndex = 0
    }
    
    init(window: UIWindow) {
        self.window = window
    }
    
//    // MARK:- update only viewControllers which are depandable on chosen channel
//    private func updateInterfaces() {
//        TabbarCoordinator.tabBar.viewControllers?.forEach({
//            ($0 as? UpdateableWithUser)?.user = user
//        })
//    }
}

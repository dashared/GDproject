import UIKit

class TabbarCoordinator{
    var window: UIWindow!

    func start(){
        let tabbar = UIStoryboard.tabBarController()
        window.rootViewController = tabbar
    }
    
    init(window: UIWindow) {
        self.window = window
    }
}

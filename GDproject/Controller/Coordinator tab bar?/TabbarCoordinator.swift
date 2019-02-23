import UIKit

class TabbarCoordinator{
    var window: UIWindow!
    
    func start(){
        window.rootViewController = UIStoryboard.tabBarController()
    }
    
    init(window: UIWindow) {
        self.window = window
    }
}

/**********************************************************
* Klaus, A state-of-the-art Classifier on iOS
* Liu Liu, 2014-08-06
**********************************************************/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
  var window: UIWindow?

  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds);
    window?.rootViewController = KLViewController(nibName: nil, bundle: nil)
    window?.makeKeyAndVisible()
    return true
  }
}


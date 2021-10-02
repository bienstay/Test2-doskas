//
//  extensions.swift
//  Bibzzy
//
//  Created by maciulek on 27/04/2021.
//

import UIKit

extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int) {
        let redValue: CGFloat = CGFloat(red) / CGFloat(255.0)
        let greenValue: CGFloat = CGFloat(green) / 255.0
        let blueValue: CGFloat = CGFloat(blue) / 255.0
        self.init(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
    }

    convenience init(_ rgb: Int) {
        self.init((rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF)
    }

    static let darkGreen = UIColor(0, 128, 0)
    static let darkYellow = UIColor(128, 128, 0)

    static var pastelRedVeryLight: UIColor = UIColor(255, 224, 224)
    static var pastelRedLight: UIColor = UIColor(255, 196, 196)
    static var pastelRed: UIColor = UIColor(255, 128, 128)
    static var pastelGreenLight: UIColor = UIColor(196, 255, 196)
    static var pastelGreen: UIColor = UIColor(128, 255, 128)
    static var pastelBlueLight: UIColor = UIColor(196, 196, 255)
    static var pastelBlue: UIColor = UIColor(128, 128, 255)
    static var pastelYellowLight: UIColor = UIColor(255, 255, 196)
    static var pastelYellow: UIColor = UIColor(255, 255, 128)
    static var pastelCyanLight: UIColor = UIColor(196, 255, 255)
    static var pastelCyan: UIColor = UIColor(128, 255, 255)
    static var pastelCyanDark: UIColor = UIColor(64, 255, 255)
    static var pastelMagentaLight: UIColor = UIColor(255, 196, 255)
    static var pastelMagenta: UIColor = UIColor(255, 128, 255)
    static var pastelGrayLight: UIColor = UIColor(224, 224, 224)
    static var pastelGray: UIColor = UIColor(192, 192, 192)
    
    static var pastelVeryLightMalachiteGreen = UIColor(0x64E987)
    static var pastelLightGreen = UIColor(0x92F294)
    static var pastelDiamond = UIColor(0xC0F9FA)
    static var pastelLightSkyBlue = UIColor(0x88CEFB)
    static var pastelLightRed = UIColor(0xFCCCCC)
    static var pastelSalmonPink = UIColor(0xFF99A9)

    static let offWhite = UIColor(red: 225 / 255, green: 225 / 255, blue: 235 / 255, alpha: 1.0)
    static let offWhiteLight = UIColor(red: 235 / 255, green: 235 / 255, blue: 245 / 255, alpha: 1.0)
    static let offWhiteVeryLight = UIColor(red: 245 / 255, green: 245 / 255, blue: 250 / 255, alpha: 1.0)

    static var color1: UIColor = UIColor(0xF3BA91)
    static var color2: UIColor = UIColor(0x5BB993)
    static var color3: UIColor = UIColor(0xF3AC37)

    @available(iOS 13.0, *)
    static var pastelRedDN = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return pastelRed
        default:
            return pastelRedLight
        }
    }
    
    static var BBbackgroundColor: UIColor = .white
/*
    static var BBbackgroundColor: UIColor {
        if #available(iOS 13, *) {
            let c = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return .black
                    default:
                        return .white
                }
            }
            return c
        } else {
            return .white
        }
    }
*/
}

func NSLocalizedString(_ key:String) -> String {
    return NSLocalizedString(key, comment: key)
}


extension UIViewController {

    func setupNavigationBar(transparent: Bool = true, transluscent: Bool = true, largeTitles: Bool = true, hideOnSwipe: Bool = true, tintColor: UIColor = .white) {
        navigationController?.navigationBar.isTranslucent = transluscent
        navigationController?.navigationBar.prefersLargeTitles = largeTitles
        navigationController?.hidesBarsOnSwipe = hideOnSwipe
        navigationController?.navigationBar.tintColor = tintColor
        navigationItem.backButtonTitle = ""

        if #available(iOS 13, *) {
            if let appearance = navigationController?.navigationBar.standardAppearance {
                if transparent { appearance.configureWithTransparentBackground() }
                else { appearance.configureWithDefaultBackground() }
                if let customFont = UIFont(name: "Nunito-Bold", size: 45.0) {
                    appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
                }
                navigationController?.navigationBar.standardAppearance = appearance
                navigationController?.navigationBar.compactAppearance = appearance
                navigationController?.navigationBar.scrollEdgeAppearance = appearance
            }
        } else {
            if transparent {
                navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                navigationController?.navigationBar.shadowImage = UIImage()
                navigationController?.navigationBar.alpha = 0.0
            } else {
                navigationController?.navigationBar.barTintColor = nil
            }
        }
    }
}

func oldCustomizeNavigationBarAppearance(_ navigationController: UINavigationController?) {
    // Enable large title for navigation bar
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.hidesBarsOnSwipe = true
    navigationController?.navigationBar.tintColor = .white

    // Customize the navigation bar appearance
    if #available(iOS 13, *) {
        if let appearance = navigationController?.navigationBar.standardAppearance {
        
            appearance.configureWithTransparentBackground()

            if let customFont = UIFont(name: "Nunito-Bold", size: 45.0) {
                appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
            }

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    } else {
        //navigationController?.navigationBar.barTintColor = .clear
        //navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.alpha = 0.0
    }
}



extension UIViewController {
    func initView(tableView: UITableView? = nil) {

        view.backgroundColor = .BBbackgroundColor

        var tv = tableView
        if let tableViewController = self as? UITableViewController { tv = tableViewController.tableView }
        if tv != nil {
            tv!.separatorStyle = .none
            tv!.cellLayoutMarginsFollowReadableWidth = true
            tv!.backgroundColor = .BBbackgroundColor
        }

        navigationItem.backButtonTitle = ""
    }
}

// load json from a file in the bundle
func loadFromJSON<T>(fileNameNoExt: String) -> T where T: Decodable {
    var jsonString = ""
    if let filepath = Bundle.main.path(forResource: fileNameNoExt, ofType: "json") {
        do {
            jsonString = try String(contentsOfFile: filepath)
            //print(contents)
        } catch {
            print("Error: \(error)")
        }
    } else {
        print("File " + fileNameNoExt + " not found")
    }
    let data = try! JSONDecoder().decode(T.self, from: jsonString.data(using: .utf8)!)
    return data
}

// save json data to a file in the sandbox Documents folder
func saveJSONData<T>(from data:T, to fileNameNoExt: String) where T: Encodable {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonData = try! encoder.encode(data)

    let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let fileURL = URL(fileURLWithPath: fileNameNoExt, relativeTo: directoryURL).appendingPathExtension("json")
    
    do {
        print("Writing to " + fileURL.absoluteString)
        try jsonData.write(to: fileURL)
    } catch {
        print(error)
    }
}

func setOrderButton(orderButton: UIButton) {
    orderButton.layer.cornerRadius = 50
    orderButton.backgroundColor = .pastelRed
    orderButton.titleLabel?.textAlignment = .center
    orderButton.isHidden = true

    orderButton.backgroundColor = .pastelRed            //UIColor(named: "buttonBackground")
    orderButton.layer.cornerRadius = 15
    orderButton.layer.shadowColor = UIColor.pastelRedLight.cgColor     // UIColor(named: "buttonShadow")?.cgColor
    orderButton.layer.shadowOpacity = 0.8
    orderButton.layer.shadowOffset = CGSize(width: 3, height: 3)
    orderButton.layer.borderWidth = 2
    orderButton.layer.borderColor = UIColor.black.cgColor    //UIColor(named: "buttonBorder")?.cgColor
}

func prepareNotification(id: String, title: String, subtitle:String, body: String, attachmentFile: String, userInfo: [AnyHashable: Any]? = nil) {
    // Create the user notification
    let content = UNMutableNotificationContent()
    content.title = title
    content.subtitle = subtitle
    content.body = body
    content.sound = UNNotificationSound.default
    if let bundlePath = Bundle.main.path(forResource: attachmentFile, ofType: "png") {
        if let orderImage = try? UNNotificationAttachment(identifier: "orderImage", url: URL(fileURLWithPath: bundlePath), options: nil) {
            content.attachments = [orderImage]
        }
    }
    if let userInfo = userInfo { content.userInfo = userInfo } // Array of custom

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    // Schedule the notification

    UNUserNotificationCenter.current().add(request) { error in
        if let err = error { print(err.localizedDescription) }
    }
}

extension UITabBar {
    static func setTransparentTabbar() {
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().clipsToBounds = true
    }
}



func generateRandomColors() -> [[UIColor]] {
    let numberOfRows = 20
    let numberOfItemsPerRow = 15

    return (0..<numberOfRows).map { _ in
        return (0..<numberOfItemsPerRow).map { _ in UIColor.randomColor() }
    }
}

extension UIColor {
    
    class func randomColor() -> UIColor {

        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}


extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}


extension UIImage {
    func scaleTo(newWidth: CGFloat) -> UIImage {
        // Make sure the given width is different from the existing one
        if self.size.width == newWidth {
            return self
        }
        // Calculate the scaling factor
        let scaleFactor = newWidth / self.size.width
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}


extension Date {
    func formatFull() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy-MM-dd HH:mm:ss^SSS"
        return formatter3.string(from: self)
    }
    func formatForSort() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter3.string(from: self)
    }
    func formatFriendly() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "EEEE, MMM d HH:mm"
        return formatter3.string(from: self)
    }
    func formatShort() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "MMM dd, HH:mm:ss"
        return formatter3.string(from: self)
    }
}

extension Notification.Name {
    static let hotelInfoUpdated = Notification.Name("hotelInfoUpdated")
    static let ordersUpdated = Notification.Name("ordersUpdated")
    static let newsUpdated = Notification.Name("newsUpdated")
    static let restaurantsUpdated = Notification.Name("restarantsUpdated")
    static let menusUpdated = Notification.Name("menusUpdated")
    static let chatRoomsUpdated = Notification.Name("chatRoomsUpdated")
    static let chatMessagesUpdated = Notification.Name("chatMessagesUpdated")
    static let guestUpdated = Notification.Name("guestUpdated")
}


class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}


func showInfoDialogBox(vc: UIViewController, title:String, message: String, completion: (() -> Void)? = nil) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alertController.addAction(OKAction)
    vc.present(alertController, animated: true, completion:completion)
}

extension UIViewController {
    func pushOrPresent(viewController vc: UIViewController) {
        if let nc = self.navigationController {
            nc.pushViewController(vc, animated: true)
        }
        else {
            vc.modalPresentationStyle = .formSheet
            self.present(vc, animated: true, completion: nil)
        }
    }

    func pushOrPresent(storyBoard: String, id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyBoard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        pushOrPresent(viewController: vc)
        return vc
    }

    func pushViewController(storyBoard: String, id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyBoard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        self.navigationController?.pushViewController(vc, animated: true)
        return vc
    }

    func pushModal(storyBoard: String, id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyBoard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true, completion: nil)
        return vc
    }
    
    func createViewController(storyBoard: String, id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyBoard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        vc.modalPresentationStyle = .formSheet
        return vc
    }
}

extension UITableView {
    func scrollToBottom() {
        guard self.numberOfSections > 0 else { return }
        DispatchQueue.main.async {
            let section = self.numberOfSections-1
            let row = self.numberOfRows(inSection: section) - 1
            if row >= 0 {
                let indexPath = IndexPath(row: row, section: section)
                self.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}

extension UIViewController {
    func embed(viewController:UIViewController, inView view:UIView) {
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var hex: Int {
        let red = UInt(coreImageColor.red * 255 + 0.5)
        let green = UInt(coreImageColor.green * 255 + 0.5)
        let blue = UInt(coreImageColor.blue * 255 + 0.5)
        return Int( (red << 16) | (green << 8) | blue )
    }
}

func createBarButtonItem(target: Any?, action: Selector) -> UIBarButtonItem {
    let profileButton = UIButton()
    profileButton.frame = CGRect(x:0, y:0, width:80, height:40)
    profileButton.backgroundColor = UIColor.gray
    profileButton.layer.cornerRadius = 10.0
    profileButton.addTarget(target, action: action, for: .touchUpInside)

    let barButton = UIBarButtonItem(customView: profileButton)
    return barButton
}

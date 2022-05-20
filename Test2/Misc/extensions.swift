//
//  extensions.swift
//  Bibzzy
//
//  Created by maciulek on 27/04/2021.
//

import UIKit
import PhotosUI

// MARK: - UIColor
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
    static let darkGreenWithBlue = UIColor(0, 104, 55)
    static let darkYellow = UIColor(128, 128, 0)

    static var pastelRedVeryLight: UIColor = UIColor(255, 224, 224)
    static var pastelRedLight: UIColor = UIColor(255, 196, 196)
    static var pastelRed: UIColor = UIColor(255, 128, 128)
    static var pastelGreenLight: UIColor = UIColor(196, 255, 196)
    static var pastelGreen: UIColor = UIColor(128, 255, 128)
    static var pastelBlueLight: UIColor = UIColor(196, 196, 255)
    static var pastelBlue: UIColor = UIColor(128, 128, 255)
    static var pastelYellowLight: UIColor = UIColor(255, 255, 196)
    static var pastelYellowVeryLight: UIColor = UIColor(255, 255, 224)
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

    //static var BBbackgroundColor: UIColor = .offWhite

    static var BBbackgroundColor: UIColor {
        if #available(iOS 13, *) {
            let c = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return .black
                    default:
                    return .offWhite
                }
            }
            return c
        } else {
            return .offWhite
        }
    }

    static var BBcellColor: UIColor {
        if #available(iOS 13, *) {
            let c = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return .darkGray
                    default:
                    return .offWhiteVeryLight
                }
            }
            return c
        } else {
            return .offWhiteVeryLight
        }
    }

    static var BBreversedCellColor: UIColor {
        if #available(iOS 13, *) {
            let c = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return .offWhiteVeryLight
                    default:
                        return .darkGray
                }
            }
            return c
        } else {
            return .darkGray
        }
    }

    static var BBtextColor: UIColor {
        if #available(iOS 13, *) {
            let c = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return .white
                    default:
                        return .black
                }
            }
            return c
        } else {
            return .black
        }
    }

    static var BBreversedTextColor: UIColor {
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

    static var BBseparatorColor: UIColor {
        if #available(iOS 13, *) {
            let c = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return UIColor(192, 192, 192)
                    default:
                        return UITableView().separatorColor ?? .gray
                }
            }
            return c
        } else {
            return UITableView().separatorColor ?? .gray
        }
    }

    class func randomColor() -> UIColor {

        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100

        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
}

// MARK: - NSLocalizedString
func NSLocalizedString(_ key:String) -> String {
    return NSLocalizedString(key, comment: key)
}

// MARK: - UIViewController: navigation bars
extension UIViewController {

    func setupTransparentNavigationBar(tableView: UITableView? = nil, collectionView: UICollectionView? = nil, tintColor: UIColor = .white)
    {
        if let t = tableView { t.contentInsetAdjustmentBehavior = .never }   // hides the navigationbar
        navigationController?.hidesBarsOnSwipe = false  // do not hide the back arrow when swiped
        navigationController?.navigationBar.tintColor = tintColor

        // setup fully transparent bar
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.isTranslucent = true
    }

    func endTransparentNavigationBar() {
        navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController!.navigationBar.shadowImage = nil
        navigationController!.navigationBar.isTranslucent = true
    }

    func setupListNavigationBar(tintColor: UIColor = .BBtextColor, largeTitle: Bool = true, title: String? = nil) {
        navigationItem.backButtonTitle = ""
        if let t = title { navigationItem.title = t }
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.prefersLargeTitles = largeTitle
        navigationController?.navigationBar.tintColor = tintColor
    }

}

// MARK: - UIViewController: init
extension UIViewController {
    func initView(tableView: UITableView? = nil, collectionView: UICollectionView? = nil, allowsSelection: Bool = true) {

        view.backgroundColor = .BBbackgroundColor

        var tv = tableView
        if let tableViewController = self as? UITableViewController { tv = tableViewController.tableView }
        if tv != nil {
            tv!.allowsSelection = allowsSelection
            tv!.separatorStyle = .none
            tv!.showsVerticalScrollIndicator = false
            tv!.cellLayoutMarginsFollowReadableWidth = true
            tv!.backgroundColor = .BBbackgroundColor
        }

        var cv = collectionView
        if let collectionViewController = self as? UICollectionViewController { cv = collectionViewController.collectionView }
        if cv != nil {
            cv!.backgroundColor = .BBbackgroundColor
        }

        navigationItem.backButtonTitle = ""
    }

}

// MARK: - JSON
// load json from a file in the bundle
func loadFromJSON<T>(fileNameNoExt: String) -> T where T: Decodable {
    var jsonString = ""
    if let filepath = Bundle.main.path(forResource: fileNameNoExt, ofType: "json") {
        do {
            jsonString = try String(contentsOfFile: filepath)
        } catch {
            Log.log("Error: \(error)")
        }
    } else {
        Log.log("File " + fileNameNoExt + " not found")
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
        Log.log(level: .INFO, "Writing to " + fileURL.absoluteString)
        try jsonData.write(to: fileURL)
    } catch {
        Log.log(level: .ERROR, "\(error)")
    }
}
/*
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
*/

/*
extension UITabBar {
    static func setTransparentTabbar() {
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().clipsToBounds = true
    }
}
*/

// MARK: - String
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


// MARK: - UIImage
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


// MARK: - Date
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
    func formatForDisplay() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "EEEE, MMM d HH:mm"
        return formatter3.string(from: self)
    }
    func formatShort() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "MMM dd, HH:mm:ss"
        return formatter3.string(from: self)
    }
    func formatForDB() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyyMMdd-HHmmss"
        return formatter3.string(from: self)
    }
    func formatTimeShort() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "HH:mm"
        return formatter3.string(from: self)
    }
}

// MARK: - Notifications
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
        if let err = error { Log.log(level: .ERROR, "\(err)") }
    }
}

extension Notification.Name {
    static let dbProxyReady = Notification.Name("dbProxyReady")

    static let hotelInfoUpdated = Notification.Name("hotelInfoUpdated")
    static let ordersUpdated = Notification.Name("ordersUpdated")
    static let offersUpdated = Notification.Name("offersUpdated")
    static let newsUpdated = Notification.Name("newsUpdated")
    static let activitiesUpdated = Notification.Name("activitiesUpdated")
    static let restaurantsUpdated = Notification.Name("restarantsUpdated")
    static let facilitiesUpdated = Notification.Name("facilitiesUpdated")
    static let menusUpdated = Notification.Name("menusUpdated")
    static let chatRoomsUpdated = Notification.Name("chatRoomsUpdated")
    static let chatMessageAdded = Notification.Name("chatMessagesAdded")
    static let chatMessageDeleted = Notification.Name("chatMessagesDeleted")
    static let chatMessageUpdated = Notification.Name("chatMessagesUpdated")
    //static let chatMessageCountUpdated = Notification.Name("chatMessageCountUpdated")
    static let guestUpdated = Notification.Name("guestUpdated")
    static let likesUpdated = Notification.Name("likesUpdated")
    static let connectionStatusUpdated = Notification.Name("connectionStatusUpdated")
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

/*
func showInfoDialogBox(vc: UIViewController, title:String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "Ok", style: .default, handler: completion)
    alertController.addAction(OKAction)
    vc.present(alertController, animated: true, completion: nil)
}
*/


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

    func presentModal(storyBoard: String, id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyBoard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        //vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true, completion: nil)
        return vc
    }
    
    func createViewController(storyBoard: String, id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyBoard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        vc.modalPresentationStyle = .formSheet
        return vc
    }

    func showInfoDialogBox(title:String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ok", style: .default, handler: completion)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }

    // completion called if Yes pressed
    func showConfirmDialogBox(title:String, message: String, completion: @escaping (() -> Void)) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: .yes, style: .default) { _ in
            completion()
        }
        let cancelAction = UIAlertAction(title: .no, style: .cancel) { _ in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
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

struct Log {
    enum LogLevel: Int {
        case FATAL = 0
        case ERROR
        case INFO
        case DEBUG
    }
    static var currentLevel: LogLevel = .INFO
    static var logInDB: Bool = true
    static func log(level: LogLevel = .INFO, _ message: String, logInDb: Bool = true, function: String = #function, file: String = #file, line: Int = #line) {
        if level.rawValue <= currentLevel.rawValue {
            let url = NSURL(fileURLWithPath: file)
            let name = (url.lastPathComponent ?? file).components(separatedBy: ".")[0]
            print("[\(name):\(line)] " + message)
            if self.logInDB && logInDb { dbProxy?.log(level: level, s: message) }
        }
    }
}



extension UIViewController  {

    func showPicturePicker(vc: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate) {
        let photoSourceRequestController = UIAlertController(title: "", message: NSLocalizedString("Choose your photo source", comment: "Choose your photo source"), preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.delegate = vc
                vc.present(imagePicker, animated: true, completion: nil)
            }
        })
        photoSourceRequestController.addAction(cameraAction)
/*
        if #available(iOS 14, *) {
            let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo library", comment: "Photo library"), style: .default, handler: { (action) in
                var config = PHPickerConfiguration()
                config.filter = .images
                config.selectionLimit = 1
                config.preferredAssetRepresentationMode = .current
                let controller = PHPickerViewController(configuration: config)
                vc.present(controller, animated: true, completion: nil)
            })
            photoSourceRequestController.addAction(photoLibraryAction)
        }
        else {
*/
            let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo library", comment: "Photo library"), style: .default, handler: { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    //imagePicker.sourceType = .savedPhotosAlbum
                    imagePicker.delegate = vc
                    vc.present(imagePicker, animated: true, completion: nil)
                }
            })
            photoSourceRequestController.addAction(photoLibraryAction)
//        }
        
        // For iPad
        if let popoverController = photoSourceRequestController.popoverPresentationController {
            popoverController.sourceView = vc.view
            popoverController.sourceRect = vc.view.bounds
        }

        vc.present(photoSourceRequestController, animated: true, completion: nil)
    }
}


extension String {
    func height(width: CGFloat, font: UIFont) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()
        return label.frame.height
    }
}

extension UICollectionView {
    func getCellIndex(_ view: UIView) -> IndexPath? {
        var superview = view.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UICollectionViewCell else {
            Log.log(level: .ERROR, "view is not contained in a collection view cell")
            return nil
        }
        guard let indexPath = self.indexPath(for: cell) else {
            Log.log(level: .ERROR, "failed to get index path for cell containing button")
            return nil
        }
        // We've got the index path for the cell that contains the button, now do something with it.
        return indexPath
    }
}

extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if let u = URL(string: url) {
                if application.canOpenURL(u) {
                    if #available(iOS 10.0, *) {
                        application.open(URL(string: url)!, options: [:], completionHandler: nil)
                    }
                    else {
                        application.openURL(URL(string: url)!)
                    }
                    return
                }
            }
        }
    }
}


func convertJSONStringToDictionary(text: String) -> [String:AnyObject]? {
    if let data = text.data(using: .utf8) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
            return json
        } catch {
            Log.log(level: .ERROR, "Error converting string to dictionary: \(text)")
        }
    }
    return nil
}

func convertObjectToDictionary<T:Codable>(t: T) -> [String:Any]? {
    if let data = try? JSONEncoder().encode(t), let json = try? JSONSerialization.jsonObject(with: data) as? [String:AnyObject] {
        return json
    } else {
        Log.log(level: .ERROR, "Error converting object to dictionary: \(t)")
        return nil
    }
}

//func parseJSON<T:Codable>(data: Data) -> T? {
func parseJSON<T:Codable>(_ jsonString: String) -> T? {
    var returnValue: T?
    let data = Data(jsonString.utf8)
    do {
        returnValue = try JSONDecoder().decode(T.self, from: data)
    } catch {
        Log.log(level: .ERROR, "Error in parseJSON: \(error.localizedDescription)")
    }

    return returnValue
}

extension DateFormatter {
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy HH:mm"
    return formatter
  }()
}

class MyJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        dateDecodingStrategy = .formatted(.dateFormatter)
    }
}

class MyJSONEncoder: JSONEncoder {
    override init() {
        super.init()
        dateEncodingStrategy = .formatted(.dateFormatter)
    }
}


extension UIImagePickerControllerDelegate where Self: UINavigationControllerDelegate {
//extension UIViewController where Self: UIImagePickerControllerDelegate { //}& UINavigationControllerDelegate {
    func showImagePicker(nc: UIViewController) {
        let alertStyle:UIAlertController.Style = (UIDevice.current.userInterfaceIdiom == .pad) ?
            .alert : .actionSheet
        let photoSourceRequestController = UIAlertController(title: "", message: NSLocalizedString("Choose your photo source", comment: "Choose your photo source"), preferredStyle: alertStyle)
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                nc.present(imagePicker, animated: true, completion: nil)
            }
        })
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo library", comment: "Photo library"), style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
//                    imagePicker.sourceType = .savedPhotosAlbum
                imagePicker.delegate = self
                nc.present(imagePicker, animated: true, completion: nil)
            }
        })
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
/* did the alertStyle instead
        // For iPad
        if let popoverController = photoSourceRequestController.popoverPresentationController {
            popoverController.sourceView = nc.view
            popoverController.sourceRect = nc.view.bounds
        }
*/
        nc.present(photoSourceRequestController, animated: true, completion: nil)

    }
}

/*
extension UIViewController {
    
    func startSpinner(vc: SpinnerViewController) {
        addChild(vc)
        vc.view.frame = view.frame
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    func stopSpinner(vc: SpinnerViewController) {
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }

    func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
}
*/

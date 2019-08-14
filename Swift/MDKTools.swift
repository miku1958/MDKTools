//
// MDKTools.swift
// MDKImageCollection
//
// Created by mikun on 2018/7/10.
// Copyright © 2018 mdk. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import Foundation
import ObjectiveC.runtime
#endif
#if canImport(Foundation)
import Foundation
import ObjectiveC.runtime
#endif

#if canImport(UIKit)

//MARK: 	根界面相关

///返回程序主窗口
public var MDKKeywindow: UIWindow {
	return UIApplication.shared.delegate!.window!!
}

///获取真正的rootViewController
public var MDKRootViewController: UIViewController {
	var rootCtr = MDKKeywindow.rootViewController;

	var presented = rootCtr?.presentedViewController;

	while presented != nil {
		rootCtr = presented
		presented = rootCtr?.presentedViewController
	}

	while (rootCtr?.isKind(of: UINavigationController.self))! {
		rootCtr = (rootCtr as! UINavigationController).topViewController
	}

	return rootCtr!;
}

///获取最顶部的NavgationController
public var MDKTopNavController: UINavigationController? {

	var nav = MDKRootViewController;
	var lastNav: UINavigationController? = MDKRootViewController.navigationController;
	while (true) {
		if nav.isKind(of: UINavigationController.self) {
			lastNav = nav as? UINavigationController;
		}

		if (nav.presentedViewController != nil) {
			while (nav.presentedViewController != nil) {
				nav = nav.presentedViewController!;
			}
		} else if nav.isKind(of: UITabBarController.self) {
			let tab = nav as! UITabBarController;
			if tab.selectedViewController == nil {
				break
			}
			nav = tab.selectedViewController!;
		} else if !nav.isKind(of: UINavigationController.self) && (nav.navigationController != nil) {
			if (lastNav == nav.navigationController) {
				break;
			}
			nav = nav.navigationController!;
		} else if nav.isKind(of: UINavigationController.self) {
			if (nav as! UINavigationController).viewControllers.count == 0 {
				break
			}
			nav = (nav as! UINavigationController).viewControllers.last!;
		} else {
			break;
		}
	}

	if nav.isKind(of: UINavigationController.self) {
		return (nav as! UINavigationController);
	} else {
		return lastNav
	}
}


//MARK: 	iOS设备版本相关

///获取的IOS版本
public var MDKiOS_version: Double {
	return Double(UIDevice.current.systemVersion) ?? 0
}


///判断获取的IOS版本是否大于 ver
@inline(__always) public func MDKiOSUp(ver: Double) -> Bool {
	return MDKiOS_version >= ver
}


///判断获取的IOS版本是否小于 ver
@inline(__always) public func MDKiOSDown(ver: Double) -> Bool {
	return MDKiOS_version < ver
}

//MARK: 	屏幕尺寸相关

///返回屏幕宽度
public var MDKScreenWidth: CGFloat {
	return UIScreen.main.bounds.size.width
}
///返回屏幕高度
public var MDKScreenHeight: CGFloat {
	return UIScreen.main.bounds.size.height
}


///iPhoneX上下元素内增的高度
public var MDKiPhoneXInset: CGFloat {
	return (MDKScreenHeight >= 768) ? 24: 0
}


///通过storyboard的名字获取它的instantiateInitialViewController, bundle为nil
@inline(__always) public func MDKSBInitial2VCWith(_ SBName: String) -> UIViewController {
	return UIStoryboard(name: SBName, bundle: nil).instantiateInitialViewController()!;
}
//MARK: 	颜色相关
///获得RGBA颜色
@inline(__always) public func MDKColor(_ red: Double, _ green: Double, _ blue: Double, withAlpha alpha: Double) -> UIColor {
	if MDKiOS_Machine_Type == .iPhone, MDKiOS_MachineModel > 9, #available(iOS 10.0, *) {
		return UIColor(displayP3Red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: CGFloat(alpha))
	}
	return UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: CGFloat(alpha))
}


///获得RGB颜色
@inline(__always) public func MDKColor(_ red: Double, _ green: Double, _ blue: Double) -> UIColor {
	return MDKColor(red, green, blue, withAlpha: 1.0);
}

///16进制转换RGB
@inline(__always) public func MDKColorFrom(Hex intValue: UInt) -> UIColor {
	if (intValue>0xFFFFFF) {
		return MDKColor((Double((intValue & 0xFF000000) >> 32)), Double((intValue & 0xFF0000) >> 16), Double((intValue & 0xFF00) >> 8), withAlpha: Double(intValue & 0xFF))
	} else {
		return MDKColor((Double((intValue & 0xFF0000) >> 16)), Double((intValue & 0xFF00) >> 8), Double(intValue & 0xFF))
	}
}

///16进制转换RGBA2.0, 单独设置alpha
@inline(__always) public func MDKColorFrom(Hex intValue: UInt, setAlpha alpha: Double) -> UIColor {
	return MDKColor((Double((intValue & 0xFF0000) >> 16)), Double((intValue & 0xFF00) >> 8), Double(intValue & 0xFF), withAlpha: alpha)
}
extension String {
	subscript (range: CountableClosedRange<Int>) -> String {
		if range.isEmpty { return "" }
		let start = self.index(self.startIndex, offsetBy: range.lowerBound)
		let end = self.index(self.startIndex, offsetBy: range.upperBound)
		return String(self[start ... end])
	}
	subscript (range: CountableRange<Int>) -> String {
		if range.isEmpty { return "" }
		let start = self.index(self.startIndex, offsetBy: range.lowerBound)
		let end = self.index(self.startIndex, offsetBy: range.upperBound)
		return String(self[start ..< end])
	}

	public func sub(to index: Int) -> String {
		return String(self[..<self.index(self.startIndex, offsetBy: index)])
	}

	public func sub(from index: Int) -> String {
		return String(self[self.index(self.startIndex, offsetBy: index)...])
	}

}
///16进制字符串转换RGB
func MDKColorFrom(Hex hexString: String) -> UIColor {
	var cleanString = hexString.replacingOccurrences(of: "#", with: "")
	cleanString = cleanString.trimmingCharacters(in: CharacterSet.whitespaces)

	if cleanString.count == 3 {
		cleanString = "\(cleanString[0..<1])\(cleanString[0..<1])\(cleanString[1..<2])\(cleanString[1..<2])\(cleanString[2..<3])\(cleanString[2..<3])"
	}

	var intValue: UInt32 = 0
	Scanner(string: cleanString).scanHexInt32(&intValue)


	return MDKColorFrom(Hex: UInt(intValue));
}

///不透明, 相同颜色
@inline(__always) public func MDKSameColor(_ same: Double) -> UIColor {
	return MDKColor(same, same, same)
}

///设置透明, 相同颜色
@inline(__always) public func MDKSameColor(_ same: Double, alpha: Double) -> UIColor {
	return MDKColor(same, same, same, withAlpha: alpha)
}

//创建随机色
public var MDKRandomColor: UIColor {
	return MDKColor(Double(arc4random_uniform(256)), Double(arc4random_uniform(256)), Double(arc4random_uniform(256)))
}


///从NSBundle加载Nib数组
@inline(__always) public func MDKLoadXibArr(nibNamed: String, owner: Any?, option: [UINib.OptionsKey: Any]?) -> [UIView] {
	return Bundle.main.loadNibNamed(nibNamed, owner: owner, options: option) as! [UIView]
}

//MARK: 	MDKAttString begin
public protocol MDKAStringDictionaryKeyable: Hashable {}
public protocol MDKAStringDictionaryValuable: Hashable {}
public protocol MDKAStringParable {}

extension String: MDKAStringParable, MDKAStringDictionaryKeyable {}
extension NSString: MDKAStringParable, MDKAStringDictionaryKeyable {}
extension UIImage: MDKAStringParable, MDKAStringDictionaryKeyable {}
extension NSAttributedString: MDKAStringParable, MDKAStringDictionaryKeyable {}

extension Dictionary: MDKAStringDictionaryValuable where Key == NSAttributedString.Key, Value: Hashable {}
extension Dictionary: MDKAStringParable where Key: MDKAStringDictionaryKeyable, Value: MDKAStringDictionaryValuable {}

extension CGRect: MDKAStringDictionaryValuable {
	public var hashValue: Int {
		var hasher = Hasher()
		hash(into: &hasher)
		return hasher.finalize()
	}
	public func hash(into hasher: inout Hasher) {
		hasher.combine(origin.x)
		hasher.combine(origin.y)
		hasher.combine(size.width)
		hasher.combine(size.height)
	}
}


/*
📖MDKAStringParable允许传的类型:
[MDKAStringDictionaryKeyable: MDKAStringDictionaryValuable](具体类型看下面)

📖MDKAStringDictionaryKeyable允许传的类型:
NSAttributedString, String, NSString, UIImage

📖当MDKAStringDictionaryKeyable为String, NSString时, 字符串属性MDKAStringDictionaryValuable传入:
[NSAttributedString.Key: AnyHashable]
✒️比方: MDKAttString([“我”: [.font: UIFont()]], [“不要”: [.foregroundColor: UIColor.red]])


当MDKAStringDictionaryKeyable为UIImage时, 图片属性MDKAStringDictionaryValuable传入: CGRect
✒️比方: MDKAttString([“我”: [.font: UIFont()]], [#imageLiteral(resourceName: ❤️): CGRect], [“你”: [.foregroundColor: UIColor.red]])

📖由于swift编译器的限制(不能把[: ]当成[MDKAStringDictionaryKeyable: MDKAStringDictionaryValuable]处理...). 所以这里改成: 如果NSAttributedString, String, NSString, UIImage不需要后面的属性, 可以直接把MDKAStringDictionaryKeyable作为MDKAStringParable直接传就行, 之后String 会拿commonAttribute作为属性来处理的
✒️比方: MDKAttString(“我”, #imageLiteral(resourceName: ❤️), “你”, commonAttribute: [...])
 
 📖由于swift中Any不能被extension, 所以原本的Attributes类型
 	[NSAttributedString.Key: Any]
 需要写成
 	[NSAttributedString.Key: AnyHashable]
 或者用
 	MDKAttributes
*/
public typealias MDKAttributes = [NSAttributedString.Key: AnyHashable]
public func MDKAttString(_ paras: MDKAStringParable..., commonAttribute: MDKAttributes = [: ]) -> NSAttributedString {
	
	let attStr = NSMutableAttributedString(string: "")
	
	for para in paras {
		if let para = para as? [AnyHashable: AnyHashable] {
			for (key, obj) in para {
				if let str = key as? NSAttributedString, var atts = obj as? MDKAttributes {
					let strm = NSMutableAttributedString(attributedString: str)
					
					atts.merge(commonAttribute) { (obj1, _) in obj1 }
					strm.setAttributes(atts, range: NSRange(location: 0, length: strm.length))
					attStr.append(strm)
				} else if let str = key as? String, var atts = obj as? MDKAttributes {
					atts.merge(commonAttribute) { (obj1, _) in obj1 }
					attStr.append(NSAttributedString(string: str, attributes: atts))
				} else if let image = key as? UIImage {
					let place = "\u{FFFC} "
					
					let atr = NSMutableAttributedString(string: place)
					
					let attach = NSTextAttachment()
					attach.image = image
					
					var bounds = CGRect(origin: CGPoint(x: 0, y: -2), size: image.size)
					if let targetBounds = obj as? CGRect, targetBounds != .zero {
						bounds = targetBounds
					}
					
					attach.bounds = bounds
					atr.setAttributes([.attachment: attach], range: NSRange(location: 0, length: atr.length))
					attStr.append(atr)
				}
			}
		} else {
			if let para = para as? NSAttributedString {
				attStr.append(MDKAttString([para: commonAttribute]))
			}
			if let para = para as? String {
				attStr.append(MDKAttString([para: commonAttribute]))
			}
			if let para = para as? UIImage {
				attStr.append(MDKAttString([para: commonAttribute]))
			}
		}
		
	}
	
	return attStr
}
//MARK: 	MDKAttString end

///改变状态栏颜色
@inline(__always) public func MDKChangeStatusBarBackgroundColor(color: UIColor) -> () {
	if
		let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIView,
		let statusBar = statusBarWindow.value(forKey: "statusBar") as? UIView,
		statusBar.isKind(of: UIView.self)
	 {
		statusBar.backgroundColor = color
	}

}
#endif

#if canImport(Foundation)

public enum MDKiOSMachineType {
	case Unknow
	case iPhone
	case iPad
	case Simulator
}


public var __iOS_MachineModel: Double = 0;
public var __iOS_MachineType: MDKiOSMachineType = .Unknow;

public var MDKiOS_MachineModel: Double {
	if (__iOS_MachineModel < 1) {
		creat_iOS_info();
	}
	return __iOS_MachineModel;
}

public var MDKiOS_Machine_Type: MDKiOSMachineType {
	if (__iOS_MachineType == .Unknow) {
		creat_iOS_info();
	}
	return __iOS_MachineType;
}


func creat_iOS_info()->() {
	
	var len: size_t = 0;
	let key = "hw.machine"
	
	let ret = sysctlbyname(key, nil, &len, nil, 0)
	
	guard ret == 0 else { return }
	
	var p = [CChar](repeating: 0, count: Int(len))
	sysctlbyname(key, &p, &len, nil, 0);

	
	var platform = String(cString: p)
	platform = platform.replacingOccurrences(of: ", ", with: ".")

	if platform.contains("iPhone") {
		__iOS_MachineType = .iPhone;
		platform = platform.replacingOccurrences(of: "iPhone", with: "")
	}

	if platform.contains("iPad") {
		__iOS_MachineType = .iPad;
		platform = platform.replacingOccurrences(of: "iPad", with: "")
	}

	if platform.contains("i386") {
		__iOS_MachineType = .Simulator;
		platform = platform.replacingOccurrences(of: "i386", with: "")
	}

	if platform.contains("x86_64") {
		__iOS_MachineType = .Simulator;
		platform = platform.replacingOccurrences(of: "x86_64", with: "")
	}

	if (platform.count > 0) {
		__iOS_MachineModel = Double(platform) ?? 0;
	}

}

//MARK: 	角度制 弧度制相关

///角度制转弧度制
@inline(__always) public func MDKAngleToRadian(_ angle: Double) -> Double {
	return angle / 180.0 * Double.pi;
}

//MARK: 	URL相关
///用NSString返回一个URL
@inline(__always) public func MDKURL(_ unUTF8str: String) -> URL {
	return URL(string: unUTF8str) ?? URL(string: "")!
}

///用NSString返回一个转换了含有非英文字符的URL
@inline(__always) public func MDKURL(Encoding unUTF8str: String) -> URL {
	if let UTF8str = unUTF8str.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
		return MDKURL(UTF8str)
	} else {
		return MDKURL(unUTF8str)
	}
}

///用NSString返回一个转换了含有非英文字符的URLRequest
@inline(__always) public func MDKURLRequest(_ unUTF8str: String) -> URLRequest {
	return URLRequest(url: MDKURL(unUTF8str))
}

///用NSString返回一个转换了含有非英文字符的URLRequest
@inline(__always) public func MDKURLRequest(Encoding unUTF8str: String) -> URLRequest {
	return URLRequest(url: MDKURL(Encoding: unUTF8str))
}


//MARK: 	CGSize相关
extension CGSize {
	///CGSize的最大尺寸
	var greatestFiniteMagnitude: CGSize {
		return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
	}
}


//MARK: 	沙盒目录相关

///输入文件名(NSString)，返回Temporary目录下的文件路径(NSString)
@inline(__always) public func MDKFileTempWith(_ tempFileName: String) -> String {
	return MDKURL(NSTemporaryDirectory()).appendingPathComponent(tempFileName).absoluteString
}

///输入文件名(NSString)，返回library/Cache目录下的文件路径(NSString)
@inline(__always) public func MDKFileCacheWith(_ cacheFileName: String) -> String {
	return MDKURL(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last ?? "").appendingPathComponent(cacheFileName).absoluteString
}

///输入文件名(NSString)，返回Document目录下的文件路径(NSString)
@inline(__always) public func MDKFileDocumentWith(_ documentFileName: String) -> String {
	return MDKURL(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? "").appendingPathComponent(documentFileName).absoluteString
}


#endif

//MARK: 	分类

#if canImport(UIKit)
extension UIView {
	public func MDKEnableRedBackground() -> () {
		#if DEBUG
		backgroundColor = .red
		#endif
	}
}

extension UITableView {
	public func MDKRegister(Cell cellClass: AnyClass) -> () {

		let classFullName = NSStringFromClass(cellClass)
		let splitArr = classFullName.split(separator: ".")
		var className = classFullName
		if splitArr.count > 0 {
			className = String(splitArr.last!)
		}

		if let path = Bundle.main.path(forResource: className, ofType: "nib"), FileManager.default.fileExists(atPath: path) {
			register(UINib(nibName: className, bundle: nil), forCellReuseIdentifier: classFullName)
		} else {
			register(cellClass, forCellReuseIdentifier: classFullName)
		}
	}

	public func MDKRegister(Footer footerClass: AnyClass) -> () {
		MDKRegister(Header: footerClass)
	}
	public func MDKRegister(Header headerClass: AnyClass) -> () {

		let classFullName = NSStringFromClass(headerClass)
		let splitArr = classFullName.split(separator: ".")
		var className = classFullName
		if splitArr.count > 0 {
			className = String(splitArr.last!)
		}

		if let path = Bundle.main.path(forResource: className, ofType: "nib"), FileManager.default.fileExists(atPath: path) {
			register(UINib(nibName: className, bundle: nil), forHeaderFooterViewReuseIdentifier: classFullName)
		} else {
			register(headerClass, forHeaderFooterViewReuseIdentifier: classFullName)
		}
	}
}

extension UICollectionView {
	public func MDKRegister(Cell cellClass: AnyClass) -> () {

		let classFullName = NSStringFromClass(cellClass)
		let splitArr = classFullName.split(separator: ".")
		var className = classFullName
		if splitArr.count > 0 {
			className = String(splitArr.last!)
		}

		if let path = Bundle.main.path(forResource: className, ofType: "nib"), FileManager.default.fileExists(atPath: path) {
			register(UINib(nibName: className, bundle: nil), forCellWithReuseIdentifier: classFullName)
		} else {
			register(cellClass, forCellWithReuseIdentifier: classFullName)
		}
	}

	public func MDKRegister(Footer footerClass: AnyClass) -> () {
		MDKRegister(viewClass: footerClass, isHeader: false)
	}

	public func MDKRegister(Header headerClass: AnyClass) -> () {
		MDKRegister(viewClass: headerClass, isHeader: true)
	}

	private func MDKRegister(viewClass: AnyClass, isHeader: Bool) -> () {

		var kind = UICollectionView.elementKindSectionHeader

		if !isHeader {
			kind = UICollectionView.elementKindSectionFooter
		}

		let classFullName = NSStringFromClass(viewClass)
		let splitArr = classFullName.split(separator: ".")
		var className = classFullName
		if splitArr.count > 0 {
			className = String(splitArr.last!)
		}

		if let path = Bundle.main.path(forResource: className, ofType: "nib"), FileManager.default.fileExists(atPath: path) {
			register(UINib(nibName: className, bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: classFullName)
		} else {
			register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: classFullName)
		}
	}
}

extension UIFont {
	var Thin: UIFont {
		let Size = self.pointSize;
		var fontName = self.fontName;

		if let _range = fontName.range(of: "-"), !_range.isEmpty {
			fontName.replaceSubrange(_range.upperBound ... fontName.endIndex, with: "Light")
			if let font = UIFont(name: fontName, size: Size) {
				return font
			}
		} else {
			var thinFont: UIFont? = nil;
			if fontName.contains("SFUIDisplay") {
				thinFont = UIFont(name: ".SFUIDisplay-Light", size: Size)
				if thinFont != nil {
					return thinFont!;
				}
			}
			if fontName.contains("SFUIText") {
				thinFont = UIFont(name: ".SFUIText-Light", size: Size)
				if thinFont != nil {
					return thinFont!;
				}
			}
			thinFont = UIFont(name: ".HelveticaNeueInterface-Light", size: Size)
			if thinFont != nil {
				return thinFont!;
			}
		}

		return self;
	}

	var Bold: UIFont {
		return UIFont.boldSystemFont(ofSize: self.pointSize)
	}
}
extension UIAlertController {
	public typealias UIAlertActionClose = (UIAlertAction)->()

	@discardableResult
	public func MDKAdd(Default Action: @escaping UIAlertActionClose, title: String, config: UIAlertActionClose? = nil) -> UIAlertController {
		let action = UIAlertAction(title: title, style: .default, handler: Action)
		config?(action)
		addAction(action)
		return self
	}
	@discardableResult
	public func MDKAdd(Cancel Action: @escaping UIAlertActionClose, title: String, config: UIAlertActionClose? = nil) -> UIAlertController {
		let action = UIAlertAction(title: title, style: .cancel, handler: Action)
		config?(action)
		addAction(action)
		return self
	}
	@discardableResult
	public func MDKAdd(Destructive Action: @escaping UIAlertActionClose, title: String, config: UIAlertActionClose? = nil) -> UIAlertController {
		let action = UIAlertAction(title: title, style: .destructive, handler: Action)
		config?(action)
		addAction(action)
		return self
	}

	@discardableResult
	public func MDKAdd(TextField config: ((UITextField) -> Void)? = nil) -> UIAlertController {
		
		assert(preferredStyle == .alert, "只有alert支持添加textField")
		
		addTextField(configurationHandler: config)

		return self
	}
	public func MDKQuickPresented() -> () {
		MDKRootViewController.present(self, animated: true, completion: nil)
	}
}

#endif


#if canImport(Foundation)
@inline(__always) public func MDKDispatch_queue_async_safe(_ queue: DispatchQueue, _ action: @escaping ()->()) -> () {
	if let currentQueueLabel = OperationQueue.current?.underlyingQueue?.label {
		if queue.label == currentQueueLabel {
			action()
			return;
		}
	}
	queue.async(execute: action)
}
@inline(__always) public func MDKDispatch_main_async_safe(_ action: @escaping ()->()) -> () {
	MDKDispatch_queue_async_safe(DispatchQueue.main, action)
}
#endif


//
//  MDKTools.m
//  MDKTools
//
//  Created by mikun on 2017/6/28.
//  Copyright © 2017年 mikun. All rights reserved.
//



#import "MDKTools.h"
//#import <objc/runtime.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#ifdef _hasUIKit
#pragma mark - UIAlertController相关

UIAlertController* __CreateAlertCtr(NSString *title,NSString *message,UIAlertControllerStyle style){
	UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];

	return alertVC;
}

UIAlertController *MDKAlertCtr(NSString *title,NSString *message){
	return __CreateAlertCtr(title, message, UIAlertControllerStyleAlert);
}
UIAlertController *MDKSheetAlertCtr(NSString *title,NSString *message){
	return __CreateAlertCtr(title, message, UIAlertControllerStyleAlert);
}



//MARK:	简化版:一个按钮功能和一个消失按钮
UIAlertController* __CreateAlertWithBlock(void (^confirmAction)(),NSString *title,NSString *message,NSString *confirmTitle,BOOL showCancel,UIAlertControllerStyle style){
	UIAlertController *alertVC = __CreateAlertCtr(title, message, style);
	if (confirmTitle) {
		UIAlertAction *confirmAct = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			if (confirmAction) {
				confirmAction();
			}
			
		}];
		[alertVC addAction:confirmAct];
	}
	
	
	if (showCancel) {
		UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
		[alertVC addAction:cancelAct];
	}
	
	return alertVC;
}

UIAlertController *MDKAlertWithBlock(void (^confirmAction)(),NSString *title,NSString *message,NSString *confirmTitle,BOOL showCancel){
	return __CreateAlertWithBlock(confirmAction, title, message, confirmTitle, showCancel, UIAlertControllerStyleAlert);
}

UIAlertController *MDKSheetAlertWithBlock(void (^confirmAction)(),NSString *title,NSString *message,NSString *confirmTitle,BOOL showCancel){
	return __CreateAlertWithBlock(confirmAction, title, message, confirmTitle, showCancel, UIAlertControllerStyleActionSheet);
}


#pragma mark - 获取真正的rootViewController

UIViewController *_theTopviewControler(){
	UIViewController *rootVC = MDKKeywindow.rootViewController;
	
	UIViewController *parent = rootVC;
	
	while ((parent = rootVC.presentedViewController) != nil ) {
		rootVC = parent;
	}
	
	while ([rootVC isKindOfClass:[UINavigationController class]]) {
		rootVC = [(UINavigationController *)rootVC topViewController];
	}
	
	return rootVC;
}

UINavigationController *_theTopNavController(){
	UINavigationController *nav = MDKRootViewController;
	UINavigationController *lastNav;
	while (1) {
		if ([nav isKindOfClass:UINavigationController.class]) {
			lastNav = nav;
		}

		if (nav.presentedViewController) {
			while (nav.presentedViewController) {
				nav = nav.presentedViewController;
			}
		}else if ([nav isKindOfClass:UITabBarController.class]) {
			UITabBarController *tab = nav;
			if (!tab.selectedViewController) {
				break;
			}
			nav = tab.selectedViewController;
		}else  if (![nav isKindOfClass:UINavigationController.class] && nav.navigationController) {
			if (lastNav == nav.navigationController) {
				break;
			}
			nav = nav.navigationController;
		}else if([nav isKindOfClass:UINavigationController.class]){
			if (!nav.viewControllers.count) {
				break;
			}
			nav = nav.viewControllers.lastObject;
		}else{
			break;
		}
	}

	if (![nav isKindOfClass:UINavigationController.class]) {
		nav = lastNav;
	}
	return nav;
}

///获取的IOS版本
static CGFloat iOS_ver;
CGFloat iOS_version(){
	if (iOS_ver < 1) {
		iOS_ver = UIDevice.currentDevice.systemVersion.doubleValue;
	}
	return iOS_ver;
}


///判断获取的IOS版本是否大于等于 ver
bool MDKiOSUp(CGFloat ver){
	return (iOS_version() >= ver);
}

bool MDKiOSDown(CGFloat ver){
	return (iOS_version() < ver);
}

///通过storyboard的名字获取它的instantiateInitialViewController,bundle为nil
UIViewController *MDKSBInitialVC(NSString *SBName){
	return [UIStoryboard storyboardWithName:SBName bundle:nil].instantiateInitialViewController;
}

#pragma mark - 颜色
///获得RGBA颜色
UIColor *MDKColorWithAlpha(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha){
	if (MDKiOS_Machine_Type==MDKiOSMachineIsiPhone&&MDKiOS_MachineModel>9) {
		return [UIColor colorWithDisplayP3Red:(red)/255.0 green:(green)/255.0 blue:(blue)/255.0 alpha:(alpha)];
	}
	return [UIColor colorWithRed:(red)/255.0 green:(green)/255.0 blue:(blue)/255.0 alpha:(alpha)];
}

///获得RGB颜色
UIColor *MDKColor(CGFloat red, CGFloat green, CGFloat blue){
	return MDKColorWithAlpha(red,green,blue,1.0);
}

///16进制转换RGB
UIColor *MDKColorFromHex(NSUInteger intValue){
	if (intValue>0xFFFFFF) {
		return MDKColorWithAlpha(((intValue & 0xFF000000) >> 32), ((intValue & 0xFF0000) >> 16), ((intValue & 0xFF00) >> 8), (intValue & 0xFF));
	}else{
		return MDKColor(((intValue & 0xFF0000) >> 16), ((intValue & 0xFF00) >> 8), (intValue & 0xFF));
	}

}

///16进制转换RGBA2.0,单独设置alpha
UIColor *MDKColorFromHex_setAlpha(NSUInteger rgbValue ,CGFloat alpha){
	return MDKColorWithAlpha(((rgbValue & 0xFF0000) >> 16), ((rgbValue & 0xFF00) >> 8), (rgbValue & 0xFF), alpha);
}


///16进制字符串转换RGB
UIColor *MDKColorFromHexStr(NSString *hexString){
	NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
	cleanString = [cleanString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if([cleanString length] == 3) {
		cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
					   [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
					   [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
					   [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
	}


	unsigned int intValue;
	[[NSScanner scannerWithString:cleanString] scanHexInt:&intValue];
	return MDKColorFromHex(intValue);

}

UIColor *MDKColorFromHexCStr(const char *hexCString){
	NSString *hexString = [NSString stringWithUTF8String:hexCString];

	return MDKColorFromHexStr(hexString);
}

///不透明,相同颜色
UIColor *MDKSameColor(CGFloat same){
	return MDKColor(same, same, same);
}

///设置透明,相同颜色
UIColor *MDKSameColorWithAlpha(CGFloat same,CGFloat alpha){
	return MDKColorWithAlpha(same, same, same, alpha);
}

///从NSBundle加载Nib数组
NSArray<UIView *> *MDKLoadXibArr(NSString* nibNamed , id owner,NSDictionary*option){
	return [NSBundle.mainBundle loadNibNamed:nibNamed owner:owner options:option];
}

///通过一个字典来创建NSAttributedString,key可以是NSString,UIImage,NSAttributedString,value必须是NSDictionary;UIImage的value必须是@(CGRect)作为bounds,如果为@{}则用UIImage.size;NSAttributedString的value是无效的传@{}就行,也可以最外层是个Dic,然后用前面的内容做 key,value 放一个 Dic 作为共有 attribute
NSAttributedString *MDKAttString(NSArray<NSDictionary *>* strArr){
	NSDictionary *commonAttribute = nil;
	if ([strArr isKindOfClass:NSDictionary.class]) {
		commonAttribute = [(NSDictionary *)strArr allValues].firstObject;
		strArr = [(NSDictionary *)strArr allKeys].firstObject;
	}
	__block NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:@""];
	if (![strArr isKindOfClass:NSArray.class]) {
		return attStr;
	}
	[strArr enumerateObjectsUsingBlock:^(NSDictionary *strDic, NSUInteger idx, BOOL *stop) {
		[strDic enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *obj, BOOL *stop) {

			if ([key isKindOfClass:NSString.class]) {
				if (![obj isKindOfClass:NSDictionary.class]) { return; }
				if (commonAttribute) {
					NSMutableDictionary *objM = commonAttribute.mutableCopy;
					[objM setValuesForKeysWithDictionary:obj];
					obj = objM;
				}
				[attStr appendAttributedString:[[NSAttributedString alloc]initWithString:key attributes:obj]];
			}else if ([key isKindOfClass:UIImage.class]){
				NSMutableAttributedString *atr = [[NSMutableAttributedString alloc]initWithString:@"\uFFFC "];
				NSTextAttachment *attach = [[NSTextAttachment alloc]init];
				attach.image = key;
				NSValue *sizeNumber = obj;
				CGRect bounds = (CGRect){{0, -2}, attach.image.size};
				if ([sizeNumber isKindOfClass:NSValue.class]) {
					if (strcmp(sizeNumber.objCType, "{CGRect={CGPoint=dd}{CGSize=dd}}") == 0) {
						CGRect targetBounds = [sizeNumber CGRectValue];
						if (!CGRectEqualToRect(targetBounds, CGRectZero)) {
							bounds= targetBounds;
						}
					}
				}
				attach.bounds = bounds;
				[atr setAttributes:@{NSAttachmentAttributeName:attach}range:NSMakeRange(0, atr.length)];
				[attStr appendAttributedString:atr];
			}else if ([key isKindOfClass:NSAttributedString.class]){
				[attStr appendAttributedString:key];
			}
		}];
	}];
	
	
	return attStr;
}

void MDKChangeStatusBarBackgroundColor(UIColor *color){
	UIView *statusBar = [[UIApplication.sharedApplication valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
	if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
		statusBar.backgroundColor = color;
	}
}
#endif

#ifdef _hasFoundation
static CGFloat _iOS_MachineModel;
static MDKiOSMachineType _iOS_MachineType;
void creat_iOS_info();

CGFloat get_iOS_MachineModel(){
	if (_iOS_MachineModel < 1) {
		creat_iOS_info();
	}
	return _iOS_MachineModel;
}

MDKiOSMachineType get_iOS_Machine_Type(){
	if (_iOS_MachineType == MDKiOSMachineUnknow) {
		creat_iOS_info();
	}
	return _iOS_MachineType;
}

void creat_iOS_info(){
	
	int mib[2];
	size_t len;
	char *machine;
	
	mib[0] = CTL_HW;
	mib[1] = HW_MACHINE;
	sysctl(mib, 2, NULL, &len, NULL, 0);
	machine = malloc(len);
	sysctl(mib, 2, machine, &len, NULL, 0);
	
	NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
	free(machine);
	
	platform = [platform stringByReplacingOccurrencesOfString:@"," withString:@"."];
	
	if ([platform rangeOfString:@"iPhone"].length) {
		_iOS_MachineType = MDKiOSMachineIsiPhone;
		platform = [platform stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
	}
	
	if ([platform rangeOfString:@"iPad"].length) {
		_iOS_MachineType = MDKiOSMachineIsiPad;
		platform = [platform stringByReplacingOccurrencesOfString:@"iPad" withString:@""];
	}
	
	if ([platform rangeOfString:@"i386"].length) {
		_iOS_MachineType = MDKiOSMachineIsSimulator;
		platform = [platform stringByReplacingOccurrencesOfString:@"i386" withString:@""];
	}
	
	if ([platform rangeOfString:@"x86_64"].length) {
		_iOS_MachineType = MDKiOSMachineIsSimulator;
		platform = [platform stringByReplacingOccurrencesOfString:@"x86_64" withString:@""];
	}
	
	if (platform.length) {
		_iOS_MachineModel = platform.doubleValue;
	}
	
}
///角度制转弧度制
CGFloat MDKAngle2Radian(CGFloat angle){
	return ((angle) / 180.0 * M_PI);
}

///用NSString返回一个URL
NSURL *MDKURL(NSString *unUTF8str){
	return [NSURL URLWithString:unUTF8str];
}

///用NSString返回一个转换了含有非英文字符的URL
NSURL *MDKURLEncoding(NSString *unUTF8str){
	NSString *UTF8str = [unUTF8str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
	return MDKURL(UTF8str);
}

///用NSString返回一个转换了含有非英文字符的URLRequest
NSURLRequest *MDKURLRequest(NSString *unUTF8str){
	return [NSURLRequest requestWithURL:MDKURL(unUTF8str)];
}

///用NSString返回一个转换了含有非英文字符的URLRequest
NSURLRequest *MDKURLRequestEncoding(NSString *unUTF8str){
	return [NSURLRequest requestWithURL:MDKURLEncoding(unUTF8str)];
}

///JSON转字典，不处理错误
NSDictionary *MDKDicWithJSON(NSData *JSONData){
	return [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:nil];
}

///输入文件名(NSString)，返回Temporary目录下的文件路径(NSString)
NSString *MDKFileTempWith(NSString *tempFileName){
	return [NSTemporaryDirectory() stringByAppendingPathComponent:(tempFileName)];
}

///输入文件名(NSString)，返回library/Cache目录下的文件路径(NSString)
NSString *MDKFileCacheWith(NSString *cacheFileName){
	return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:(cacheFileName)];
}

///输入文件名(NSString)，返回Document目录下的文件路径(NSString)
NSString *MDKFileDocumentWith(NSString *documentFileName){
	return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:(documentFileName)];
}



NSString * MDKString(NSString *Format,...){
	va_list args;
	va_start(args, Format);
	NSString *
	str = [[NSString alloc]initWithFormat:Format arguments:args];
	va_end(args);
	return str;
}



NSString *replaceUnicode(NSString *unicodeStr);




//转换指针到OC对象和C基本数据类型的部分,修改自
//https://github.com/stanislaw/NSStringFromAnyObject
//算法做了逻辑简化
NSString *MDKRepalceLog(const char *type, const void *voidObject){
#ifdef DEBUG
	
	__unsafe_unretained id object = nil;
	NSString *printStr;
	
	switch (type[0]) {
		case '@': {//NS对象
			object = *(__unsafe_unretained id *)voidObject;
			break;
		}
		case '#': {//NS类
			object = *(Class *)voidObject;
			break;
		}
		case ':': {//方法对象
			object = NSStringFromSelector(*(SEL *)voidObject);
			break;
		}
		default:
			break;
	}
	
	if (object){
		
		if ([object isKindOfClass:NSString.class]) {
			printStr = object;
		}else if([object isKindOfClass:NSArray.class]){
#pragma mark - 处理NSArray的中文
			NSArray *arrObject = object;
			
			// 开头有个[
			NSMutableString *string = @"@[\n".mutableCopy;
			
			// 遍历所有的元素
			[arrObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				[string appendFormat:@"\t%@,\n", obj];
			}];
			
			// 结尾有个]
			[string appendString:@"]"];
			
			// 查找最后一个逗号
			NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
			if (range.location != NSNotFound)
				[string deleteCharactersInRange:range];
			printStr = string.copy;
			
		}else if([object isKindOfClass:NSDictionary.class]){
#pragma mark - 处理NSDictionary的中文
			NSDictionary *dicObject = object;
			
			// 开头有个{
			NSMutableString *string = @"@{\n".mutableCopy;
			
			// 遍历所有的键值对
			[dicObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				[string appendFormat:@"\t%@", key];
				[string appendString:@" : "];
				[string appendFormat:@"%@,\n", obj];
			}];
			
			// 结尾有个}
			[string appendString:@"}"];
			
			// 查找最后一个逗号
			NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
			if (range.location != NSNotFound)
				[string deleteCharactersInRange:range];
			
			printStr = string.copy;
		}else if ([object isKindOfClass:NSIndexPath.class]) {
			NSIndexPath *indexPathObject = object;
			
			// 开头有个NSIndexPath:{
			NSMutableString *str = @"NSIndexPath:{\n".mutableCopy;
			
			[str appendString:MDKString(@"\tlength = %d\n",indexPathObject.length)];
			@try {
				//如果开了Exception Breakpoint会停在这里,继续就行了
				//为了通用,这里import的是<Foundation/Foundation.h>,所以找不到section这个属性
				id section = [indexPathObject valueForKeyPath:@"section"];
				[str appendString:MDKString(@"\tsection = %d",[section integerValue])];
			} @catch (NSException *exception) {
				[str appendString:MDKString(@"\tsection = unknwon")];
			}
			
			@try {
				//如果开了Exception Breakpoint会停在这里,继续就行了
				//如果是使用[NSIndexPath indexPathWithIndex:]来初始化的,内部的_indexes[1]不会有值,也就会崩溃
				id row = [indexPathObject valueForKeyPath:@"row"];
				[str appendString:MDKString(@",row(item) = %d\n",[row integerValue])];
			} @catch (NSException *exception) {
				[str appendString:MDKString(@",row(item) = unknwon\n")];
			}
			
			// 结尾有个]
			[str appendString:@"}"];
			
			printStr = str.copy;
			
			
		}else if ([object isKindOfClass:NSObject.class]) {
			NSObject* nsobj = object;
			printStr = nsobj.description;
		}
		
	}else{
#pragma mark
//FIXME:	这里写的比较激进,默认了只要不是NSObject的子类,都是基本数据类型/结构体,但那些也解析不了
		
#pragma mark - C numeric types
		//对浮点数简单做了处理,要放到最前面判断
		if (strcmp(@encode(double), type) == 0) {
			printStr = MDKString(@"%f",*(double *)voidObject);
		}
		
		if (strcmp(@encode(float), type) == 0){
			printStr = MDKString(@"%ff",*(float *)voidObject);
		}
		
		if (printStr.length>2) {//x.y
			while ([[printStr substringFromIndex:printStr.length-1] isEqualToString:@"0"]) {
				printStr = [printStr substringToIndex:printStr.length-1];
			}
			if ([[printStr substringFromIndex:printStr.length-1] isEqualToString:@"."]) {
				printStr = MDKString(@"%@0",printStr);
			}
		}
		
		
		if (strcmp(@encode(BOOL), type) == 0){
			if (strcmp(@encode(BOOL), @encode(signed char)) == 0){
				// 32 bit
				char ch = *(signed char *)voidObject;
				if ((char)YES == ch) printStr =  @"true";
				if ((char)NO == ch) printStr =  @"false";
			}
			
			else if (strcmp(@encode(BOOL), @encode(bool)) == 0){
				// 64 bit
				bool boolValue = *(bool *)voidObject;
				if (boolValue) {
					printStr =  @"true";
				}else{
					printStr =  @"false";
				}
			}
		}
		
		
		if (strcmp(@encode(int), type) == 0){
			printStr = MDKString(@"%d",*(int *)voidObject);
		}
		
		if (strcmp(@encode(short), type) == 0){
			printStr = MDKString(@"%d",*(short *)voidObject);
		}
		
		if (strcmp(@encode(long), type) == 0){
			printStr = MDKString(@"%ldL", *(long *)voidObject);
		}
		
		if (strcmp(@encode(long long), type) == 0) {
			printStr = MDKString(@"%lldLL", *(long long *)voidObject);
		}
		
		if (strcmp(@encode(unsigned int), type) == 0){
			printStr = MDKString(@"%u", *(unsigned int *)voidObject);
		}
		
		if (strcmp(@encode(unsigned short), type) == 0){
			printStr = MDKString(@"%u", *(unsigned short *)voidObject);
		}
		
		if (strcmp(@encode(unsigned long), type) == 0){
			printStr = MDKString(@"%lu", *(unsigned long *)voidObject);
		}
		
		if (strcmp(@encode(unsigned long long), type) == 0){
			printStr = MDKString(@"%llu", *(unsigned long long *)voidObject);
		}
		
#pragma mark - C char (*) strings
		if (strcmp(@encode(const char *), type) == 0) {
			printStr = MDKString(@"%s", *(const char **)voidObject);
		}
		if (strcmp(@encode(char *), type) == 0) {
			printStr = MDKString(@"%s", *(const char **)voidObject);
		}
		if (strcmp(@encode(char), type) == 0){
			char ch = *(char *)voidObject;
			printStr = MDKString(@"%c",ch);
		}
		if (strcmp(@encode(unsigned char), type) == 0){
			printStr = MDKString(@"%c", *(unsigned char *)voidObject);
		}
		NSString *NSType = [NSString stringWithUTF8String:type];
		if ([NSType hasSuffix:@"c]"]) {
			char* charObject = (char*)voidObject;
			printStr = [NSString stringWithUTF8String:charObject];
		}
		
#pragma mark - C语言数据都匹配不到
		if (!printStr) {
			printStr = [NSValue valueWithBytes:voidObject objCType:type].description;
			printStr = [printStr stringByReplacingOccurrencesOfString:@"NS" withString:@"CG"];
			printStr = [printStr stringByReplacingOccurrencesOfString:@"CGRange" withString:@"NSRange"];
		}
		
	}
	if (printStr) {
		
#if 0
		/*类似NSLog的打印,因为我不知道项目名后面的[]是什么所以没加*/
		NSDate *date = [NSDate date];
		NSTimeZone *zone = [NSTimeZone systemTimeZone];
		NSInteger interval = [zone secondsFromGMTForDate: date];
		NSDate *localeDate = [date dateByAddingTimeInterval: interval];
		
		NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
		fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
		NSString* dateStr = [fmt stringFromDate:localeDate];
		
		NSString *displayName = [NSBundle.mainBundle.infoDictionary objectForKey:(__bridge NSString*)kCFBundleNameKey];
		
		printStr = MDKString(@"%@ %@ %@",dateStr,displayName,printStr);
#endif
		printStr = replaceUnicode(printStr);
		printf("%s\n",printStr.UTF8String);//本来是多线程打印的,但断点调试不方便,就去掉了
	}
	return printStr;
#endif
	return nil;
}
//来源:http://blog.csdn.net/u013428812/article/details/20370993
NSString *replaceUnicode(NSString *unicodeStr){



	NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
	NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
	NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
	NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
	[NSString stringWithCString:[tempStr3 cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
	NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
	if (!returnStr) {
		returnStr = tempStr3;
	}
	return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

///输出程序的基本信息,比如模拟器路径,设备信息
void baseLog(){
	NSLog(@"baseLog:");
	NSLog(@"App路径:%@",[[NSBundle mainBundle] bundlePath]);
	NSLog(@"App沙盒路径:%@",NSHomeDirectory());
}

///模拟设备被独占，线程被占用，用于测试性能
void MDKSleep(CGFloat time){
	[NSThread sleepForTimeInterval:time];
}
#endif



#ifdef _hasUIKit
@implementation UIView (MDKTool)
- (void)MDKEnableRedBackground{
#ifdef DEBUG
	self.backgroundColor = [UIColor redColor];
#endif
}
@end

@implementation UITableView(MDKTool)
- (void)MDKRegisterCell:(NSString *)cellName{
	if ([NSFileManager.defaultManager fileExistsAtPath:[NSBundle.mainBundle pathForResource:cellName ofType:@"nib"]]) {
		[self registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellReuseIdentifier:cellName];
	}else{
		[self registerClass:NSClassFromString(cellName) forCellReuseIdentifier:cellName];
	}
}

- (void)MDKRegisterHeader:(NSString *)headerName{
	[self MDKRegisterHeader_Footer:headerName];
}
- (void)MDKRegisterFooter:(NSString *)footerName{
	[self MDKRegisterHeader_Footer:footerName];
}
- (void)MDKRegisterHeader_Footer:(NSString *)viewName{
	if ([NSFileManager.defaultManager fileExistsAtPath:[NSBundle.mainBundle pathForResource:viewName ofType:@"nib"]]) {
		[self registerNib:[UINib nibWithNibName:viewName bundle:nil] forHeaderFooterViewReuseIdentifier:viewName];
	}else{
		[self registerClass:NSClassFromString(viewName) forHeaderFooterViewReuseIdentifier:viewName];
	}
}
@end

@implementation UICollectionView(MDKTool)
- (void)MDKRegisterCell:(NSString *)cellName{
	if ([NSFileManager.defaultManager fileExistsAtPath:[NSBundle.mainBundle pathForResource:cellName ofType:@"nib"]]) {
		[self registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellWithReuseIdentifier:cellName];
	}else{
		[self registerClass:NSClassFromString(cellName) forCellWithReuseIdentifier:cellName];
	}
}
- (void)MDKRegisterHeader:(NSString *)headerName{
	[self MDKRegisterHeader_Footer:headerName isHeader:YES];
}
- (void)MDKRegisterFooter:(NSString *)footerName{
	[self MDKRegisterHeader_Footer:footerName isHeader:NO];
}
- (void)MDKRegisterHeader_Footer:(NSString *)viewName isHeader:(BOOL)isHeader{
	NSString *kind = UICollectionElementKindSectionHeader;
	if (!isHeader) {
		kind = UICollectionElementKindSectionFooter;
	}
	if ([NSFileManager.defaultManager fileExistsAtPath:[NSBundle.mainBundle pathForResource:viewName ofType:@"nib"]]) {
		[self registerNib:[UINib nibWithNibName:viewName bundle:nil] forSupplementaryViewOfKind:kind withReuseIdentifier:viewName];
	}else{
		[self registerClass:NSClassFromString(viewName) forSupplementaryViewOfKind:kind withReuseIdentifier:viewName];
	}
}
@end

@implementation UIFont(MDKTool)
-(UIFont *)Thin{
	NSInteger Size = self.pointSize;
	NSMutableString *fontName = self.fontName.mutableCopy;

	NSRange _range = [fontName rangeOfString:@"-"];
	if (!_range.length) {
		UIFont *thinFont;
		if ([fontName rangeOfString:@"SFUIDisplay"].length) {
			thinFont = [UIFont fontWithName:@".SFUIDisplay-Light" size:Size];
			if (thinFont) {
				return thinFont;
			}
		}
		if ([fontName rangeOfString:@"SFUIText"].length) {
			UIFont *thinFont = [UIFont fontWithName:@".SFUIText-Light" size:Size];
			if (thinFont) {
				return thinFont;
			}
		}
		thinFont = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:Size];
		
		if (thinFont) {
			return thinFont;
		}
		
		return self;
	}

	NSUInteger rangeFrom = NSMaxRange(_range);
	[fontName replaceCharactersInRange:NSMakeRange(rangeFrom, fontName.length-rangeFrom) withString:@"Light"];
	
	return [UIFont fontWithName:fontName size:Size];
}
-(UIFont *)Bold{
	NSInteger Size = self.pointSize;
	return [UIFont boldSystemFontOfSize:Size];
}
@end


@implementation UIAlertController(quick)

- (MDKAddActionType)MDKAddDefaultAction{
	return [self MDKAddActionForStyle:UIAlertActionStyleDefault];
}
- (MDKAddActionType)MDKAddCancelAction{
	return [self MDKAddActionForStyle:UIAlertActionStyleCancel];
}
- (MDKAddActionType)MDKAddDestructiveAction{
	return [self MDKAddActionForStyle:UIAlertActionStyleDestructive];
}
- (MDKAddActionType)MDKAddActionForStyle:(UIAlertActionStyle)style{
	return ^UIAlertController *(NSString *title,UIAlertCreateActionBlock action,UIAlertHandleActionBlock handler) {
		UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:style handler:action];
		if (handler) {
			handler(alertAction);
		}
		[self addAction:alertAction];
		return self;
	};
}
- (MDKAddTextFieldType)MDKAddTextField{

	return ^UIAlertController *(UIAlertCreateTextFieldBlock action, UIAlertHandleTextFieldBlock handler) {
		NSArray *textFieldsBefore = self.textFields.copy;
		[self addTextFieldWithConfigurationHandler:action];

		if (handler) {
			NSArray *textFieldsAfter = self.textFields.copy;

			NSArray *textFieldsNew = [textFieldsAfter filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, id bindings) {
				return ![textFieldsBefore containsObject:evaluatedObject];
			}]];
			if (textFieldsNew.count) {
				handler(textFieldsNew.firstObject);
			}
		}
		return self;
	};
}
- (void)MDKQuickPresented{
	[MDKRootViewController presentViewController:self animated:YES completion:nil];
}

@end

@implementation UIImage (OptimizeRAM)
//MARK:	Not Finished
+(UIImage *)imageURL:(NSString *)imgStr size:(CGSize)pointSize scale:(CGFloat)scale{
	NSDictionary *sourceOpt = @{(__bridge NSString *)kCGImageSourceShouldCache : @0};

	NSURL *imgUrl = [NSURL URLWithString:imgStr];
	CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)imgUrl, (__bridge CFDictionaryRef)sourceOpt);

	CGFloat maxDimension = MAX(pointSize.width, pointSize.height) * scale;
	NSDictionary * downsampleOpt =@{
									(__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways:@1,
									(__bridge NSString *)kCGImageSourceShouldCacheImmediately:@1,
									(__bridge NSString *)kCGImageSourceCreateThumbnailWithTransform:@1,
									(__bridge NSString *)kCGImageSourceThumbnailMaxPixelSize:@(maxDimension),
									};

	CGImageRef downsampleImage = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)downsampleOpt);
	return [UIImage imageWithCGImage:downsampleImage];

}
@end
#endif


#ifdef _hasFoundation
NSString *MDKGetPropertyName(objc_property_t property){
	return [NSString stringWithUTF8String:property_getName(property)];
}
NSString *MDKGetPropertyType(objc_property_t property){
	NSString *type = [NSString stringWithUTF8String:property_getAttributes(property)];
	NSRange typeRange = [type rangeOfString:@"T@\""];
	if (typeRange.length) {
		NSInteger loc = NSMaxRange(typeRange);
		NSInteger end = [type rangeOfString:@"\","].location;
		return [type substringWithRange:NSMakeRange(loc, end-loc)];
	}
	return @"";
}

NSString *MDKGetIvaName(Ivar ivar){
	return [NSString stringWithUTF8String:ivar_getName(ivar)];
}
NSString *MDKGetIvaType(Ivar ivar){
	NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
	NSRange typeRange = [type rangeOfString:@"@\""];
	if (typeRange.length) {
		NSInteger loc = NSMaxRange(typeRange);
		NSInteger end = [type rangeOfString:@"\"" options:NSBackwardsSearch].location;
		return [type substringWithRange:NSMakeRange(loc, end-loc)];
	}
	return nil;
}
CGFloat MDKiPhoneXInset;
@implementation NSObject(MDKTool)

+(NSString *)name{
	return NSStringFromClass(self.class);
}


__attribute__((constructor))
void initiPhoneXTopInset(){
	MDKiPhoneXInset = MDKScreenHeight>=768 ? 24 : 0;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		MDKiPhoneXInset = MDKScreenHeight>=768 ? 24 : 0;
	});
}

- (void)MDKInitModel{
	[self MDKInitModel_checkExists:NO];
}
- (void)MDKInitModel_IfNotExists{
	[self MDKInitModel_checkExists:YES];
}
- (void)MDKInitModel_checkExists:(BOOL)checkExists{
	unsigned int count = 0;
	objc_property_t *propertys = class_copyPropertyList(self.class, &count);
	for (int i = 0; i < count; i++) {
		objc_property_t property = propertys[i];

		NSString *name = MDKGetPropertyName(property);
		if (checkExists) {
			if ([self valueForKey:name]) {
				continue;
			}
		}

		NSString *type = MDKGetPropertyType(property);
		NSString *attribute = [NSString stringWithUTF8String:property_getAttributes(property)];
		if ([attribute rangeOfString:@",S"].length) {//防止setter改名写入失败
			name = [attribute substringFromIndex:NSMaxRange([attribute rangeOfString:@",S"])];
			if ([name rangeOfString:@","].length) {
				name = [name substringToIndex:[name rangeOfString:@","].location];
			}
		}else{
			name = MDKString(@"%@%@",[[name substringToIndex:1] uppercaseString],[name substringFromIndex:1]);
			name = MDKString(@"set%@:",name);
		}
		if (NSClassFromString(type)) {
			SEL sel = NSSelectorFromString(name);
			if ([self respondsToSelector:sel]) {
				[self performSelector:sel withObject:[[NSClassFromString(type)alloc]init]];
			}
		}

	}
	free(propertys);
}

//该方法修改自https://www.jianshu.com/p/672c0d4f435a
- (id)MDKPerformSelector:(SEL)selector withObjects:(NSArray *)objects{
	if (objects && ![objects isKindOfClass:NSArray.class]) {
		objects = @[objects];
	}
	NSMethodSignature *signature = [self.class instanceMethodSignatureForSelector:selector];
	if (!signature) {
		signature = [self.class methodSignatureForSelector:selector];//获取类方法
	}
	NSAssert(signature, MDKString(@"-[%@ %@]: unrecognized selector sent to instance %p",NSStringFromClass(self.class) , NSStringFromSelector(selector),self));

	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.target = self;
	invocation.selector = selector;

	NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
	NSAssert(objects.count == paramsCount, @"para count does not match to method");

	paramsCount = MIN(paramsCount, objects.count);
	for (NSInteger i = 0; i < paramsCount; i++) {
		id object = objects[i];
		if ([object isKindOfClass:[NSNull class]]) continue;
		[invocation setArgument:&object atIndex:i + 2];
	}

	[invocation invoke];

	__autoreleasing id returnValue = nil;//修正类方法返回数据会被释放
	if (signature.methodReturnLength) {
		[invocation getReturnValue:&returnValue];
	}

	return returnValue;
}

@end
#endif






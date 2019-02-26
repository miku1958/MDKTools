//
//  MDKTools.h
//  MDKTools
//
//  Created by mikun on 2017/6/28.
//  Copyright © 2017年 mikun. All rights reserved.
//

#if __has_include(<UIKit/UIKit.h>)
	#import <UIKit/UIKit.h>
	#define _hasUIKit 1
#endif
#if __has_include(<Foundation/Foundation.h>)
	#import <Foundation/Foundation.h>
	#import <objc/runtime.h>
	#define _hasFoundation 1
#endif

#define MDKLikely(x)      __builtin_expect(!!(x), 1)
#define MDKUnlikely(x)    __builtin_expect(!!(x), 0)

#define __privateAppendWeak(obj) __privateAppendWeak_of_##obj

#define MDKMakeWeak(obj) __weak typeof(obj) __privateAppendWeak(obj) = obj;
#define MDKMakeStrong(obj) __strong typeof(__privateAppendWeak(obj)) obj = __privateAppendWeak(obj);

#define MDKMakeStrongIfAlive(obj,return) MDKMakeStrong(obj);if (!obj)({return;});

#ifdef _hasUIKit
#pragma mark - UIAlertController相关
UIAlertController *MDKAlertWithBlock(void (^confirmAction)(),NSString *title,NSString *message,NSString *confirmTitle,BOOL showCancel);

UIAlertController *MDKSheetAlertWithBlock(void (^confirmAction)(),NSString *title,NSString *message,NSString *confirmTitle,BOOL showCancel);

#define MDKRootViewController _theTopviewControler()
UIViewController *_theTopviewControler();

#define MDKTopNavController _theTopNavController()
UINavigationController *_theTopNavController();

#pragma mark - IOS设备版本相关
extern CGFloat MDKiPhoneXInset;
///获取的IOS版本
CGFloat MDKiOS_version();
#define MDKiOS iOS_version()

///判断获取的IOS版本是否大于 ver
bool MDKiOSUp(CGFloat ver);

///判断获取的IOS版本是否小于 ver
bool MDKiOSDown(CGFloat ver);

#pragma mark - 程序相关
//返回程序主窗口
#define MDKKeywindow UIApplication.sharedApplication.delegate.window

#pragma mark - 屏幕尺寸相关
//返回屏幕宽度
#define MDKScreenWidth UIScreen.mainScreen.bounds.size.width

//返回屏幕高度
#define MDKScreenHeight UIScreen.mainScreen.bounds.size.height

#pragma mark - share 相关
//通知中心
#define MDKNotificationCenter NSNotificationCenter.defaultCenter
//Application
#define MDKApplicationManager UIApplication.sharedApplication

///通过storyboard的名字获取它的instantiateInitialViewController,bundle为nil
UIViewController *MDKSBInitialVC(NSString *SBName);

#pragma mark - 获取颜色
///获得RGBA颜色
UIColor *MDKColorWithAlpha(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);


///获得RGB颜色
UIColor *MDKColor(CGFloat red, CGFloat green, CGFloat blue);


///16进制转换RGB
UIColor *MDKColorFromHex(NSUInteger rgbValue);

///16进制转换RGBA2.0,单独设置alpha
UIColor *MDKColorFromHex_setAlpha(NSUInteger rgbValue ,CGFloat alpha);

///16进制字符串转换RGB
UIColor *MDKColorFromHexStr(NSString *hexString);
UIColor *MDKColorFromHexCStr(const char *hexCString);

///不透明,相同颜色
UIColor *MDKSameColor(CGFloat same);


///设置透明,相同颜色
UIColor *MDKSameColorWithAlpha(CGFloat same,CGFloat alpha);


//创建随机色
#define MDKRandomColor MDKColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

///从NSBundle加载Nib数组
NSArray *MDKLoadXibArr(NSString* nibNamed , id owner,NSDictionary*option);
///通过一个字典来创建NSAttributedString,key可以是NSString,UIImage,NSAttributedString,value必须是NSDictionary;UIImage的value必须是@(CGRect)作为bounds,如果为空则用UIImage.size;NSAttributedString的value是无效的传@{}就行
NSAttributedString *MDKAttString(NSArray<NSDictionary *>* strArr);

void MDKChangeStatusBarBackgroundColor(UIColor *color);
#endif

#ifdef _hasFoundation
#define MDKiOS_MachineModel get_iOS_MachineModel()
CGFloat get_iOS_MachineModel();

typedef NS_ENUM(NSInteger, MDKiOSMachineType) {
	MDKiOSMachineUnknow		=0,
	MDKiOSMachineIsiPhone		=1,
	MDKiOSMachineIsiPad			=2,
	MDKiOSMachineIsSimulator		=3
};

#define MDKiOS_Machine_Type get_iOS_Machine_Type()
MDKiOSMachineType get_iOS_Machine_Type();

#pragma mark - 角度制 弧度制相关
///角度制转弧度制
CGFloat MDKAngle2Radian(CGFloat angle);

#pragma mark - URL相关
///用NSString返回一个URL
NSURL *MDKURL(NSString *unUTF8str);

///用NSString返回一个转换了含有非英文字符的URL
NSURL *MDKURLEncoding(NSString *unUTF8str);

///用NSString返回一个转换了含有非英文字符的URLRequest
NSURLRequest *MDKURLRequest(NSString *unUTF8str);


///用NSString返回一个转换了含有非英文字符的URLRequest
NSURLRequest *MDKURLRequestEncoding(NSString *unUTF8str);


#pragma mark - JSON字典相关
///JSON转字典，不处理错误
NSDictionary *MDKDicWithJSON(NSData *JSONData);

#pragma mark - CGSize相关
//最大 CGSize 尺寸
#define MDKCGSIZE_MAX (CGSize){CGFLOAT_MAX,CGFLOAT_MAX}
#define CGSIZE_MAX MDKCGSIZE_MAX


#pragma mark - 沙盒目录相关
//路径相关查看NSCoding

///输入文件名(NSString)，返回Temporary目录下的文件路径(NSString)
NSString *MDKFileTempWith(NSString *tempFileName);

///输入文件名(NSString)，返回library/Cache目录下的文件路径(NSString)
NSString *MDKFileCacheWith(NSString *cacheFileName);

///输入文件名(NSString)，返回Document目录下的文件路径(NSString)
NSString *MDKFileDocumentWith(NSString *documentFileName);

///快速格式化字符串
NSString * MDKString(NSString *Format,...);

#pragma mark - 自动去除Debug用的打印
/*仅在调试界面输出信息,一般请使用MDKLog()
 如果直接传进来一个C语言数组,比如int[],是处理不了的,因为没有专门的格式化符号
 */
NSString *MDKRepalceLog(const char *type, const void *object);
//OC跟C++一样,不允许直接传入一个临时变量的地址,而基本数据的临时变量作为参数时,是值复制,拿到手后获取类型是地址内容,就不能知道它的类型了,
//而且OC不支持把id和C基本类型进行赋值运算,至少ARC下不允许
//而又不能把结构体/OC指针用@()来包装(used in a boxed expression)
//而OC指针又不能隐式转换为void*类型,需要用(__bridge void*)来显式转换,才能用NSValue包装
//所以才这么麻烦,这个办法是从github的stanislaw大神学习的,感谢stanislaw想出的这个办法(虽然还是处理不了临时C数组,但我解决了字符数组的解析.详情文档说明)
//按照字符串数组的办法来修改普通数组,却发现指针指向的内容是不同的....所以为也不知道怎么弄了,对内存不是很熟

#ifdef DEBUG
//MARK:	稍微提升一下性能,这里也用#ifdef DEBUG来判断

#if __cplusplus
#pragma mark - C++下的打印只能打印NS对象
//在OC++下不能用 (__typeof__(object) []){ object }转换成const void*类型,只能用下面的方法,但是用下面的方法就不能直接打印基本数据类型了
#define MDKLog(object) MDKRepalceLog(@encode(__typeof__(object)), (__bridge void *)object);
#else
//gcc要求在头文件中使用__typeof__而不是typeof(虽然也没有问题)
#define MDKLog(object) MDKRepalceLog(@encode(__typeof__(object)), (__typeof__(object) []){ object });
#endif

#define MDKPrint(object) MDKLog(object)

#define NSLog(...) MDKLog(MDKString(__VA_ARGS__))
//这是为了应对第三方/遗留的大量NSLog做的处理

//在调试界面输出详细信息(函数,行号)
#define MDKDetailLog(...) NSLog(@"%s %d \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])

#else
//详细说明查看debug版本

#define MDKLog(object)

#define MDKPrint(object)

#define NSLog(...)

#define MDKDetailLog(...)

#endif

///输出程序的基本信息,比如模拟器路径,设备信息
void MDKBaseLog();

///模拟设备被独占，线程被占用，用于测试性能
void MDKSleep(CGFloat time);


#endif

#pragma mark - 分类
#ifdef _hasUIKit
@interface UIView(MDKTool)
#define _view self.view
- (void)MDKEnableRedBackground;
@end


@interface UITableView(MDKTool)
- (void)MDKRegisterCell:(NSString *)cellName;
- (void)MDKRegisterHeader:(NSString *)headerName;
- (void)MDKRegisterFooter:(NSString *)footerName;
@end

@interface UICollectionView(MDKTool)
- (void)MDKRegisterCell:(NSString *)cellName;
- (void)MDKRegisterHeader:(NSString *)headerName;
- (void)MDKRegisterFooter:(NSString *)footerName;
@end

@interface UIFont(MDKTool)
- (UIFont*)Thin;
- (UIFont*)Bold;
@end


typedef void (^UIAlertCreateActionBlock)(UIAlertAction *createdAciton) ;
typedef void (^UIAlertHandleActionBlock)(UIAlertAction *handledAciton) ;
typedef  UIAlertController * (^MDKAddActionType)(NSString* title,UIAlertCreateActionBlock createBlock,UIAlertHandleActionBlock handlerBlock);

typedef void (^UIAlertCreateTextFieldBlock)(UITextField *createdTextField);
typedef void (^UIAlertHandleTextFieldBlock)(UITextField *handlerTextField);
typedef UIAlertController * (^MDKAddTextFieldType)(UIAlertCreateTextFieldBlock createBlock , UIAlertHandleTextFieldBlock handlerBoock);
@interface UIAlertController(quick)
@property (nonatomic, readonly, copy) MDKAddActionType MDKAddDefaultAction;
@property (nonatomic, readonly, copy) MDKAddActionType MDKAddCancelAction;
@property (nonatomic, readonly, copy) MDKAddActionType MDKAddDestructiveAction;
@property (nonatomic, readonly, copy) MDKAddTextFieldType MDKAddTextField;

- (void)MDKQuickPresented;

@end
#endif


#ifdef _hasFoundation
NSString *MDKGetPropertyName(objc_property_t property);
NSString *MDKGetPropertyType(objc_property_t property);
@interface NSObject(MDKTool)
@property (class,readonly)NSString *name;
- (void)MDKInitModel;
- (void)MDKInitModel_IfNotExists;
- (id)MDKPerformSelector:(SEL)selector withObjects:(NSArray *)objects;
@end

#define MDKGetObj(owner,property) objc_getAssociatedObject(owner, @selector(property));

#define MDKSetWeakObj(owner,property,obj) __SetObj(owner,property,obj,YES)
#define MDKSetObj(owner,property,obj) __SetObj(owner,property,obj,NO)
#define __SetObj(owner,property,obj,isWeak) do {\
if (isWeak) {\
objc_setAssociatedObject(owner, @selector(property), obj, OBJC_ASSOCIATION_ASSIGN);\
}else{\
[owner willChangeValueForKey:@#property];\
if ([obj isKindOfClass:NSString.class]) {\
objc_setAssociatedObject(owner, @selector(property), obj, OBJC_ASSOCIATION_COPY_NONATOMIC);\
}else{\
objc_setAssociatedObject(owner, @selector(property), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
}\
[owner didChangeValueForKey:@#obj];\
} while (0);
#endif


//MARK:	该GCD safe 代码来自 SDWebImage,改为内联方便调试

inline static void MDKDispatch_queue_async_safe(dispatch_queue_t queue, dispatch_block_t block){
	if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
		block();
	} else {
		dispatch_async(queue, block);
	}
}

inline static void MDKDispatch_main_async_safe(dispatch_block_t block){
	MDKDispatch_queue_async_safe(dispatch_get_main_queue(), block);
}

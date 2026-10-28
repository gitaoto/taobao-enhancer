#import <UIKit/UIKit.h>

static UIWindow *g_floatingWindow = nil;
static UIButton *g_floatingBtn = nil;

// 悬浮球点击事件处理函数
@interface TaobaoEnhancerManager : NSObject
+ (instancetype)sharedInstance;
- (void)floatingBtnTapped:(id)sender;
@end

@implementation TaobaoEnhancerManager

+ (instancetype)sharedInstance {
    static TaobaoEnhancerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TaobaoEnhancerManager alloc] init];
    });
    return instance;
}

- (void)floatingBtnTapped:(id)sender {
    // 获取当前最上层的 ViewController 弹窗
    UIWindow *targetWindow = nil;
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            targetWindow = scene.windows.firstObject;
            break;
        }
    }
    
    UIViewController *topVC = targetWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"历史价格查询" 
                                                                   message:@"已通过独立悬浮窗口成功唤醒！\n（在此处可接入慢慢买、一淘或其他比价 API 数据）" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [topVC presentViewController:alert animated:YES completion:nil];
}

@end

// 创建一个永远浮在最顶层的独立 UIWindow
static void ShowIndependentFloatingBall() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_floatingWindow) {
            g_floatingWindow.hidden = NO;
            return;
        }
        
        // 针对 iOS 13+ 多场景适配
        UIWindowScene *targetScene = nil;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                targetScene = scene;
                break;
            }
        }
        
        if (targetScene) {
            g_floatingWindow = [[UIWindow alloc] initWithWindowScene:targetScene];
        } else {
            g_floatingWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        
        // 设置极高的窗口层级，凌驾于所有 App 页面和系统弹窗之上
        g_floatingWindow.windowLevel = UIWindowLevelAlert + 1000;
        g_floatingWindow.backgroundColor = [UIColor clearColor];
        
        // 创建一个透明的 RootViewController 承载悬浮按钮
        UIViewController *emptyVC = [[UIViewController alloc] init];
        emptyVC.view.backgroundColor = [UIColor clearColor];
        g_floatingWindow.rootViewController = emptyVC;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        // 创建悬浮球
        g_floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        g_floatingBtn.frame = CGRectMake(screenWidth - 55, 380, 45, 45);
        [g_floatingBtn setTitle:@"比价" forState:UIControlStateNormal];
        [g_floatingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        g_floatingBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
        g_floatingBtn.backgroundColor = [UIColor colorWithRed:1.00 green:0.30 blue:0.00 alpha:0.92]; // 淘宝橙红
        g_floatingBtn.layer.cornerRadius = 22.5;
        g_floatingBtn.clipsToBounds = YES;
        
        // 添加阴影
        g_floatingBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        g_floatingBtn.layer.shadowOffset = CGSizeMake(0, 2);
        g_floatingBtn.layer.shadowOpacity = 0.4;
        g_floatingBtn.layer.shadowRadius = 3.0;
        
        // 绑定点击事件
        [g_floatingBtn addTarget:[TaobaoEnhancerManager sharedInstance] 
                          action:@selector(floatingBtnTapped:) 
                forControlEvents:UIControlEventTouchUpInside];
        
        [emptyVC.view addSubview:g_floatingBtn];
        
        // 显示窗口
        g_floatingWindow.hidden = NO;
    });
}


// ==========================================
// 1. App 启动或主界面加载时立即唤醒独立悬浮窗
// ==========================================
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    ShowIndependentFloatingBall();
}

%end


// ==========================================
// 2. 去开屏广告
// ==========================================
%hook TBAdManager

- (BOOL)isSplashAdEnable {
    return NO;
}

- (void)loadSplashAd {
}

%end


// ==========================================
// 3. 去更新 & 去更新提示
// ==========================================
%hook TBUpdateService

- (void)checkUpdate {
}

- (void)showUpdateAlert {
}

- (BOOL)isForceUpdate {
    return NO;
}

%end

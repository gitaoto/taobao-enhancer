#import <UIKit/UIKit.h>

static UIWindow *g_floatingWindow = nil;
static UIButton *g_floatingBtn = nil;

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
                                                                   message:@"已通过顶层常驻独立窗口成功唤醒！\n（在此处可接入慢慢买、一淘或其他比价 API 数据）" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [topVC presentViewController:alert animated:YES completion:nil];
}

@end

// 核心常驻方法：创建独立于淘宝页面的最高层级悬浮窗
static void ShowIndependentFloatingBall() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_floatingWindow && !g_floatingWindow.isHidden) {
            return;
        }
        
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
        
        // 凌驾于所有页面和弹窗之上的最高层级
        g_floatingWindow.windowLevel = UIWindowLevelAlert + 9999;
        g_floatingWindow.backgroundColor = [UIColor clearColor];
        
        UIViewController *emptyVC = [[UIViewController alloc] init];
        emptyVC.view.backgroundColor = [UIColor clearColor];
        g_floatingWindow.rootViewController = emptyVC;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        if (!g_floatingBtn) {
            g_floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            g_floatingBtn.frame = CGRectMake(screenWidth - 55, 380, 45, 45);
            [g_floatingBtn setTitle:@"比价" forState:UIControlStateNormal];
            [g_floatingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            g_floatingBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
            g_floatingBtn.backgroundColor = [UIColor colorWithRed:1.00 green:0.30 blue:0.00 alpha:0.95]; // 淘宝橙红
            g_floatingBtn.layer.cornerRadius = 22.5;
            g_floatingBtn.clipsToBounds = YES;
            
            g_floatingBtn.layer.shadowColor = [UIColor blackColor].CGColor;
            g_floatingBtn.layer.shadowOffset = CGSizeMake(0, 2);
            g_floatingBtn.layer.shadowOpacity = 0.5;
            g_floatingBtn.layer.shadowRadius = 3.0;
            
            [g_floatingBtn addTarget:[TaobaoEnhancerManager sharedInstance] 
                              action:@selector(floatingBtnTapped:) 
                    forControlEvents:UIControlEventTouchUpInside];
        }
        
        [g_floatingBtn removeFromSuperview];
        [emptyVC.view addSubview:g_floatingBtn];
        
        g_floatingWindow.hidden = NO;
        // 强制置顶
        [g_floatingWindow makeKeyAndVisible];
    });
}


// ==========================================
// 1. Hook 整个 App 的主窗口显示，确保一开机就强制加载悬浮球
// ==========================================
%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    ShowIndependentFloatingBall();
}

- (void)setHidden:(BOOL)hidden {
    %orig;
    if (hidden && self == g_floatingWindow) {
        // 防止被淘宝自身逻辑意外隐藏
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            g_floatingWindow.hidden = NO;
        });
    }
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

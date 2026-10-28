#import <UIKit/UIKit.h>

static const NSInteger kFloatingBallTag = 8881028;

// 声明点击响应函数
@interface UIButton (TaobaoEnhancerFloat)
- (void)floatingBtnTapped:(id)sender;
@end

@implementation UIButton (TaobaoEnhancerFloat)
- (void)floatingBtnTapped:(id)sender {
    // 获取当前处于活跃状态的最顶层窗口与控制器
    UIWindow *targetWindow = nil;
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            for (UIWindow *window in scene.windows) {
                if (window.isKeyWindow) {
                    targetWindow = window;
                    break;
                }
            }
            if (!targetWindow) targetWindow = scene.windows.firstObject;
            if (targetWindow) break;
        }
    }
    
    UIViewController *topVC = targetWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"历史价格查询" 
                                                                   message:@"已通过全局悬浮球成功唤醒！\n（在此处可接入慢慢买、一淘或其他比价 API 数据）" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [topVC presentViewController:alert animated:YES completion:nil];
}
@end

// 在整个 App 的最顶层 Window 上常驻一个悬浮球
static void SetupGlobalFloatingBall() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *targetWindow = nil;
        
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        targetWindow = window;
                        break;
                    }
                }
                if (!targetWindow) targetWindow = scene.windows.firstObject;
                if (targetWindow) break;
            }
        }
        if (!targetWindow) return;
        
        // 防止重复创建
        if ([targetWindow viewWithTag:kFloatingBallTag]) return;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        // 创建悬浮球（位于屏幕右侧中部，不遮挡主要内容）
        UIButton *floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.tag = kFloatingBallTag;
        floatingBtn.frame = CGRectMake(screenWidth - 55, 380, 45, 45);
        [floatingBtn setTitle:@"比价" forState:UIControlStateNormal];
        [floatingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        floatingBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
        floatingBtn.backgroundColor = [UIColor colorWithRed:1.00 green:0.30 blue:0.00 alpha:0.85]; // 淘宝橙红
        floatingBtn.layer.cornerRadius = 22.5;
        floatingBtn.clipsToBounds = YES;
        
        // 添加阴影，提升视觉质感
        floatingBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        floatingBtn.layer.shadowOffset = CGSizeMake(0, 2);
        floatingBtn.layer.shadowOpacity = 0.3;
        floatingBtn.layer.shadowRadius = 3.0;
        
        // 绑定点击事件
        [floatingBtn addTarget:floatingBtn action:@selector(floatingBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [targetWindow addSubview:floatingBtn];
        [targetWindow bringSubviewToFront:floatingBtn];
    });
}


// ==========================================
// 1. 钩住主窗口生命周期，确保悬浮球常驻
// ==========================================
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    SetupGlobalFloatingBall();
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

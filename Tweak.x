#import <UIKit/UIKit.h>

@interface UIViewController (TaobaoEnhancer)
- (void)tbEnhancer_showPriceHistory;
@end

// 声明全局按钮 Tag，避免重复创建
static const NSInteger kPriceHistoryBtnTag = 8881027;

// 现代化且安全的窗口及按钮注入逻辑
static void InjectPriceButton(UIViewController *vc) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *targetWindow = nil;
        
        // 使用 iOS 13+ 推荐的 UIWindowScene 方式获取活跃窗口
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        targetWindow = window;
                        break;
                    }
                }
                if (!targetWindow) {
                    targetWindow = scene.windows.firstObject;
                }
                if (targetWindow) break;
            }
        }
        
        if (!targetWindow) return;
        
        // 如果已经存在按钮，直接置顶并显示
        UIButton *existBtn = (UIButton *)[targetWindow viewWithTag:kPriceHistoryBtnTag];
        if (existBtn) {
            existBtn.hidden = NO;
            [targetWindow bringSubviewToFront:existBtn];
            return;
        }
        
        // 创建悬浮按钮
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        UIButton *priceHistoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        priceHistoryBtn.tag = kPriceHistoryBtnTag;
        priceHistoryBtn.frame = CGRectMake(screenWidth - 85, 180, 75, 32); // 避开顶部导航栏
        [priceHistoryBtn setTitle:@"历史价格" forState:UIControlStateNormal];
        [priceHistoryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        priceHistoryBtn.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
        priceHistoryBtn.backgroundColor = [UIColor colorWithRed:1.00 green:0.30 blue:0.00 alpha:0.92]; // 淘宝橙红
        priceHistoryBtn.layer.cornerRadius = 16.0;
        priceHistoryBtn.clipsToBounds = YES;
        
        // 绑定点击事件
        [priceHistoryBtn addTarget:vc action:@selector(tbEnhancer_showPriceHistory) forControlEvents:UIControlEventTouchUpInside];
        
        [targetWindow addSubview:priceHistoryBtn];
        [targetWindow bringSubviewToFront:priceHistoryBtn];
    });
}

static void HidePriceButton() {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            for (UIWindow *window in scene.windows) {
                UIButton *existBtn = (UIButton *)[window viewWithTag:kPriceHistoryBtnTag];
                if (existBtn) {
                    existBtn.hidden = YES;
                }
            }
        }
    });
}

// ==========================================
// 1. 商品详情页 Hook（淘宝 10.53.40 兼容）
// ==========================================
%hook TBItemDetailViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    InjectPriceButton((UIViewController *)self);
}

- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    HidePriceButton();
}

%new
- (void)tbEnhancer_showPriceHistory {
    UIViewController *rootVC = (UIViewController *)self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"价格走势" 
                                                                   message:@"已成功适配 10.53.40 版本！\n（此处可接入比价 API 或加载历史价格网页）" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [rootVC presentViewController:alert animated:YES completion:nil];
}

%end

%hook AliDetailViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    InjectPriceButton((UIViewController *)self);
}

- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    HidePriceButton();
}

%new
- (void)tbEnhancer_showPriceHistory {
    UIViewController *rootVC = (UIViewController *)self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"价格走势" 
                                                                   message:@"已成功适配 10.53.40 版本！\n（此处可接入比价 API 或加载历史价格网页）" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [rootVC presentViewController:alert animated:YES completion:nil];
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

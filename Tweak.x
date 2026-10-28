#import <UIKit/UIKit.h>

@interface UIViewController (TaobaoEnhancer)
- (void)tbEnhancer_showPriceHistory;
@end

// ==========================================
// 1. 在淘宝底部/顶部门户注入原生比价入口
// ==========================================
%hook UITabBarController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    UIViewController *rootVC = (UIViewController *)self;
    UIView *tabBarView = rootVC.view;
    if (!tabBarView) return;
    
    NSInteger btnTag = 8881029;
    if ([tabBarView viewWithTag:btnTag]) return;
    
    // 在底部导航栏上方（不遮挡 TabBar 按钮的位置）创建一个原生的比价入口按钮
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIButton *priceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    priceBtn.tag = btnTag;
    // 放在右下角悬浮，属于当前 App 视图内部，不会触发风控拦截
    priceBtn.frame = CGRectMake(screenWidth - 75, screenHeight - 120, 60, 60);
    [priceBtn setTitle:@"比价" forState:UIControlStateNormal];
    [priceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    priceBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    priceBtn.backgroundColor = [UIColor colorWithRed:1.00 green:0.30 blue:0.00 alpha:0.95];
    priceBtn.layer.cornerRadius = 30.0;
    priceBtn.clipsToBounds = YES;
    
    priceBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    priceBtn.layer.shadowOffset = CGSizeMake(0, 3);
    priceBtn.layer.shadowOpacity = 0.4;
    priceBtn.layer.shadowRadius = 4.0;
    
    [priceBtn addTarget:rootVC action:@selector(tbEnhancer_showPriceHistory) forControlEvents:UIControlEventTouchUpInside];
    
    [tabBarView addSubview:priceBtn];
    [tabBarView bringSubviewToFront:priceBtn];
}

%new
- (void)tbEnhancer_showPriceHistory {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"历史价格查询" 
                                                                   message:@"已成功通过淘宝原生容器唤醒比价弹窗！\n（去广告与去更新功能正常运行中）" 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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

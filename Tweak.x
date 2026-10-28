#import <UIKit/UIKit.h>

@interface UIViewController (TaobaoEnhancer)
- (void)tbEnhancer_showPriceHistory;
@end

static const NSInteger kPriceHistoryBtnTag = 8881027;

// 通用历史价格按钮注入函数
static void InjectPriceButtonToVC(UIViewController *vc) {
    if (!vc || ![vc isKindOfClass:[UIViewController class]]) return;
    
    // 过滤出商品详情页相关类名
    NSString *className = NSStringFromClass([vc class]);
    if (![className containsString:@"Detail"] && ![className containsString:@"Item"]) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *targetView = vc.view;
        if (!targetView) return;
        
        // 避免重复注入
        if ([targetView viewWithTag:kPriceHistoryBtnTag]) return;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        // 在详情页右上角（避开导航栏）创建历史价格按钮
        UIButton *priceHistoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        priceHistoryBtn.tag = kPriceHistoryBtnTag;
        priceHistoryBtn.frame = CGRectMake(screenWidth - 82, 140, 72, 30);
        [priceHistoryBtn setTitle:@"历史价格" forState:UIControlStateNormal];
        [priceHistoryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        priceHistoryBtn.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
        priceHistoryBtn.backgroundColor = [UIColor colorWithRed:1.00 green:0.30 blue:0.00 alpha:0.90]; // 淘宝橘红
        priceHistoryBtn.layer.cornerRadius = 15.0;
        priceHistoryBtn.clipsToBounds = YES;
        
        [priceHistoryBtn addTarget:vc action:@selector(tbEnhancer_showPriceHistory) forControlEvents:UIControlEventTouchUpInside];
        
        [targetView addSubview:priceHistoryBtn];
        [targetView bringSubviewToFront:priceHistoryBtn];
    });
}

// ==========================================
// 1. 全局广谱 Hook：覆盖淘宝 10.53.40 所有详情页容器
// ==========================================
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    InjectPriceButtonToVC(self);
}

%new
- (void)tbEnhancer_showPriceHistory {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"价格走势" 
                                                                   message:@"已成功捕获 10.53.40 页面！\n（此处可接入比价 API 或加载历史价格网页）" 
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

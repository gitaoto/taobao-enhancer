#import <UIKit/UIKit.h>

// 1. 去除更新弹窗与广告
%hook TBUpdateService
- (void)checkUpdate {
    return;
}
%end

%hook TBAdManager
- (BOOL)shouldShowAd {
    return NO;
}
%end

// 2. 商品详情页注入比价浮窗
%hook TBItemDetailViewController

- (void)viewDidLoad {
    %orig;
    UIView *selfView = self.view;
    if (selfView) {
        UIButton *priceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        priceButton.frame = CGRectMake(selfView.frame.size.width - 70, selfView.frame.size.height - 180, 50, 50);
        priceButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.0 alpha:0.9];
        [priceButton setTitle:@"比价" forState:UIControlStateNormal];
        [priceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        priceButton.layer.cornerRadius = 25;
        priceButton.clipsToBounds = YES;
        [priceButton addTarget:self action:@selector(openPriceComparison:) forControlEvents:UIControlEventTouchUpInside];
        [selfView addSubview:priceButton];
    }
}

%new
- (void)openPriceComparison:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"全网比价 & 历史价格" 
                                                                    message:@"【淘宝 v10.53.40 专属面板】\n1. 历史最高价: ¥299.00\n2. 历史最低价: ¥189.00\n3. 全网当前最低: 京东 ¥192.00" 
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    UIViewController *rootVC = self;
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    [rootVC presentViewController:alert animated:YES completion:nil];
}

%end

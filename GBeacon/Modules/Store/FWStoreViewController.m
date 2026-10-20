//
//  FWStoreViewController.m
//  FeasyBeacon
//
//  Created by wenyewei on 2020/9/11.
//  Copyright © 2020 LIDONG. All rights reserved.
//

#import "FWStoreViewController.h"
#import <WebKit/WebKit.h>
#import <AFNetworking/AFNetworking.h>

// 已经不维护此网页了2023-6-29
//#define storefeasycom @"https://store.feasycom.com/bluetooth-beacon"

#define storefeasycom @"https://www.feasycomm.com/products/"

@interface FWStoreViewController ()<WKNavigationDelegate,WKUIDelegate> {
}

@property(strong,nonatomic)WKWebView *webView;
//进度条
@property (nonatomic,strong) UIProgressView *progress;
@end

@implementation FWStoreViewController


- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (@available(iOS 13.0, *)) {
        NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]};
        
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor darkGrayColor];
        appearance.titleTextAttributes = dic;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    // 透明
    self.navigationController.navigationBar.translucent = YES;
    // navigation控件颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.title = LS(@"Store");
    [self setback];
    
    _webView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _webView.navigationDelegate = self;
    
    [self.view addSubview:_webView];
    
    self.progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 2)];
      //、  self.progress.backgroundColor = [UIColor blueColor];
        //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
        self.progress.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
        [self.view addSubview:self.progress];
    
    //添加KVO，WKWebView有一个属性estimatedProgress，就是当前网页加载的进度，所以监听这个属性。
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];

    [self loadRequest];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progress.progress = self.webView.estimatedProgress;
        if (self.progress.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progress.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progress.hidden = YES;

            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progress.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progress.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progress];
}

//加载完成
//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    NSLog(@"加载完成");
//    //加载完成后隐藏progressView
//    //self.progressView.hidden = YES;
//}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
    //加载失败同样需要隐藏progressView
    //self.progressView.hidden = YES;
}


-(void)setback{
   UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 54, 54)];
       [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      // [button setTitle:NSLocalizedString(@"feedback", nil) forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"shuaxin-2"] forState:UIControlStateNormal];
       [button addTarget:self action:@selector(loadRequest) forControlEvents:UIControlEventTouchUpInside];
       UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:button];
                self.navigationItem.rightBarButtonItem  = right;
}


-(void)loadRequest {
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] <= AFNetworkReachabilityStatusNotReachable) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS(@"NETWORK_NOT_REACHABLE") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:okAction];
        [self.navigationController presentViewController:alertController animated:YES completion:NULL];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:storefeasycom];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [_webView loadRequest:request];
}

-(void)setLeftNav
{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
   //[backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"fanhui"] forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [closeBtn setImage:[UIImage imageNamed:@"shanchu-2"] forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc]initWithCustomView:closeBtn];
    
    
    self.navigationItem.leftBarButtonItems= @[barButton,closeBarButton];
    
    

}


-(void)backBtnClick
{
    if (_webView.canGoBack) {
  
        [self setLeftNav];
        
        [_webView goBack];
    }else{
        self.navigationItem.leftBarButtonItems = nil;
    }
}

-(void)closeBtnClick
{
    self.navigationItem.leftBarButtonItems = nil;
    
    if (_webView.backForwardList.backList.count>0) {                                  //得到栈里面的list
        WKBackForwardListItem * item = _webView.backForwardList.currentItem;          //得到现在加载的list
        for (WKBackForwardListItem * backItem in _webView.backForwardList.backList) { //循环遍历，得到你想退出到
             //添加判断条件
            [_webView goToBackForwardListItem:_webView.backForwardList.backList.firstObject];
        }
    }
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if(webView.canGoBack){
        [self setLeftNav];
     }else{
        self.navigationItem.leftBarButtonItems = nil;
     }
}


//新增测试

-(void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void(^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *urlString = [navigationAction.request.URL absoluteString];
    NSLog(@"开始请求：%@ \n\n",navigationAction.request);
    NSLog(@"navigationAction: %@ \n\n", navigationAction);
    NSLog(@"urlString:%@",urlString);
    if ([urlString containsString:@"/link.html"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    NSLog(@"navigationAction.navigationType = %ld",(long)navigationAction.navigationType);
}



@end

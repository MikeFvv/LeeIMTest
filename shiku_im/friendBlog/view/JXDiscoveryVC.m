//
//  JXDiscoveryVC.m
//  shiku_im
//
//  Created by 胡勇 on 2020/2/28.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "JXDiscoveryVC.h"
#import "WeiboViewControlle.h"
#import "SDWebImageDownloader.h"
#import "RITLWebViewController.h"
#import "UIView+Frame.h"
#import "JXScanQRViewController.h"
#import "JXNearVC.h"
#import "SLPrefixHeader.pch"
#import <SafariServices/SafariServices.h>



// WKWebView 内存不释放的问题解决
@interface WeakWebViewScriptMessageDelegate : NSObject<WKScriptMessageHandler>

//WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
@implementation WeakWebViewScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
//遵循WKScriptMessageHandler协议，必须实现如下方法，然后把方法向外传递
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end



@interface JXDiscoveryVC ()<WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate,SFSafariViewControllerDelegate>
@property (nonatomic,strong)NSArray *webArray;
@property (nonatomic,strong)NSMutableArray *viewArray;
@property (nonatomic, strong) UIButton *moreBtn;


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) WKWebView *webView;
//网页加载进度视图
@property (nonatomic, strong) UIProgressView *progressView;
/// 网址
@property (nonatomic, copy) NSString *urlPath;

@property (nonatomic, strong) UIButton *goBackButton;
@property (nonatomic, strong) UIButton *homeButton;
@property (nonatomic, strong) UIButton *refreshButton;

@property (nonatomic, strong) SFSafariViewController *safariVC;

@end

@implementation JXDiscoveryVC

#define HEIGHT 56
#define MY_INSET  0  // 每行左右间隙

- (NSMutableArray *)viewArray{
    if (!_viewArray) {
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}
- (instancetype)init{
    
    self = [super init];
    if (self) {
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = NO;
        [self createHeadAndFoot];
        
        NSInteger statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH/4, statusHeight, JX_SCREEN_WIDTH*0.5, 44)];
        titleL.textAlignment = NSTextAlignmentCenter;
        
        titleL.text = Localized(@"JXMainViewController_Find");

        titleL.font = [UIFont boldSystemFontOfSize:18];
        [self.tableHeader addSubview: titleL];
        _titleLabel = titleL;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.heightFooter = JX_SCREEN_BOTTOM;
    self.tableView.backgroundColor = HEXCOLOR(0xf0eff4);
    [self initView];
    
    [self initWebView];
}


-(void)initView{
    JXImageView* iv;
        int w = JX_SCREEN_WIDTH;
        int h = self.webArray.count*HEIGHT+8;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExists = [fileManager fileExistsAtPath:filePath];
        if (isExists) {
            NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
            NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
            iv = [self createButton:XL_APP_NAME drawTop:YES drawBottom:YES icon: icon isWebImage:NO click:@selector(jumpTohtmlVC:) tag:0];
            iv.frame = CGRectMake(MY_INSET, h, w - MY_INSET*2, HEIGHT);
            h += iv.frame.size.height;
        }
    
        iv = [self createButton:Localized(@"JXUserInfoVC_Space") drawTop:YES drawBottom:YES icon: @"shenghuoquan" isWebImage:NO click:@selector(discoveryAction) tag:0];
        iv.frame = CGRectMake(MY_INSET, h, w - MY_INSET*2, HEIGHT);

        h += iv.frame.size.height;
        
        
        iv = [self createButton:Localized(@"JX_saoyisao") drawTop:NO drawBottom:YES icon: @"saoyisao" isWebImage:NO click:@selector(showScanViewController) tag:0];
        iv.frame = CGRectMake(MY_INSET, h, w - MY_INSET*2, HEIGHT);

        h += iv.frame.size.height;
        h += iv.frame.size.height;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    if (self.webArray.count == 0) {
       [g_server getDiscoverWebList:@"" toView:self];
    }
}

#pragma mark 右上角更多
-(void)onMore:(UIButton *)sender {
    
    NSMutableArray *titles = [NSMutableArray arrayWithArray:@[ Localized(@"JX_Scan"), Localized(@"JXNearVC_NearPer")]];
    NSMutableArray *images = [NSMutableArray arrayWithArray:@[ @"messaeg_scnning_black", @"message_near_person_black"]];
    NSMutableArray *sels = [NSMutableArray arrayWithArray:@[ @"showScanViewController", @"onNear"]];
    
    NSArray *role = MY_USER_ROLE;
    if ([g_App.config.hideSearchByFriends intValue] == 1 && ([g_App.config.isCommonFindFriends intValue] == 0 || role.count > 0)) {
    }else {
        [titles removeObject:Localized(@"JX_AddFriends")];
        [images removeObject:@"message_add_friend_black"];
        [sels removeObject:@"onSearch"];
    }
    if ([g_App.config.isCommonCreateGroup intValue] == 1 && role.count <= 0) {
        [titles removeObject:Localized(@"JX_LaunchGroupChat")];
        [images removeObject:@"message_creat_group_black"];
        [sels removeObject:@"onNewRoom"];
    }
    if ([g_App.config.isOpenPositionService intValue] == 1) {
        [titles removeObject:Localized(@"JXNearVC_NearPer")];
        [images removeObject:@"message_near_person_black"];
        [sels removeObject:@"onNear"];
    }
    if ([g_App.isShowRedPacket intValue] == 0) {
        [titles removeObject:Localized(@"JX_Receiving")];
        [images removeObject:@"message_near_receiving"];
        [sels removeObject:@"onReceiving"];
    }

    JX_SelectMenuView *menuView = [[JX_SelectMenuView alloc] initWithTitle:titles image:images cellHeight:45];
    menuView.sels = sels;
    menuView.delegate = self;
    [g_App.window addSubview:menuView];
}

-(void)showScanViewController {
    
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        [g_server showMsg:Localized(@"JX_CanNotopenCenmar")];
        return;
    }
    
    JXScanQRViewController * scanVC = [[JXScanQRViewController alloc] init];
    
//    [g_window addSubview:scanVC.view];
    [g_navigation pushViewController:scanVC animated:YES];
}

// 附近的人
-(void)onNear{
    JXNearVC * nearVc = [[JXNearVC alloc] init];
    [g_navigation pushViewController:nearVc animated:YES];
}

- (void)discoveryAction {
    
    WeiboViewControlle *weiboVC = [WeiboViewControlle alloc];
    weiboVC.user = g_server.myself;
    weiboVC = [weiboVC init];
    [g_navigation pushViewController:weiboVC animated:YES];
}

- (void)jumpTohtmlVC:(JXImageView *)button{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"];
    NSURL *pathURL = [NSURL fileURLWithPath:filePath];
    
    RITLWebViewController *webVC = [[RITLWebViewController alloc] init];
    webVC.url = pathURL;
    webVC.webTitle = XL_APP_NAME;
    webVC.useLeftCloseItem = YES;
    webVC.leftCloseImage = [UIImage imageNamed:@"talk_close"];
    webVC.leftCloseButtonTap = ^(RITLWebViewController * _Nonnull viewController, UIBarButtonItem * _Nonnull item) {
        [viewController.navigationController popViewControllerAnimated:YES];
        
    };
    [self.homeVC.navigationController pushViewController:webVC animated:true];
}

- (void)jumpToWebVC:(JXImageView *)button{
    
    NSInteger index = button.tag - 10;
    NSArray *array = [g_default objectForKey:@"act_GetDiscoveryWebList"];
    NSString *url = array[index][@"url"];
//    RITLWebViewController *webVC = [[RITLWebViewController alloc] init];
//    webVC.url = [NSURL URLWithString:url];
//    webVC.useLeftCloseItem = YES;
//    webVC.leftCloseImage = [UIImage imageNamed:@"talk_close"];
//    webVC.leftCloseButtonTap = ^(RITLWebViewController * _Nonnull viewController, UIBarButtonItem * _Nonnull item) {
//
//        [viewController.navigationController popViewControllerAnimated:YES];
//
//    };
//    [self.homeVC.navigationController pushViewController:webVC animated:true];
    
//    self.hidesBottomBarWhenPushed = NO;
//    SLWebViewController *webVC = [[SLWebViewController alloc] init];
//    webVC.hidesBottomBarWhenPushed = NO;
////    webVC.url = url;
//    webVC.url = @"https://www.baidu.com/";
    
//    self.urlPath = @"https://www.baidu.com/";
    self.urlPath = url;
    
//    [self showViewController:webVC sender:nil];
//    [self addChildViewController:webVC];
    
//    [self.navigationController popToViewController:webVC animated:YES];
    
//    [self.homeVC.navigationController popToViewController:webVC animated:YES];
    
    
    [self showLoadURL];
//    [self.homeVC.navigationController pushViewController:webVC animated:YES];
}


- (JXImageView*)createButton:(NSString*)title drawTop:(BOOL)drawTop drawBottom:(BOOL)drawBottom icon:(NSString*)icon isWebImage:(BOOL)isWebImage click:(SEL)click tag:(NSInteger)tag{
    
    JXImageView* btn = [[JXImageView alloc] init];
    btn.backgroundColor = [UIColor whiteColor];
    btn.userInteractionEnabled = YES;
    btn.didTouch = click;
    btn.delegate = self;
    btn.tag = tag;
    
    [self.tableView addSubview:btn];
    
    JXLabel* p = [[JXLabel alloc] initWithFrame:CGRectMake(20*2+20, 0, self_width-35-20-5, HEIGHT)];
    p.text = title;
    p.font = g_factory.font16;
    p.backgroundColor = [UIColor clearColor];
    p.textColor = HEXCOLOR(0x323232);
//    p.delegate = self;
//    p.didTouch = click;
    [btn addSubview:p];

    if(icon){
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, HEIGHT-20, HEIGHT-20)];
        if (isWebImage) {
              [iv sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"酷聊120"]];
          }
        else {
            iv.image = [UIImage imageNamed:icon];
        }
        [btn addSubview:iv];
    }
    
    if(drawTop){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,0,JX_SCREEN_WIDTH,0.3)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [btn addSubview:line];
    }
    
    if(drawBottom){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT-0.3,JX_SCREEN_WIDTH,0.3)];
        line.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [btn addSubview:line];
    }
    
    if(click){
        UIImageView* iv;
        iv = [[UIImageView alloc] initWithFrame:CGRectMake(JX_SCREEN_WIDTH-INSETS-20-3-MY_INSET, 16, 20, 20)];
        iv.image = [UIImage imageNamed:@"set_list_next"];
        [btn addSubview:iv];
        
    }
    [self.viewArray addObject: btn];
    return btn;
}


-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
 
    if ([aDownload.action isEqualToString:act_GetDiscoveryWebList]) {
        [self.viewArray removeAllObjects];
        //朋友圈列表
        [g_default setObject:array1 forKey:@"act_GetDiscoveryWebList"];
        g_config.disconverWebArray = array1;
            JXImageView* iv;
            //根据接口返回添加
            CGFloat h = 8;
            BOOL TOP = NO;
            BOOL Bottom =NO;
            NSArray *array = [g_default objectForKey:@"act_GetDiscoveryWebList"];
            
            for (NSInteger i = 0; i < array.count; i++) {
                
                NSString *icon = array[i][@"icon"];
               
                NSString *title = array[i][@"title"];
                SEL jumpToWebVC = @selector(jumpToWebVC:);
                if (i== 0) {
                    TOP = YES;
                    Bottom = YES;
                }else if (i == array.count-1){
                    
                    TOP = NO;
                    Bottom = YES;
                }else{
                    TOP = NO;
                    Bottom = YES;
                }
                if ([title isEqualToString:XL_Tabbar_Middle]) {
                    iv = [self createButton:title drawTop:TOP drawBottom:Bottom icon:@"ykdicon" isWebImage:NO click: jumpToWebVC tag:10 + i];
                }else{
                    iv = [self createButton:title drawTop:TOP drawBottom:Bottom icon:icon isWebImage:YES click: jumpToWebVC tag:10 + i];
                }
                iv.frame = CGRectMake(MY_INSET, h, JX_SCREEN_WIDTH - MY_INSET*2, HEIGHT);
                
                h += HEIGHT;
            }
         self.webArray = array1;
        [self initView];

    }
}


#pragma mark - 🔴🔴🔴 网页 🔴🔴🔴

- (void)initWebView {
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    //添加监测网页加载进度的观察者
    [self.webView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                      options:0
                      context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
//    [self showLoadURL];
}

- (void)showLoadURL {

    self.webView.hidden = NO;
    self.tableView.hidden = YES;
    self.titleLabel.text = @"";
    
    [self setupNavigationItem];
    
//    NSURL *url = [NSURL URLWithString:@"https://ethob.top/"];   // 测试

    if (!self.urlPath || self.urlPath.length==0) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:self.urlPath];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    
//    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:YES];
//    _safariVC = safariVC;
////    [self.view addSubview:safariVC.view];
//
//    safariVC.delegate = self;
//    [self.homeVC presentViewController:safariVC animated:NO completion:nil];
    
}
#pragma mark - SafariViewController

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}




- (void)showTableView {
    self.webView.hidden = YES;
    self.tableView.hidden = NO;
    self.titleLabel.text = @"发现";
    
    for(UIView *view in [self.tableHeader subviews])
    {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)dealloc {
    //移除注册的js方法
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"jsToOcNoPrams"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"jsToOcWithPrams"];
    //移除观察者
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    [_webView removeObserver:self
                  forKeyPath:NSStringFromSelector(@selector(title))];
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
//    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-TabbarHeight);
    _webView.frame = CGRectMake(0, mxwStatusNavBarHeight(), SCREEN_WIDTH, SCREEN_HEIGHT-mxwStatusNavBarHeight()-TabbarHeight);
    NSLog(@"1");
    
    
    NSLog(@"1");
}


#pragma mark - UI
- (void)setupNavigationItem {
    // 后退按钮
    UIButton * goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goBackButton setImage:[UIImage imageNamed:@"title_back_black"] forState:UIControlStateNormal];
    [goBackButton addTarget:self action:@selector(goBackAction:) forControlEvents:UIControlEventTouchUpInside];
    goBackButton.frame = CGRectMake(10, 10, 30, mxwStatusNavBarHeight());
    _goBackButton = goBackButton;
    
    // 回到首页按钮
    UIButton * homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setImage:[UIImage imageNamed:@"fd_back_home"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(localHtmlClicked:) forControlEvents:UIControlEventTouchUpInside];
    homeButton.frame = CGRectMake(60, 10, 30, mxwStatusNavBarHeight());
    _homeButton = homeButton;
    
    // 刷新按钮
    UIButton * refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setImage:[UIImage imageNamed:@"fd_refresh"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
    refreshButton.frame = CGRectMake(SCREEN_WIDTH-50, 10, 30, mxwStatusNavBarHeight());
    _refreshButton = refreshButton;
    
    [self.tableHeader addSubview: goBackButton];
    [self.tableHeader addSubview: homeButton];
    [self.tableHeader addSubview: refreshButton];
}

#pragma mark - Event Handle
- (void)goBackAction:(UIButton *)sender {
    
    if (self.webView.canGoBack == YES) {
        [self.webView goBack];
    } else {
        [self showTableView];
//        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)localHtmlClicked:(UIButton *)sender {
    
    NSURL *url = [NSURL URLWithString:self.urlPath];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}
- (void)refreshAction:(UIButton *)sender {
    [_webView reload];
}
//OC调用JS
- (void)ocToJs{
    //changeColor()是JS方法名，completionHandler是异步回调block
    NSString *jsString = [NSString stringWithFormat:@"changeColor('%@')", @"Js颜色参数"];
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"改变HTML的背景色");
    }];
    
    //改变字体大小 调用原生JS方法
    NSString *jsFont = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", arc4random()%99 + 100];
    [_webView evaluateJavaScript:jsFont completionHandler:nil];
    
    NSString * path =  [[NSBundle mainBundle] pathForResource:@"girl" ofType:@"png"];
    NSString *jsPicture = [NSString stringWithFormat:@"changePicture('%@','%@')", @"pictureId",path];
    [_webView evaluateJavaScript:jsPicture completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"切换本地头像");
    }];
    
}

#pragma mark - KVO
//kvo 监听进度 必须实现此方法
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _webView) {
        
        NSLog(@"网页加载进度 = %f",_webView.estimatedProgress);
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
            });
        }
        
    }else if([keyPath isEqualToString:@"title"]
             && object == _webView){
        self.navigationItem.title = _webView.title;
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


#pragma mark - Getter
- (UIProgressView *)progressView {
    if (!_progressView){
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 2, self.view.frame.size.width, 1.5)];
        _progressView.tintColor = [UIColor blueColor];
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}
- (WKWebView *)webView{
    if(_webView == nil){
        
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        //最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
        preference.minimumFontSize = 0;
        //设置是否支持javaScript 默认是支持的
        preference.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        
        // 是使用h5的视频播放器在线播放, 还是使用原生播放器全屏播放
        config.allowsInlineMediaPlayback = YES;
        //设置视频是否需要用户手动播放  设置为NO则会允许自动播放
        config.requiresUserActionForMediaPlayback = YES;
        //设置是否允许画中画技术 在特定设备上有效
        config.allowsPictureInPictureMediaPlayback = YES;
        //设置请求的User-Agent信息中应用程序名称 iOS9后可用
        config.applicationNameForUserAgent = @"ChinaDailyForiPad";
        
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        //这个类主要用来做native与JavaScript的交互管理
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        //注册一个name为jsToOcNoPrams的js方法 设置处理接收JS方法的对象
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcNoPrams"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcWithPrams"];
        
        config.userContentController = wkUController;
        
        //以下代码适配文本大小
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        //用于进行JavaScript注入
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [config.userContentController addUserScript:wkUScript];
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-mxwStatusNavBarHeight()-TabbarHeight) configuration:config];
        // UI代理
        _webView.UIDelegate = self;
        // 导航代理
        _webView.navigationDelegate = self;
        // 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
        //可返回的页面列表, 存储已打开过的网页
        WKBackForwardList * backForwardList = [_webView backForwardList];
        
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlPath]];
        [request addValue:[self readCurrentCookieWithDomain:self.urlPath] forHTTPHeaderField:@"Cookie"];
        [_webView loadRequest:request];
        
        _webView.hidden = YES;
        
//        NSURL *url = [NSURL URLWithString:@"https://www.baidu.com/"];
//        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        
        
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"JStoOC.html" ofType:nil];
//        NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//        [_webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
        
    }
    return _webView;
}

//解决第一次进入的cookie丢失问题
- (NSString *)readCurrentCookieWithDomain:(NSString *)domainStr{
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString * cookieString = [[NSMutableString alloc]init];
    for (NSHTTPCookie*cookie in [cookieJar cookies]) {
        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
    }
    
    //删除最后一个“;”
    if ([cookieString hasSuffix:@";"]) {
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    }
    
    return cookieString;
}

//解决 页面内跳转（a标签等）还是取不到cookie的问题
- (void)getCookie{
    
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";
    
    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    //执行js
    [_webView evaluateJavaScript:JSCookieString completionHandler:nil];
    
}

//被自定义的WKScriptMessageHandler在回调方法里通过代理回调回来，绕了一圈就是为了解决内存不释放的问题
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    //用message.body获得JS传出的参数体
    NSDictionary * parameter = message.body;
    //JS调用OC
    if([message.name isEqualToString:@"jsToOcNoPrams"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:@"不带参数" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else if([message.name isEqualToString:@"jsToOcWithPrams"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:parameter[@"params"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

#pragma mark - WKNavigationDelegate
/*
 WKNavigationDelegate主要处理一些跳转、加载处理操作，WKUIDelegate主要处理JS脚本，确认框，警告框等
 */

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self getCookie];
}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}

// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString * urlStr = navigationAction.request.URL.absoluteString;
    NSLog(@"发送跳转请求：%@",urlStr);
    //自己定义的协议头
    NSString *htmlHeadString = @"github://";
    if([urlStr hasPrefix:htmlHeadString]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"通过截取URL调用OC" message:@"你想前往我的Github主页?" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }])];
        [alertController addAction:([UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL * url = [NSURL URLWithString:[urlStr stringByReplacingOccurrencesOfString:@"github://callName_?" withString:@""]];
            [[UIApplication sharedApplication] openURL:url];
            
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
    
}

// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}

//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    //用户身份信息
    NSURLCredential * newCred = [[NSURLCredential alloc] initWithUser:@"user123" password:@"123" persistence:NSURLCredentialPersistenceNone];
    //为 challenge 的发送方提供 credential
    [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
    
}

//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    
}

#pragma mark - WKUIDelegate

/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param completionHandler 警告框消失调用
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"HTML的弹出框" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 确认框
//JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 输入框
//JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 页面是弹出窗口 _blank 处理
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}


@end

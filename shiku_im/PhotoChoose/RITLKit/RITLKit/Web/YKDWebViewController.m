//
//  WebViewController.m
//  DebtFinance
//
//  Created by ZYL on 2017/6/23.
//  Copyright © 2017年 DropletFinance. All rights reserved.
//

#import "YKDWebViewController.h"
#import <WebKit/WebKit.h>
@interface YKDWebViewController ()<WKNavigationDelegate,WKUIDelegate>

@property (weak, nonatomic) WKWebView *webView;

@property (nonatomic,strong)NSArray *webArray;

@property (nonatomic,strong)UILabel *navTitleLabel;
@end

@implementation YKDWebViewController
- (instancetype)init{
    
    self = [super init];
    if (self) {
        //self.view.frame = CGRectMake(JX_SCREEN_WIDTH, 0, JX_SCREEN_WIDTH, JX_SCREEN_HEIGHT);
        self.heightHeader = JX_SCREEN_TOP;
        self.heightFooter = 0;
        self.isGotoBack = YES;
        [self createHeadAndFoot];
        [_table removeFromSuperview];
        
        NSInteger statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(JX_SCREEN_WIDTH/4, statusHeight, JX_SCREEN_WIDTH*0.5, 44)];
        titleL.textAlignment = NSTextAlignmentCenter;
        
        titleL.text = XL_Tabbar_Middle;
        titleL.font = [UIFont boldSystemFontOfSize:18];
        _navTitleLabel = titleL;
        [self.tableHeader addSubview: titleL];
    }
    return self;
}
-(void)actionQuit{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    if (self.webArray.count == 0) {
       [g_server getDiscoverWebList:@"" toView:self];
    }
    
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebView *webView = [[WKWebView alloc]initWithFrame:self.view.frame];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    if (!self.provider) {
        self.provider = [[self genUrl] host];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    [label setText:[[NSString alloc] initWithFormat:@"此网页由%@提供", self.provider]];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [self.webView insertSubview:label atIndex:0];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[self genUrl]];
    [self.webView loadRequest:request];
}

- (NSURL *)genUrl {
    if ([self.urlString hasPrefix:@"http:"] || [self.urlString hasPrefix:@"https:"]) {
        return [NSURL URLWithString:self.urlString];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://", self.urlString]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"])
    {
        if (object == self.webView)
        {
            _navTitleLabel.text = self.webView.title;
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void) didServerResultSucces:(JXConnection*)aDownload dict:(NSDictionary*)dict array:(NSArray*)array1{
 
    if ([aDownload.action isEqualToString:act_GetDiscoveryWebList]) {
        if (self.webArray.count == 0) {
            self.webArray = array1;
        }
        
        for (NSDictionary *obj in self.webArray) {
            NSString *title = obj[@"title"];
            NSString *urlStr = obj[@"url"];
            if ([title isEqualToString:XL_Tabbar_Middle]) {
                self.urlString = urlStr;
                
                NSURLRequest *request =[NSURLRequest requestWithURL:[self genUrl]];
                [self.webView loadRequest:request];
            }
        }
    }
}
- (void)dealloc
{
    _webView.navigationDelegate = nil;
    [_webView removeObserver:self forKeyPath:@"title"];
    _webView = nil;
}
@end

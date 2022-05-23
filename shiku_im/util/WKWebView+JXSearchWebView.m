//
//  WKWebView+JXSearchWebView.m
//  shiku_im
//
//  Created by liangjian on 2020/3/31.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "WKWebView+JXSearchWebView.h"

//#import <AppKit/AppKit.h>


@implementation WKWebView (JXSearchWebView)
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str index:(NSInteger)index
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self evaluateJavaScript:jsCode completionHandler:nil];
    
//    [self stringByEvaluatingJavaScriptFromString:jsCode];
    
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@', '%ld')",str,(long)index];
//    [self stringByEvaluatingJavaScriptFromString:startSearch];
    [self evaluateJavaScript:startSearch completionHandler:nil];
    
    
    [self evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id obj, NSError * _Nullable error) {

     
        

    }];
    __block NSString *result = @"0";
    
    [self evaluateJavaScript:@"MyApp_SearchResultCount" completionHandler:^(id obj, NSError * _Nullable error) {
        if ([obj isKindOfClass:[NSString class]]) {
            result = obj;
        }
    }];

//    NSString *result = [self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount"];
    return [result integerValue];
}

- (void)removeAllHighlights
{
    [self evaluateJavaScript:@"MyApp_RemoveAllHighlights()" completionHandler:nil];
//    [self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
}
@end

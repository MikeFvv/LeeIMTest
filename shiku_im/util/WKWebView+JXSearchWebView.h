//
//  WKWebView+JXSearchWebView.h
//  shiku_im
//
//  Created by liangjian on 2020/3/31.
//  Copyright © 2020 Reese. All rights reserved.
//

//#import <AppKit/AppKit.h>


#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (JXSearchWebView)
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str index:(NSInteger)index;
- (void)removeAllHighlights;
@end

NS_ASSUME_NONNULL_END

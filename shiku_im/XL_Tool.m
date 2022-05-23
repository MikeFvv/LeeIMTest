//
//  XL_Tool.m
//  shiku_im
//
//  Created by 张艺露 on 2021/5/20.
//  Copyright © 2021 Reese. All rights reserved.
//

#import "XL_Tool.h"

@implementation XL_Tool
//是否隐藏此消息
+(BOOL)isHiddenMsg:(NSString *)msg{
    BOOL isHidden = NO;
    for (NSString *obj in XL_Hidden_System_Message_List ) {
        if ([msg containsString:obj]) {
            isHidden = YES;
        }
    }
    return isHidden;
}
@end

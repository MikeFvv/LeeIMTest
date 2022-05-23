//
//  AgoraModel.h
//  shiku_im
//
//  Created by liangjian on 2020/3/4.
//  Copyright © 2020 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraModel : NSObject
@property (copy, nonatomic)NSString *appId;
@property (copy, nonatomic)NSString *channel;
@property (copy, nonatomic)NSString *ownToken;
@property (copy, nonatomic)NSString *uid;
@end

NS_ASSUME_NONNULL_END

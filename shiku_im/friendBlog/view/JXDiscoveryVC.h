//
//  JXDiscoveryVC.h
//  shiku_im
//
//  Created by 胡勇 on 2020/2/28.
//  Copyright © 2020 Reese. All rights reserved.
//

#import "JXTableViewController.h"

#import "JXMainViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface JXDiscoveryVC : JXTableViewController

@property(nonatomic,strong) JXUserObject* user;

@property(nonatomic,strong) JXMainViewController *homeVC;
@end

NS_ASSUME_NONNULL_END

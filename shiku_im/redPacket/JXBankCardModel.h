//
//  JXBankCardModel.h
//  shiku_im
//
//  Created by 胡勇 on 2020/1/11.
//  Copyright © 2020 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXBankCardModel : NSObject

@property (nonatomic, strong) NSString *bankBrandId;
@property (nonatomic, strong) NSString *bankBrandName;
@property (nonatomic, strong) NSString *cardName;
@property (nonatomic, strong) NSString *cardNo;
@property (nonatomic, strong) NSString *cardType;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *isDeleted;
@property (nonatomic, strong) NSString *openBankAddr;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *userName;



@end

NS_ASSUME_NONNULL_END

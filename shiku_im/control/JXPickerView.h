//
//  JXPickerView.h
//  shiku_im
//
//  Created by aaa on 2019/12/29.
//  Copyright © 2019 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXPickerView : UIView

@property(nonatomic,strong) NSString *hint;

@property(nonatomic,strong) UIPickerView *pickerView;
@property(nonatomic,weak) id delegate;
@property(nonatomic,weak) id dataSource;
@property(nonatomic, assign) SEL didSelect;
@property(assign) SEL didCancel;

@property (nonatomic, strong) UIButton *confirmButton;


@end

NS_ASSUME_NONNULL_END

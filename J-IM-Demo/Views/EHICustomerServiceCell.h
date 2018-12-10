//
//  EHICustomerServiceCell.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/30.
//  Copyright © 2018 yogurts. All rights reserved.
//
//  消息cell
//

#import <UIKit/UIKit.h>
#import "EHICustomerServiceModel.h"

@interface EHICustomerServiceCell : UITableViewCell

/** model */
@property (nonatomic, strong) EHICustomerServiceModel *model;

/** 播放视频 */
@property (nonatomic, copy) void (^voicePlay)(void);

@end

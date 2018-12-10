//
//  EHINewCustomerSeerviceTools.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/7.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHINewCustomerSeerviceTools.h"

@implementation EHINewCustomerSeerviceTools

+ (BOOL)isIphoneX {
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets;
        if (safeAreaInsets.top ||
            safeAreaInsets.left ||
            safeAreaInsets.bottom ||
            safeAreaInsets.right) {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

+ (CGFloat)getBottomDistance {
    if ([self isIphoneX]) {
        return 34.f;
    }
    return .0f;
}


@end

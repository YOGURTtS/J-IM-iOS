//
//  LabelTool.h
//  UILabel的使用

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LabelTool : NSObject

+(CGSize)sizeOfStr:(NSString *)str andFont:(UIFont *)font andMaxSize:(CGSize)size andLineBreakMode:(NSLineBreakMode)mode;

+(UIImage*)changeSizeOfImgKeepScale:(UIImage*)sourceImg andMaxLength:(NSInteger)maxWidth andMaxHeight:(NSInteger)maxheight;

+(UIImage*)changeSizeOfImg:(UIImage*)sourceImg andWidth:(NSInteger)width andHeight:(NSInteger)height;

+ (NSString *)TransformToUTF8EncodingWithStr:(NSString *)sourceStr;
+(CGSize)sizeWithString:(NSString *)string font:(UIFont *)font andMaxSize:(CGSize)size;

@end










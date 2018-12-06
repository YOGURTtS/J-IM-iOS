//
//  LabelTool.m
//  UILabel的使用


#import "LabelTool.h"
@implementation LabelTool


//做ios版本之间的适配
//不同的ios版本,调用不同的方法,实现相同的功能
+(CGSize)sizeOfStr:(NSString *)str andFont:(UIFont *)font andMaxSize:(CGSize)size andLineBreakMode:(NSLineBreakMode)mode
{
   // NSLog(@"版本号:%f",[[[UIDevice currentDevice]systemVersion]doubleValue]);
    CGSize s;
    if ([[[UIDevice currentDevice]systemVersion]doubleValue]>=7.0) {
       // NSLog(@"ios7以后版本");
//        NSDictionary *dic=@{NSFontAttributeName:font};
        NSMutableDictionary  *mdic=[NSMutableDictionary dictionaryWithCapacity:2];
        [mdic setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
        [mdic setObject:font forKey:NSFontAttributeName];
        s = [str boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:mdic context:nil].size;
    }
    else
    {
       // NSLog(@"ios7之前版本");
        s=[str sizeWithFont:font constrainedToSize:size lineBreakMode:mode];
    }
    return s;
}
+(CGSize)sizeWithString:(NSString *)string font:(UIFont *)font andMaxSize:(CGSize)size{
    CGSize stringSize = [string sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    return stringSize;
}


#pragma mark  --改变图片大小,保持图片的长宽比
+(UIImage*)changeSizeOfImgKeepScale:(UIImage*)sourceImg andMaxLength:(NSInteger)maxWidth andMaxHeight:(NSInteger)maxheight
{
    float width=sourceImg.size.width;
    float height=sourceImg.size.height;
    
    if (width<=maxWidth && height<=maxheight) {
        return sourceImg;
    }
    
    if (width/height<=maxWidth/maxheight) {
        return [LabelTool changeSizeOfImg:sourceImg andWidth:maxheight/height*width andHeight:maxheight];
    }
    if (width/height>=maxWidth/maxheight) {
        return [LabelTool changeSizeOfImg:sourceImg andWidth:maxWidth andHeight:maxWidth/width*height];
    }
    return nil;
}

#pragma mark --改变图片的大小--
+(UIImage*)changeSizeOfImg:(UIImage*)sourceImg andWidth:(NSInteger)width andHeight:(NSInteger)height
{
    CGSize size=CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    //获取上下文内容
    CGContextRef ctx= UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    //重绘image
    CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, size.width, size.height), sourceImg.CGImage);
    //根据指定的size大小得到新的image
    UIImage* scaled= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaled;
}

+ (NSString *)TransformToUTF8EncodingWithStr:(NSString *)sourceStr
{
  NSString *str = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)sourceStr, NULL, NULL,  kCFStringEncodingUTF8 ));
    
    return str;
}





@end









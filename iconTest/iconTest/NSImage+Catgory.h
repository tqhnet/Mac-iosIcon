//
//  NSImage+Catgory.h
//  MacIconTest
//
//  Created by tqh on 2018/5/28.
//  Copyright © 2018年 tqh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Catgory)

//生成指定大小的图片
- (NSImage*)reSize:(NSSize)resize;

//保存图片到指定路径
- (void)saveAtPath:(NSString*)path;

@end

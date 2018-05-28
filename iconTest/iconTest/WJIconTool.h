//
//  WJIconTool.h
//  iconTest
//
//  Created by tqh on 2018/5/28.
//  Copyright © 2018年 tqh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJIconTool : NSObject

//打开文件
- (void)openFile:(void(^)(NSString * file))fileStr;

//导出压缩文件
- (void)createIconWithFile:(NSString *)file;

@end

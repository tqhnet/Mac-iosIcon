//
//  WJIconTool.m
//  iconTest
//
//  Created by tqh on 2018/5/28.
//  Copyright © 2018年 tqh. All rights reserved.
//

#import "WJIconTool.h"
#import "NSImage+Catgory.h"
#import "SSZipArchive.h"

@implementation WJIconTool

- (void)openFile:(void(^)(NSString * file))fileStr {
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    //是否可以创建文件夹
    panel.canCreateDirectories = YES;
    //是否可以选择文件夹
    panel.canChooseDirectories = YES;
    //是否可以选择文件
    panel.canChooseFiles = YES;
    
    //是否可以多选
    [panel setAllowsMultipleSelection:NO];
    
    //显示
    [panel beginWithCompletionHandler:^(NSInteger result) {
        
        //是否点击open 按钮
        if (result == NSModalResponseOK) {
            NSString *pathString = [panel.URLs.firstObject path];
            if (fileStr) {
                fileStr(pathString);
            }
        }
    }];
}

- (void)createIconWithFile:(NSString *)file {
    if (file.length==0) {
        return;
    }
    
    NSString *plist =[[NSBundle mainBundle] pathForResource:@"ImageCore" ofType:@"plist"];
    NSImage *image = [[NSImage alloc]initWithContentsOfFile:file];
//    NSImage
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plist];
    NSDictionary *iphone = dic[@"iPhone"];
    
    NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
    NSMutableArray *imagejsonArr = [NSMutableArray array];
    
    [iphone enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSArray *  _Nonnull obj, BOOL * _Nonnull stop) {
        //每种尺寸的1,@2x,@3x
        CGFloat width = [key floatValue];
        
        [obj enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop1) {
            NSInteger multiple = [obj1 integerValue];
            NSImage *newImage = [image reSize:CGSizeMake(multiple*width, multiple*width)];
            NSString *keyDic = nil;
            if (multiple == 1) {
                keyDic = [NSString stringWithFormat:@"%@.png",key];
            }else {
                keyDic = [NSString stringWithFormat:@"%@@%ldx.png",key,multiple];
            }
            //添加绑定文件
            [imagejsonArr addObject:@{@"size":[NSString stringWithFormat:@"%@x%@",key,key],
                                      @"idiom":@"iphone",
                                      @"filename":keyDic,
                                      @"scale":[NSString stringWithFormat:@"%ldx",multiple]
                                      }];
            
            [imageDic setObject:newImage forKey:keyDic];
        }];
    }];
    //    NSLog(@"%@",imagejsonArr);
    
    //---------------------------------储存-------------------------------------------
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    [jsonDic setObject:@{@"version":@1,@"author":@"xcode"} forKey:@"info"];
    [jsonDic setObject:@{@"pre-rendered":@(YES)} forKey:@"properties"];
    [jsonDic setObject:imagejsonArr forKey:@"images"];
    //    NSLog(@"%@",jsonDic);
    //写入沙盒文件
    
    NSString *path = [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSLog(@"%@",path);
    NSString *dataFilePath = [path stringByAppendingPathComponent:@"icon_images"];
    
    NSError *parseError = nil;
    //NSJSONWritingPrettyPrinted是没有换行符的
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //    NSLog(@"%@",jsonStr);
    
    //---------------------------------储存-------------------------------------------
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:dataFilePath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        // 在Document目录下创建一个archiver目录
        [fileManager createDirectoryAtPath:dataFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [imageDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSImage * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *file = [NSString stringWithFormat:@"%@/%@",dataFilePath,key];
        [obj saveAtPath:file];
    }];
    
    NSString *zipfile = [NSString stringWithFormat:@"%@/icon_images.zip",path];
    NSString *jsonFile = [NSString stringWithFormat:@"%@/Contents.json",dataFilePath];
    NSError *jsonError = nil;
    [jsonStr writeToFile:jsonFile atomically:YES encoding:NSUTF8StringEncoding error:&jsonError];
    //    NSLog(@"%@",jsonError);
    
    if ([SSZipArchive createZipFileAtPath:zipfile withContentsOfDirectory:dataFilePath]) {
        //移除原来文件夹
        [fileManager removeItemAtPath:dataFilePath error:nil];
        //将压缩文件转位data拷贝到制定路径
        NSData *data = [NSData dataWithContentsOfFile:zipfile];
        [self downLoadFile:data fileName:@"icon_images"];
        //移除原来的压缩文件
        [fileManager removeItemAtPath:zipfile error:nil];
    }else {
        
    }
}


- (void)downLoadFile:(NSData *)file fileName:(NSString *)fileName
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    panel.title = @"保存文件";
    [panel setMessage:@"选择文件保存地址"];//提示文字
    
    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];//设置默认打开路径
    [panel setNameFieldStringValue:fileName];
    [panel setAllowsOtherFileTypes:YES];
    [panel setAllowedFileTypes:@[@"zip"]];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK)
        {
            NSString *path = [[panel URL] path];
            BOOL result =  [file writeToFile:path atomically:YES];
            
            NSString * downloadResult;
            if(result){
                downloadResult = @"下载成功！";
            }else{
                downloadResult = @"下载失败！请稍后再试！";
            }
        }
    }];
}

@end

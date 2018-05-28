//
//  ViewController.m
//  iconTest
//
//  Created by tqh on 2018/5/28.
//  Copyright © 2018年 tqh. All rights reserved.
//

#import "ViewController.h"
#import "NSImage+Catgory.h"
#import "SSZipArchive.h"
#import "WJIconTool.h"

@interface ViewController()

@property (weak) IBOutlet NSButton *openButton;
@property (weak) IBOutlet NSButton *downButton;
@property (weak) IBOutlet NSTextField *textLabel;
@property (nonatomic,strong) WJIconTool *tool;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)openButtonPressed:(NSButton *)sender {
    __weak typeof(self) myself = self;
    [self.tool openFile:^(NSString *file) {
        myself.textLabel.stringValue = file;
    }];
}
- (IBAction)downButtonPressed:(NSButton *)sender {
    [self.tool createIconWithFile:self.textLabel.stringValue];
}

#pragma mark - 懒加载

- (WJIconTool *)tool {
    if (!_tool) {
        _tool = [WJIconTool new];
    }
    return _tool;
}

@end

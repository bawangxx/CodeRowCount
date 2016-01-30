//
//  ViewController.m
//  CodeRowCount
//
//  Created by zhiwei on 16/1/29.
//  Copyright © 2016年 zhiwei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()<NSPathControlDelegate>

@property (weak) IBOutlet NSPathControl *pathControl;
@property (weak) IBOutlet NSTextField *codeCountLabel;

@property (weak) IBOutlet NSPopUpButton *popButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.popButton removeAllItems];
    [self.popButton addItemsWithTitles:@[@"Object-C",@"Swift"]];
    
    self.pathControl.delegate = self;
    
    NSPathComponentCell *componentCell = [[NSPathComponentCell alloc] init];
    
    NSImage *iconImage = [NSImage imageNamed:@"icon"];
    componentCell.image = iconImage;
    [componentCell setTitle:@"请将Xcode工程拖到此处"];
    [self.pathControl setPathComponentCells:@[componentCell]];
   
}


- (IBAction)popBtn:(NSPopUpButton *)sender {
    
    NSLog(@"%ld",(long)sender.indexOfSelectedItem);
    
}


#pragma mark - 重置
//- (IBAction)reset:(NSButton *)sender {
//    
//    NSPathComponentCell *componentCell = [[NSPathComponentCell alloc] init];
//    
//    NSImage *iconImage = [NSImage imageNamed:@"icon"];
//    componentCell.image = iconImage;
//    [componentCell setURL:[NSURL URLWithString:@""]];
//    [componentCell setTitle:@"请将Xcode工程拖到此处"];
//    [self.pathControl setPathComponentCells:@[componentCell]];
//    self.codeCountLabel.stringValue = @"0";
//}


-(void)executeTerminal:(NSString *)path{
    
    //终端命令1
    NSTask *task = [NSTask new];
    task.currentDirectoryPath = path;
    [task setLaunchPath:@"/usr/bin/find"];
    
    NSLog(@"%ld",(long)self.popButton.indexOfSelectedItem);
    if (self.popButton.indexOfSelectedItem == 0) {
        [task setArguments:@[@".",@"-name",@"*.m"]];
    }else{
        [task setArguments:@[@".",@"-name",@"*.swift"]];
    }
    
    
    //终端命令2
    NSTask *task2 = [NSTask new];
    task2.currentDirectoryPath = path;
    [task2 setLaunchPath:@"/usr/bin/xargs"];
    [task2 setArguments:@[@"wc",@"-l"]];
    
    
    
    //创建一个管道
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    //将前面task的输出给管道
    [task setStandardOutput: pipe];
    //给task2设置管道
    [task2 setStandardInput:pipe];
    
    
    [task launch];
    
    
    NSPipe *pipe2;
    pipe2 = [NSPipe pipe];
    //将前面task的输出给管道
    [task2 setStandardOutput: pipe2];
    
    
    [task2 launch];
    
    
    //写入到文件
    NSFileHandle *file;
    file = [pipe2 fileHandleForReading];
    
    
    
    
    //读取文件成二进制
    NSData *data;
    data = [file readDataToEndOfFile];
    
    
    
    NSString *string;
    string = [[NSString alloc] initWithData: data
                                   encoding: NSUTF8StringEncoding];
        NSLog (@"got-----%@", string);
    
    
    NSArray *array = [string componentsSeparatedByString:@" "];
    
    
    NSLog(@"%@",array[array.count-2]);
    
    
    self.codeCountLabel.stringValue = array[array.count-2];
}

#pragma mark - 执行代码统计命令
- (IBAction)pathControlAction:(NSPathControl *)sender {
    
    
    [self executeTerminal:sender.URL.path];
    
}

#pragma mark - NSPathControlDelegate
//- (NSDragOperation)pathControl:(NSPathControl *)pathControl validateDrop:(id <NSDraggingInfo>)info
//{
//    [self executeTerminal:pathControl.URL.path];
//    return NSDragOperationCopy;
//}



//- (BOOL)pathControl:(NSPathControl *)pathControl shouldDragItem:(NSPathControlItem *)pathItem withPasteboard:(NSPasteboard *)pasteboard; {
//    
//    return NO;
//    
//}
//- (BOOL)pathControl:(NSPathControl *)pathControl shouldDragPathComponentCell:(NSPathComponentCell *)pathComponentCell withPasteboard:(NSPasteboard *)pasteboard; {
//    
//    
//    return NO;
//    
//}

//- (BOOL)pathControl:(NSPathControl *)pathControl acceptDrop:(id <NSDraggingInfo>)info;{
//    return YES;
//}
//
//- (void)pathControl:(NSPathControl *)pathControl willDisplayOpenPanel:(NSOpenPanel *)openPanel;{
//    
//    
//}
//
//- (void)pathControl:(NSPathControl *)pathControl willPopUpMenu:(NSMenu *)menu;{
//    
//    
//}




@end

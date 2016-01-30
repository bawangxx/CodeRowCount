//
//  ViewController.m
//  CodeRowCount
//
//  Created by zhiwei on 16/1/29.
//  Copyright © 2016年 zhiwei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()<NSPathControlDelegate>
@property (weak) IBOutlet NSPathControl *standardControl;

@property (weak) IBOutlet NSPathControl *pathControl;
@property (weak) IBOutlet NSTextField *codeCountLabel;

@property (weak) IBOutlet NSPopUpButton *popButton;


@property (nonatomic,strong) NSMutableArray *nameArray;
@property (nonatomic,strong) NSMutableArray *rowCount;
@property (nonatomic,strong) NSMutableArray *complete;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化数组
    self.nameArray = [NSMutableArray array];
    self.rowCount = [NSMutableArray array];
    self.complete = [NSMutableArray array];
    

    [self setupUI];
   
}

#pragma mark - 设置界面
-(void)setupUI{
    [self.popButton removeAllItems];
    [self.popButton addItemsWithTitles:@[@"Object-C",@"Swift"]];
    
    self.pathControl.delegate = self;
    
    NSPathComponentCell *componentCell = [[NSPathComponentCell alloc] init];
    
    NSImage *iconImage = [NSImage imageNamed:@"icon"];
    componentCell.image = iconImage;
    [componentCell setTitle:@"请将Xcode工程拖到此处"];
    [self.pathControl setPathComponentCells:@[componentCell]];
    [self.standardControl setPathComponentCells:@[componentCell]];
    
}

#pragma mark - 选择编程语言
- (IBAction)popBtn:(NSPopUpButton *)sender {
    
    NSLog(@"%ld",(long)sender.indexOfSelectedItem);
    
}

#pragma mark - 标准代码行数
- (IBAction)standardControlAction:(NSPathControl *)sender {
    
    NSString *str = [[self executeTerminal:sender.URL.path] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.codeCountLabel.stringValue = str;
    
    NSLog(@"----->%ld",(long)[self.codeCountLabel.stringValue integerValue]);

}


#pragma mark - 执行查询代码行数命令
-(NSString *)executeTerminal:(NSString *)path{
    
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
    
    return array[array.count-2];
}


-(NSString *)getTaskString:(NSTask *)task{
    
    //创建一个管道
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    //将前面task的输出给管道
    [task setStandardOutput: pipe];
    
    [task launch];
    
    //写入到文件
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    
    
    
    //读取文件成二进制
    NSData *data;
    data = [file readDataToEndOfFile];
    
    
    
    NSString *string;
    string = [[NSString alloc] initWithData: data
                                   encoding: NSUTF8StringEncoding];
    
    return string;
}

#pragma mark - 拖文件夹到pathControl时执行
- (IBAction)pathControlAction:(NSPathControl *)sender {
    

    //终端命令:列举所有姓名目录
    NSTask *task = [NSTask new];
    task.currentDirectoryPath = sender.URL.path;
    [task setLaunchPath:@"/bin/ls"];
    
    NSString *str = [self getTaskString:task];
    
    NSArray *tempArray = [str componentsSeparatedByString:@"\n"];
    self.nameArray = [NSMutableArray arrayWithArray:tempArray];
    [self.nameArray removeLastObject];
    
    //终端命令:计算每个目录的代码行数
    for (NSString *name in self.nameArray) {
        NSString *path = [NSString stringWithFormat:@"%@/%@",sender.URL.path,name];
        NSString *count = [self executeTerminal:path];
        NSString *tempCount = [count stringByReplacingOccurrencesOfString:@" " withString:@""];
       
        
        NSString *comp = [NSString stringWithFormat:@"%0.2f",([tempCount doubleValue]/[self.codeCountLabel.stringValue doubleValue])*100];
        comp = [comp stringByAppendingString:@"%"];
        
        //将每个人的代码量加到数组
        [self.rowCount addObject:count];
        
        //将每个人的完成度加到数组
        [self.complete addObject:comp];

    }
    
    NSString *writeStr = @"姓名 :\t  代码行数 :\t 完成度:\n";
    for (int i = 0; i<self.nameArray.count; i++) {
        
        NSLog(@"%@ : %@ :%@",self.nameArray[i],self.rowCount[i],self.complete[i]);
    
        NSString *temStr = [NSString stringWithFormat:@"%@\t  %@\t\t %@\n",self.nameArray[i],self.rowCount[i],self.complete[i]];
        writeStr = [writeStr stringByAppendingString:temStr];
        
        
    }
    
    [self writeStringToFile:writeStr];

    

}


#pragma mark - 将字符串写到文件
-(void) writeStringToFile:(NSString *)str{
    
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingString:@"/studentCode.txt"];
    NSLog(@"path = %@",path);
    NSError *error;
    [str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"导出失败:%@",error);
    }else{
        NSLog(@"导出成功");
    }
}

#pragma mark - 查看统计结果
- (IBAction)seeResult:(NSButton *)sender {
    
    NSTask *task = [NSTask new];
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES).firstObject;
    
    task.currentDirectoryPath = path;
    [task setLaunchPath:@"/usr/bin/open"];
    [task setArguments:@[@"studentCode.txt"]];
    [task launch];
}



@end

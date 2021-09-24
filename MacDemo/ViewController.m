//
//  ViewController.m
//  MacDemo
//
//  Created by cmm on 2021/9/24.
//

#import "ViewController.h"
#import "WebCacheDB.h"
#import "WebCacheConfig.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    WebCacheDB *db = [WebCacheDB shareInstance];
    [db initDataBase];
    
    NSDictionary *dict = nil;
    NSString *sourcePath = @"www.baidu.com";
    //从资源缓存表中查是否需要缓存
    NSArray *result = [db getTableWebSourceCacheWithSourcePath:sourcePath];
    if(result.count > 0){
        NSString *pathMd5 = [[result firstObject] objectForKey:@"md5"];
        if(pathMd5 && pathMd5.length > 0){
            dict = [result firstObject];
        }
    }
    NSArray *webSoucreCacheSQL = [db arraySQLForInsertTableWebSourceCacheWithSourceName:@"baidu-cli-sqlcipher" pathMd5Dic:@{
        @"baidu-cli-sqlcipher": @"23r3434234rwer3gd",
            @"baidu-cli-sqlcipher/HWAFL/fdsgngfd" : @"dsffsdfdsewrewr",
            @"baidu-cli-sqlcipher/css/app.3gfhfdf.css" : @"3423vfdgfdgdfgdffg",
            @"baidu-cli-sqlcipher/css/chunk-53578.9d09f644.css" : @"657623vdfvdfgerewr",
            @"baidu-cli-sqlcipher/css/chunk-354635.b1b518cb.css" : @"34234235gfddffdsfewf",
    }];
    NSArray *webSoucreSQL = [db arraySQLForInsertTableWebSourceWithNameMd5Dic:@{@"baidu-cli-sqlcipher": @"5787hfdgdgdsdscfsdfsdfs"}];
    
    NSMutableArray *insertArray = [[NSMutableArray alloc] initWithArray:webSoucreCacheSQL];
    [insertArray addObjectsFromArray:webSoucreSQL];

    BOOL isSuccess = [db updateTransactionWithSqlArray:insertArray];
    if(isSuccess == NO){
        NSLog(@"缓存: 表1、表2插入数据库 失败:%@",@"mspmk-cli-onlineloan");
    }
    id data = [db getAllFromTable:TableWebSourceCache];
    NSLog(@"data = %@", data);
//    [db close];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end

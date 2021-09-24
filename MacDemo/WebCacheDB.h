//
//  WebCacheDB.h
//  SQLCipherDemo
//
//  Created by cmm on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebCacheDB : NSObject

+ (WebCacheDB *)shareInstance;

#pragma mark - 共同表相关操作
- (void)initDataBase;
//创建表
- (void)createTable;

//获取全部数据
- (NSArray *)getAllFromTable:(NSString *)tableName;

#pragma mark - web_source表相关操作

//获取web_source表插入语句
- (NSArray *)arraySQLForInsertTableWebSourceWithNameMd5Dic:(NSDictionary *)sourceNameMd5Dic;

#pragma mark - web_source_cache表相关操作

- (NSArray *)getTableWebSourceCacheWithSourcePath:(NSString *)sourcePath;

//获取web_source_cache表插入语句
- (NSArray *)arraySQLForInsertTableWebSourceCacheWithSourceName:(NSString *)sourceName pathMd5Dic:(NSDictionary *)sourcePathMd5Dic;

//查询数据库
- (NSArray *)queryWithSql:(NSString *)executeSql;

//更新数据库
- (BOOL)updateWithSql:(NSString *)executeSql;

//多次更新数据库
- (BOOL)updateTransactionWithSqlArray:(NSArray *)sqlArray;

- (void)close;

@end

NS_ASSUME_NONNULL_END

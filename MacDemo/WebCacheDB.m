//
//  WebCacheDB.m
//  SQLCipherDemo
//
//  Created by cmm on 2021/9/23.
//

#import "WebCacheDB.h"
#import "FMDatabaseQueue.h"
#import "WebCacheConfig.h"

@interface WebCacheDB(){
    FMDatabaseQueue  *_queue;
}

@end

@implementation WebCacheDB

static WebCacheDB *instance = nil;

+ (WebCacheDB *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (void)initDataBase{
    // 文件路径
    _queue = [FMDatabaseQueue databaseQueueWithPath:NewDbFilePath];
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:NewDbFilePath];
    if(isFileExist){
        [self createTable];
    }
}
- (void)createTable{
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        [db setKey:NewDBPassWord];
        // 初始化数据表
        NSString *insetTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name text, md5 text)",TableWebSource];
        [db executeUpdate:insetTableSql];

        insetTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name text, path text, md5 text)",TableWebSourceCache];
        [db executeUpdate:insetTableSql];

        NSString *sourceIndexSql = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS index_name ON %@ (name)",TableWebSourceCache];
        [db executeUpdate:sourceIndexSql];
        
        NSString *nameIndexSql = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS index_path ON %@ (path)",TableWebSourceCache];
        [db executeUpdate:nameIndexSql];
    }];
}

#pragma mark - 共同表相关操作

- (NSArray *)getAllFromTable:(NSString *)tableName{
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    return [self queryWithSql:querySql];
}

- (BOOL)clearAllFromTable:(NSString *)tableName{
    NSString *clearAllSql = [NSString stringWithFormat:@"DROP TABLE %@",tableName];
    return [self updateWithSql:clearAllSql];
}

- (BOOL)removeSourceNames:(NSArray *)sourceNames fromTable:(NSString *)tableName{
    NSString *inArrayStr = [sourceNames componentsJoinedByString:@"','"];
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE name in ('%@')",tableName, inArrayStr];
    return [self updateWithSql:deleteSql];
}

#pragma mark - web_source表相关操作
//获取web_source表插入语句
- (NSArray *)arraySQLForInsertTableWebSourceWithNameMd5Dic:(NSDictionary *)sourceNameMd5Dic{
    NSMutableArray *insertSqlArray = [[NSMutableArray alloc] init];
    for(NSString *sourceName in sourceNameMd5Dic){
        NSString *sourceMd5 = sourceNameMd5Dic[sourceName];
        if(sourceMd5.length > 0){
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@(name, md5) values('%@','%@')",TableWebSource,sourceName,sourceMd5];
            [insertSqlArray addObject:insertSql];
        }
    }
    return insertSqlArray;
}

#pragma mark - web_source_cache表相关操作

- (NSArray *)getTableWebSourceCacheWithSourcePath:(NSString *)sourcePath{
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE path='%@' limit 0, 1", TableWebSourceCache, sourcePath];
    return [self queryWithSql:querySql];
}

//获取web_source_cache表插入语句
- (NSArray *)arraySQLForInsertTableWebSourceCacheWithSourceName:(NSString *)sourceName pathMd5Dic:(NSDictionary *)sourcePathMd5Dic{
    NSMutableArray *insertSqlArray = [[NSMutableArray alloc] init];
    for(NSString *sourcePath in sourcePathMd5Dic){
        NSString *pathMd5 = sourcePathMd5Dic[sourcePath];
        if(pathMd5.length > 0){
            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@(name,path,md5) values('%@','%@','%@')",TableWebSourceCache, sourceName, sourcePath, pathMd5];
            [insertSqlArray addObject:insertSql];
        }
    }
    return insertSqlArray;
}

- (NSArray *)queryWithSql:(NSString *)executeSql{
    __block NSArray *tempArray = [[NSArray alloc] init];
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:executeSql];
        tempArray = [self convertArrayFromSet:resultSet];
        [resultSet close];
    }];
    return tempArray;
}

- (BOOL)updateWithSql:(NSString *)executeSql{
    __block BOOL isOK;
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        isOK = [db executeUpdate:executeSql];
    }];
    return isOK;
}

- (BOOL)updateTransactionWithSqlArray:(NSArray *)sqlArray{
    __block BOOL isSuccess = NO;
    [_queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (NSString *executeSql in sqlArray) {
            BOOL flag = [db executeUpdate:executeSql];
            if(!flag){
                *rollback = YES;
                return;
            }
        }
        isSuccess = YES;
    }];
    return isSuccess;
}

//将查询后的数据 转换为 数组
- (NSArray *)convertArrayFromSet:(FMResultSet *)resultSet{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        for (int index=0; index<resultSet.columnCount; index++) {
            NSString *columnName = [resultSet columnNameForIndex:index];
            NSString *columnValue = [resultSet stringForColumn:columnName];
            [dic setValue:columnValue forKey:columnName];
        }
        [array addObject:dic];
    }
    return array;
}
- (void)close
{
    [_queue close];
}
@end

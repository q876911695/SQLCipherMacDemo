//
//  WebCacheConfig.h
//  SQLCipherDemo
//
//  Created by cmm on 2021/9/23.
//


/**********************************数据库文件**********************************************/

#define WebCacheDBName @"SQLCipherDB.sqlite" //数据库名称
#define NewDBPassWord @"SQLCipherDemo@app@123456@cmm"   //数据库加密
#define TableWebSource @"web_source"  //资源md5表
#define TableWebSourceCache @"web_source_cache"    //资源缓存表-有索引

/**********************************文件目录**********************************************/

//根地址
#define LibCacheFile [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

//数据库文件地址
#define NewDbFilePath [LibCacheFile stringByAppendingPathComponent:WebCacheDBName]

//web文件缓存根目录
#define NewWebCachePath [LibCacheFile stringByAppendingPathComponent:@"web_cache"]

//本地服务器储存地址
#define LocalHTTPServerPath [LibCacheFile stringByAppendingPathComponent:@"LocalHTTPServer"]

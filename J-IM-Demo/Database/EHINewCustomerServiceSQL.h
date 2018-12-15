//
//  EHINewCustomerServiceSQL.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/10.
//  Copyright © 2018 yogurts. All rights reserved.
//

#ifndef EHINewCustomerServiceSQL_h
#define EHINewCustomerServiceSQL_h

/** 创建框架总表(聊天分类) */
#define     NEWCUSTOMERSERVICE_TABLE_NAME              @"customer_service_message"

#define     SQL_CREATE_NEWCUSTOMERSERVICE_TABLE        @"CREATE TABLE IF NOT EXISTS %@(\
msg_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,\
is_anonymous_message INTEGER,\
user_id VARCHAR(255),\
from_type INTEGER,\
message_status INTEGER,\
message_type INTEGER,\
text_content TEXT,\
voice_url TEXT,\
play_status INTEGER,\
milliseconds_played REAL,\
picture_url TEXT,\
create_time TEXT,\
chat_content_height REAL,\
chat_content_width REAL,\
ext1 TEXT,\
ext2 TEXT,\
ext3 TEXT,\
ext4 TEXT,\
ext5 TEXT);"

#define     NEWCUSTOMERSERVICE_ADD_MESSAGE             @"REPLACE INTO %@ ( \
is_anonymous_message,\
user_id,\
from_type,\
message_status,\
message_type,\
text_content,\
voice_url,\
play_status,\
milliseconds_played,\
picture_url,\
create_time,\
chat_content_height,\
chat_content_width,\
ext1, ext2, ext3, ext4, ext5)\
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"


/** 查询 指定时间和用户ID 消息 */
#define SQL_SELECT_CREATE_TIME_MESSAGE @"SELECT * FROM %@ WHERE create_time = %@ AND user_id = %@"

/** 查询 匿名 消息 */
#define SQL_SELECT_ANONYMOUS_MESSAGE @"SELECT * FROM %@ WHERE is_anonymous_message = %d"

/** 查询 某一ID下的所有消息 */
#define SQL_SELECT_USERID_MESSAGE @"SELECT * FROM %@ WHERE user_id = %@"

/** 查询 指定用户ID最后一条记录 */
#define SQL_SELECT_USERID_LAST_MESSAGE @"SELECT * from %@ WHERE user_id = %@ ORDER BY msg_id DESC LIMIT 1"

/** 删除 匿名 消息 */
#define SQL_DELETE_ANONYMOUS_MESSAGE @"DELETE * FROM %@ WHERE is_anonymous_message = %d"

/** 删除 所有消息 */
#define SQL_DELETE_ALL_MESSAGES @"UPDATE sqlite_sequence SET seq = 0 WHERE name = %@;\
DELETE FROM %@;"

/** 更新 转换匿名信息为某一用户ID下的信息 */
#define SQL_UPDATE_ANONYMOUS_MESSAGE @"UPDATE %@ SET is_anonymous_message = '%d', user_id = '%@' WHERE msg_id = %d"


#endif /* EHINewCustomerServiceSQL_h */

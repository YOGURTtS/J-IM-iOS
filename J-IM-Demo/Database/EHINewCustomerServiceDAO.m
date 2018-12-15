//
//  EHINewCustomerServiceDAO.m
//  J-IM-Demo
//
//  Created by yogurts on 2018/12/10.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import "EHINewCustomerServiceDAO.h"
#import "EHINewCustomerServiceSQL.h"

@implementation EHINewCustomerServiceDAO

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dbQueue = [EHIDBManager sharedInstance].messageQueue;
        BOOL ok = [self createTable];
        if (!ok) {
            NSLog(@"DB: 聊天记录表创建失败");
        }
    }
    return self;
}

- (BOOL)createTable {
    NSString *sqlString = [NSString stringWithFormat:SQL_CREATE_NEWCUSTOMERSERVICE_TABLE, NEWCUSTOMERSERVICE_TABLE_NAME];
    return [self createTable:NEWCUSTOMERSERVICE_TABLE_NAME withSQL:sqlString];
}

- (BOOL)addMessage:(EHICustomerServiceModel *)message {
    NSString *sqlString = [NSString stringWithFormat:NEWCUSTOMERSERVICE_ADD_MESSAGE, NEWCUSTOMERSERVICE_TABLE_NAME];
    NSArray *arrPara = [NSArray arrayWithObjects:
                        @(message.isAnonymousMessage),
                        message.userId,
                        @(message.fromType),
                        @(message.messageStatus),
                        @(message.messageType),
                        message.text,
                        message.voiceUrl,
                        @(message.playStatus),
                        @(message.millisecondsPlayed),
                        message.pictureUrl,
                        message.time,
                        @(message.chatContentSize.height),
                        @(message.chatContentSize.width),
                        @"", @"", @"",
                        @"", @"", nil];
    BOOL ok = [self excuteSQL:sqlString withArrParameter:arrPara];
    NSLog(@"插入聊天记录到数据库");
    return ok;
}


/** 查找所有的匿名信息 返回 */
- (void)getAnonymousMessageWithCompletion:(void (^)(NSArray *array))completion {
    completion([self findMessageWetherIsAnonymous:YES]);
}

/** 查找某一ID下的所有信息 返回 */
- (void)getMessagesWithUserId:(NSString *)userId completion:(void (^)(NSArray *array))completion {
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *sqlString = [NSString stringWithFormat:
                           SQL_SELECT_USERID_MESSAGE,
                           NEWCUSTOMERSERVICE_TABLE_NAME,
                           userId];
    [self excuteQuerySQL:sqlString resultBlock:^(FMResultSet *retSet) {
        while ([retSet next]) {
            EHICustomerServiceModel *message = [self createDBMessageByFMResultSet:retSet];
            [array addObject:message];
        }
        [retSet close];
    }];
    completion(array);
}

/** 查找指定用户ID最后一条记录 */
- (void)getLastMessageWithUserId:(NSString *)userId completion:(void (^)(EHICustomerServiceModel *message))completion {
    __block NSMutableArray<EHICustomerServiceModel *> *array = [[NSMutableArray alloc] init];
    NSString *sqlString = [NSString stringWithFormat:
                           SQL_SELECT_USERID_LAST_MESSAGE,
                           NEWCUSTOMERSERVICE_TABLE_NAME,
                           userId];
    [self excuteQuerySQL:sqlString resultBlock:^(FMResultSet *retSet) {
        while ([retSet next]) {
            EHICustomerServiceModel *message = [self createDBMessageByFMResultSet:retSet];
            [array addObject:message];
        }
        [retSet close];
    }];
    completion(array.lastObject);
}

/** 删除所有的匿名信息 */
- (BOOL)deleteAnonymousMessages {
    NSString *sqlStr = [NSString stringWithFormat:
                        SQL_DELETE_ANONYMOUS_MESSAGE,
                        NEWCUSTOMERSERVICE_TABLE_NAME,
                        YES];
    BOOL ok = [self excuteSQL:sqlStr];
    return ok;
}

/** 删除所有信息 */
- (BOOL)deleteAllMessages {
    NSString *sqlStr = [NSString stringWithFormat:
                        SQL_DELETE_ALL_MESSAGES,
                        NEWCUSTOMERSERVICE_TABLE_NAME,
                        NEWCUSTOMERSERVICE_TABLE_NAME];
    BOOL ok = [self excuteSQL:sqlStr];
    return ok;
}

/** 将所有的匿名信息更新为某一用户ID下的信息 */
- (BOOL)turnAnonymousMessagesToLoginMessagesWithUserId:(NSString *)userId {
    __block BOOL ok;
    NSString *sqlString = [NSString stringWithFormat:
                           SQL_SELECT_ANONYMOUS_MESSAGE,
                           NEWCUSTOMERSERVICE_TABLE_NAME,
                           YES];
    [self excuteQuerySQL:sqlString resultBlock:^(FMResultSet *retSet) {
        while ([retSet next]) {
            int msg_id = [retSet intForColumn:@"msg_id"];
            NSString *sqlStr = [NSString stringWithFormat:
                                SQL_UPDATE_ANONYMOUS_MESSAGE,
                                NEWCUSTOMERSERVICE_TABLE_NAME,
                                NO,
                                userId,
                                msg_id];
            ok = [self excuteSQL:sqlStr];
        }
        [retSet close];
    }];
    return ok;
}


#pragma mark - private methods

- (NSArray *)findMessageWetherIsAnonymous:(BOOL)anonymous {
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *sqlString = [NSString stringWithFormat:
                           SQL_SELECT_ANONYMOUS_MESSAGE,
                           NEWCUSTOMERSERVICE_TABLE_NAME,
                           anonymous];
    [self excuteQuerySQL:sqlString resultBlock:^(FMResultSet *retSet) {
        while ([retSet next]) {
            EHICustomerServiceModel *message = [self createDBMessageByFMResultSet:retSet];
            [array addObject:message];
        }
        [retSet close];
    }];
    return array;
}

- (EHICustomerServiceModel *)createDBMessageByFMResultSet:(FMResultSet *)retSet {
    
    EHICustomerServiceModel *message = [[EHICustomerServiceModel alloc] init];
    message.fromType = [retSet intForColumn:@"from_type"];
    message.messageStatus = [retSet intForColumn:@"message_status"];
    message.messageType = [retSet intForColumn:@"message_type"];
    message.text = [retSet stringForColumn:@"text_content"];
    message.voiceUrl = [retSet stringForColumn:@"voice_url"];
    message.playStatus = [retSet intForColumn:@"play_status"];
    message.millisecondsPlayed = [retSet doubleForColumn:@"milliseconds_played"];
    message.pictureUrl = [retSet stringForColumn:@"picture_url"];
    message.time = [retSet stringForColumn:@"create_time"];
    CGFloat chatContentSizeWidth = [retSet doubleForColumn:@"chat_content_width"];
    CGFloat chatContentSizeHeight = [retSet doubleForColumn:@"chat_content_height"];
    message.chatContentSize = CGSizeMake(chatContentSizeWidth, chatContentSizeHeight);
    
    return message;
}

@end

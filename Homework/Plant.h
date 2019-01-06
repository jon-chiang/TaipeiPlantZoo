//
//  Plant.h
//  Homework
//
//  Created by jon on 2019/1/4.
//  Copyright © 2019 jon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Plant : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *feature;
@property (nonatomic, copy) NSString *imageUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

//
//  PlantFetcher.h
//  Homework
//
//  Created by jon on 2019/1/4.
//  Copyright © 2019 jon. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlantFetcher : NSObject

- (void)fetchAt:(int)offset limit:(int)limit completedBlock:(void (^)(NSArray *data, NSNumber *total))block;

@end

NS_ASSUME_NONNULL_END

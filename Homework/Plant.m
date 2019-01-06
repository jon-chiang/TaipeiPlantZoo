//
//  Plant.m
//  Homework
//
//  Created by jon on 2019/1/4.
//  Copyright © 2019 jon. All rights reserved.
//

#import "Plant.h"

@implementation Plant

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.name = dictionary[@"F_Name_Ch"];
        self.location = dictionary[@"F_Location"];
        self.feature = dictionary[@"F_Feature"];
        self.imageUrl = dictionary[@"F_Pic01_URL"];
    }
    return self;
}

@end

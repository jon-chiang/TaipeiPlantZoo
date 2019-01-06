//
//  PlantFetcher.m
//  Homework
//
//  Created by jon on 2019/1/4.
//  Copyright © 2019 jon. All rights reserved.
//

#import "PlantFetcher.h"
#import "Plant.h"

@implementation PlantFetcher

- (void)fetchAt:(int)offset limit:(int)limit completedBlock:(void (^)(NSArray *data, NSNumber *total))block {
    NSString *requestString = [[NSString alloc] initWithFormat:(@"https://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=f18de02f-b6c9-47c0-8cda-50efad621c14&limit=%d&offset=%d"), limit, offset];
    NSURL *url = [NSURL URLWithString:requestString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"ret=%@", ret);
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSDictionary *result = [dict objectForKey:@"result"];
    NSArray *plants = [result objectForKey:@"results"];
    NSNumber *total = [result objectForKey:@"count"];
    
    NSMutableArray *tem = [NSMutableArray new];
    for (NSDictionary *dict in plants) {
        Plant *p = [[Plant alloc] initWithDictionary:dict];
        [tem addObject:p];
    }
    block(tem, total);
}

@end

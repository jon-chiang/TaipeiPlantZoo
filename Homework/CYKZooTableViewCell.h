//
//  CYKZooTableViewCell.h
//  Homework
//
//  Created by jon on 2019/1/3.
//  Copyright © 2019 jon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CYKZooTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel;

@end

NS_ASSUME_NONNULL_END

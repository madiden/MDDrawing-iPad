//
//  ImagePickerCell.h
//  MDDrawingPad
//
//  Created by Mahmut Duman on 10/09/14.
//  Copyright (c) 2014 Mahmut Duman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePickerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;

@end

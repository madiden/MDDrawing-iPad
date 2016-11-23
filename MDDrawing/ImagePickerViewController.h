//
//  ImagePickerViewController.h
//  MDDrawingPad
//  Resim seçmek içiçn kullanılıyor
//  Created by Mahmut Duman on 10/09/14.
//  Copyright (c) 2014 Mahmut Duman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePickerViewController : UICollectionViewController
@property(nonatomic, strong) NSMutableArray *images;
@property(nonatomic, strong)UIImage *selectedImage;
@property(nonatomic, strong)UIPopoverController *popover;
@end

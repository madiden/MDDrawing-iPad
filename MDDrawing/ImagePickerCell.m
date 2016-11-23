//
//  ImagePickerCell.m
//  MDDrawingPad
//
//  Created by Mahmut Duman on 10/09/14.
//  Copyright (c) 2014 Mahmut Duman. All rights reserved.
//

#import "ImagePickerCell.h"

@implementation ImagePickerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

-(id)init{
    self = [super init];
    if(self){
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 0.75;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

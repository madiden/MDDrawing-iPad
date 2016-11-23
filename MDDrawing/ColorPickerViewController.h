//
//  ColorPickerViewController.h
//  PathHitTesting
//
//  Created by Mahmut Duman on 06/09/14.
//  Copyright (c) 2014 Mahmut Duman. All rights reserved.
//

#define kColorPresetRed     1
#define kColorPresetBlue    2
#define kColorPresetGreen   3
#define kColorPresetYellow  4
#define kColorPresetBrown   5
#define kColorPresetOrange  6
#define kColorPresetPurple  7
#define kColorPresetBlack   8

#import <UIKit/UIKit.h>

@interface ColorPickerViewController : UIViewController
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (weak, nonatomic) IBOutlet UILabel *lineWidthLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorRedLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorGreenLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorBlueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UIView *colorButtonsPanel;
@property (weak, nonatomic) IBOutlet UISlider *linewWidthSlider;
@property (weak, nonatomic) IBOutlet UISlider *colorRedSlider;
@property (weak, nonatomic) IBOutlet UISlider *colorGreenSlider;
@property (weak, nonatomic) IBOutlet UISlider *colorBlueSlider;

- (IBAction)lineWidthSliderChanged:(id)sender;
- (IBAction)colorRedSliderChanged:(id)sender;
- (IBAction)colorGreenSliderChanged:(id)sender;
- (IBAction)colorBlueSliderChanged:(id)sender;
- (IBAction)colorButtonClicked:(UIButton *)sender;
- (void)setLineColor:(UIColor *)lineColor lineWidth:(CGFloat)lineWidth;

@end

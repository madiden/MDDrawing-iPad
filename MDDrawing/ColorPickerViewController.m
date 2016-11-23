//
//  ColorPickerViewController.m
//  PathHitTesting
//
//  Created by Mahmut Duman on 06/09/14.
//  Copyright (c) 2014 Mahmut Duman. All rights reserved.
//

#import "ColorPickerViewController.h"

@interface ColorPickerViewController ()
-(void)decorateButton:(UIButton*)button;
-(UIColor*)getColorForNumber:(NSInteger)number;
-(void)sliderChangedWithValue:(float)value andLabel:(UILabel*)label;
-(void)preview;
@end

@implementation ColorPickerViewController
@synthesize lineColor =_lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize colorButtonsPanel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.previewImage.layer.borderWidth = 1;
    //self.previewImage.layer.borderColor = [UIColor blackColor].CGColor;
    self.previewImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.previewImage.layer.shadowOffset = CGSizeMake(2, 2);
    self.previewImage.layer.shadowOpacity = 0.50;
    for (int i=0; i<self.colorButtonsPanel.subviews.count; i++) {
        UIButton *b = (UIButton*)[self.colorButtonsPanel.subviews objectAtIndex:i];
        b.tag = i;
        [self decorateButton:b];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIColor *)getColorForNumber:(NSInteger)number{
    switch (number) {
        case kColorPresetRed:
            return [UIColor redColor];
        case kColorPresetBlue:
            return [UIColor blueColor];
        case kColorPresetGreen:
            return [UIColor greenColor];
        case kColorPresetYellow:
            return [UIColor yellowColor];
        case kColorPresetBrown:
            return [UIColor brownColor];
        case kColorPresetOrange:
            return [UIColor orangeColor];
        case kColorPresetPurple:
            return [UIColor purpleColor];
        case kColorPresetBlack:
            return [UIColor blackColor];
        default:
            return  [UIColor cyanColor];
    }
}

-(void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    [self preview];
}

-(void)setLineWidth:(CGFloat)lineWidth{
    _lineWidth = lineWidth;
    self.lineWidthLabel.text = [NSString stringWithFormat:@"%d", (int)lineWidth];
    [self preview];
}

-(void)preview{
    UIGraphicsBeginImageContext(self.previewImage.bounds.size);
    CGPoint startPoint = CGPointMake(self.previewImage.bounds.size.width/2.0f,
                                     self.previewImage.bounds.size.height/2.0f);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x, startPoint.y);
//    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), self.lineColor.CGColor);
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), self.lineColor.CGColor);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.lineWidth);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),startPoint.x + 1,startPoint.y + 1);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.previewImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)sliderChangedWithValue:(float)value andLabel:(UILabel*)label{
    label.text = [NSString stringWithFormat:@"%d", (int)value];
    float red = [self.colorRedLabel.text floatValue];
    float green = [self.colorGreenLabel.text floatValue];
    float blue = [self.colorBlueLabel.text floatValue];
    self.lineColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
}

-(void)setLineColor:(UIColor *)lineColor lineWidth:(CGFloat)lineWidth{
    _lineColor = lineColor;
    _lineWidth = lineWidth;
    self.lineWidthLabel.text = [NSString stringWithFormat:@"%d", (int)lineWidth];
    self.linewWidthSlider.value = lineWidth;
    CGFloat red, green, blue, alpha;
    [lineColor getRed:&red green:&green blue:&blue alpha:&alpha];
    red = red*255;
    green = green*255;
    blue = blue*255;
    self.colorRedSlider.value = red;
    self.colorGreenSlider.value = green;
    self.colorBlueSlider.value = blue;
    self.colorRedLabel.text = [NSString stringWithFormat:@"%d", (int)red];
    self.colorGreenLabel.text = [NSString stringWithFormat:@"%d", (int)green];
    self.colorBlueLabel.text = [NSString stringWithFormat:@"%d", (int)blue];
    [self preview];
}

-(void)decorateButton:(UIButton *)button{
    UIColor *buttonColor = [self getColorForNumber:button.tag];
    button.layer.backgroundColor = buttonColor.CGColor;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.titleLabel.text = @"";
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)lineWidthSliderChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    self.lineWidth = slider.value;
}

- (IBAction)colorRedSliderChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    [self sliderChangedWithValue:slider.value andLabel:self.colorRedLabel];
}

- (IBAction)colorGreenSliderChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    [self sliderChangedWithValue:slider.value andLabel:self.colorGreenLabel];
}

- (IBAction)colorBlueSliderChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    [self sliderChangedWithValue:slider.value andLabel:self.colorBlueLabel];
}

- (IBAction)colorButtonClicked:(UIButton *)sender {
    [self setLineColor:[self getColorForNumber:sender.tag] lineWidth:self.lineWidth];
}
@end

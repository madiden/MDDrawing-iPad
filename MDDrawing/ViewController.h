//
//  ViewController.h
//  MDDrawingPad
/*
 Asıl ViewController, tüm kullanıcı interaksiyonları buradan yönetilir.
 */
//  Created by Mahmut Duman on 30.01.12.
//  Copyright (c) 2012 Mahmut Duman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPickerViewController.h"

#define kDrawingViewDrawModeNone        20
#define kDrawingViewDrawModeFreeHand    21
#define kDrawingViewDrawModeShape       22

@class Shape;

@interface ViewController : UIViewController <UIGestureRecognizerDelegate,UIActionSheetDelegate>{
    CGPoint lastPoint;
    BOOL mouseSwiped;
    NSInteger _drawingMode;
    NSInteger _drawToolType;
    NSInteger _shapeToolType;
    NSInteger _polygonEdgeCount;
    CGRect lastRectangle,refreshRectangle;
    
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingButton;
@property (weak, nonatomic) IBOutlet UIView *drawingView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *redoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteShapeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shapeButton;

- (IBAction)undoButtonTapped:(id)sender;
- (IBAction)redoButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;
- (IBAction)toolButtonTapped:(id)sender;
- (IBAction)shapeButtonTapped:(id)sender;
- (IBAction)clearButtonTapped:(id)sender;
- (IBAction)settingTapped:(id)sender;

@end

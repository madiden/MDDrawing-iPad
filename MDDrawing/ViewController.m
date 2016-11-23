//
//  ViewController.m
//  PathHitTesting
//
//  Created by Mahmut Duman on 30.01.12.
//  Copyright (c) 2012 Mahmut Duman. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Shape.h"
#import "ImagePickerViewController.h"
#import "MDDrawingLayer.h"





#define kShapeToolTypeSelect    21
#define kShapeToolTypeImage     22
#define kShapeToolTypeTriangle  23
#define kShapeToolTypePentagon  24
#define kShapeToolTypePolygon   25

#define kActionSheetDrawing 100
#define kActionSheetShape   101


@interface ViewController ()<UIPopoverControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *drawingLayers;
@property (nonatomic, strong) NSMutableArray *shapeBuffer;
@property (nonatomic, strong) NSMutableArray *shaperedoBuffer;
@property (nonatomic, strong) NSMutableArray *shapes;
@property (nonatomic, assign) NSUInteger selectedShapeIndex;
@property (nonatomic, readonly) Shape *selectedShape;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIColor *drawingColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIPopoverController *colorPicker;
@property (strong, nonatomic) Shape *lastShape;
@property (nonatomic, strong) MDDrawingLayer *lastDrawingLayer;

//Tıklanan nokta herhangi bir şekle denk geliyor mu
- (NSUInteger)hitTest:(CGPoint)point;
//Çizim ya da şekil modu mu? Eğer çizim moduysa büyütme, döndürme vs. gibi şekille alakalı interactionlar devre dışı bırakılıyor
-(void)setDrawingMode:(NSInteger)mode;
//Ekrandaki kontrollerin enabled, disabled kontrolleri
-(void)refreshControlStates;
//Çizim için MDDrawingLayer oluşturuyor. İlgili açıklama MDDrawingLayer.h içinde bulunuyor.
-(void)createDrawingLayerForFreehand;
//Herhangi bir menü açıldığında, üst üste basılmasını engellemek; daha sonra tekrar aktive etmek için kullanılıyor
-(void)enableDisableButtonsForPopover:(BOOL)enable;
-(void)addShape:(Shape*)shape;
@end



@implementation ViewController

@synthesize deleteShapeButton = _deleteShapeButton;
@synthesize drawingLayers = _drawingLayers;
@synthesize selectedShapeIndex = _selectedShapeIndex;
@synthesize lastShape = _lastShape;
@synthesize drawingColor = _drawingColor;
@synthesize lineWidth = _lineWidth;
@synthesize shapes = _shapes;
//selectedShape diye metod olacak anlamına geliyor
@dynamic selectedShape;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _lineWidth = kDefaultLineWidth;
    self.drawingColor = [UIColor blackColor];
	// Do any additional setup after loading the view, typically from a nib.
    _selectedShapeIndex = NSNotFound;
    self.drawingLayers = [NSMutableArray array];
    self.shapeBuffer = [NSMutableArray array];
    self.shaperedoBuffer = [NSMutableArray array];
    self.shapes = [NSMutableArray array];
    _drawingMode = kDrawingViewDrawModeNone;
    [self refreshControlStates];
}

- (void)viewDidUnload
{
    [self setDeleteShapeButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark - Shape management

- (IBAction)deleteButtonTapped:(id)sender 
{
    if (self.selectedShapeIndex == NSNotFound) {
        return;
    }
    [self.selectedShape saveStateForAction:Deleted];
    [self.shapeBuffer addObject:self.selectedShape];
    [self.selectedShape.layer removeFromSuperlayer];
    [self.shapes removeObject:self.selectedShape];
    self.selectedShapeIndex = NSNotFound;
}

-(void)toolButtonTapped:(id)sender{
    [self enableDisableButtonsForPopover:NO];
    UIActionSheet *sheet= [[UIActionSheet alloc]initWithTitle:@"Çizim Türünü Seçiniz" delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:@"Kalem",@"Çizgi",@"Kare&Dikdörtgen",@"Elips&Daire",@"Silgi", nil];
    [sheet setTag:kActionSheetDrawing];
    [sheet showFromBarButtonItem:self.toolButton animated:YES];
}

-(void)shapeButtonTapped:(id)sender{
    [self enableDisableButtonsForPopover:NO];
    UIActionSheet *sheet= [[UIActionSheet alloc]initWithTitle:@"Şekil Modu Seçiniz" delegate:self cancelButtonTitle:@"İptal" destructiveButtonTitle:nil otherButtonTitles:@"Seç",@"Resim",@"Üçgen",@"Beşgen",@"Çokgen", nil];
    [sheet setTag:kActionSheetShape];
    [sheet showFromBarButtonItem:self.shapeButton animated:YES];
}


- (void)setSelectedShapeIndex:(NSUInteger)selectedShapeIndex
{
    _selectedShapeIndex = selectedShapeIndex;
    for (Shape *shape in self.shapes) {
        [shape deselectShape];
    }
    if (_selectedShapeIndex != NSNotFound) {
        [[self.shapes objectAtIndex:selectedShapeIndex] selectShape];
    }
    
    self.deleteShapeButton.enabled = (_selectedShapeIndex != NSNotFound);
}

//dynamic tanımladığımız kısmın metodu
- (Shape *)selectedShape
{
    if (_selectedShapeIndex == NSNotFound) {
        return nil;
    }
    return [self.shapes objectAtIndex:_selectedShapeIndex];
}
#pragma mark - DrawingView Features
-(void)createDrawingLayerForFreehand{
    self.lastDrawingLayer = [MDDrawingLayer drawingLayerForFreehand];
    self.lastDrawingLayer.layer.frame = CGRectMake(0, 0, self.drawingView.frame.size.width, self.drawingView.frame.size.height);
    [self.drawingView.layer addSublayer:self.lastDrawingLayer.layer];
    [self.drawingLayers addObject:self.lastDrawingLayer];
}

//Çizim modunu ayarla
-(void)setDrawingMode:(NSInteger)mode{
    _drawingMode = mode;

    if(_drawingMode == kDrawingViewDrawModeShape){
        [self.lastDrawingLayer convertShapeDrawingsWithAddingTo:self.shapes];
        self.lastShape = nil;
        self.lastDrawingLayer = nil;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
        [self.drawingView addGestureRecognizer:tapRecognizer];
        tapRecognizer.delegate = self;
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
        [self.drawingView addGestureRecognizer:panRecognizer];
        panRecognizer.delegate =self;
        
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchDetected:)];
        [self.drawingView addGestureRecognizer:pinchGestureRecognizer];
        pinchGestureRecognizer.delegate = self;
        
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationDetected:)];
        [self.drawingView addGestureRecognizer:rotationGestureRecognizer];
        rotationGestureRecognizer.delegate =self;
        
    }else if(_drawingMode == kDrawingViewDrawModeFreeHand){
        //Çizim moduna geçince şekille ilgili etkileşimleri iptal et
        for (int i=0; i< self.drawingView.gestureRecognizers.count; i++) {
            [self.drawingView removeGestureRecognizer:[self.drawingView.gestureRecognizers objectAtIndex:i]];
            i--;
        }
        [self createDrawingLayerForFreehand];
    }
    _drawingMode = mode;
    [self refreshControlStates];
}

-(void)refreshControlStates{
    self.undoButton.enabled = self.shapeBuffer.count > 0;
    self.redoButton.enabled = self.shaperedoBuffer.count > 0;
}

- (IBAction)undoButtonTapped:(id)sender {
    Shape *shape = (Shape*)[self.shapeBuffer lastObject];
    [shape undoWithArray:self.shapes];
    [self.shaperedoBuffer addObject:shape];
    [self.shapeBuffer removeLastObject];
    [self refreshControlStates];
}

- (IBAction)redoButtonTapped:(id)sender {
    Shape *shape = (Shape*)self.shaperedoBuffer.lastObject;
    [shape redoWithArray:self.shapes];
    [self.shaperedoBuffer removeLastObject];
    [self.shapeBuffer addObject:shape];
    [self refreshControlStates];
}


- (IBAction)clearButtonTapped:(id)sender {
    [self.drawingLayers removeAllObjects];
    self.drawingView.layer.sublayers = nil;
    [self.shapeBuffer removeAllObjects];
    [self.shaperedoBuffer removeAllObjects];
    [self.shapes removeAllObjects];
    [self createDrawingLayerForFreehand];
    [self refreshControlStates];
}

- (IBAction)settingTapped:(id)sender {
    [self enableDisableButtonsForPopover:NO];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ColorPickerViewController *cpv = (ColorPickerViewController *)[sb instantiateViewControllerWithIdentifier:@"ColorPickerIdentiifier"];
    self.colorPicker = [[UIPopoverController alloc]initWithContentViewController:cpv];
    self.colorPicker.delegate = self;
    [self.colorPicker presentPopoverFromBarButtonItem:self.settingButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [cpv setLineColor:self.drawingColor lineWidth:_lineWidth];
}
#pragma mark - UIAlertView Members
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *input = [alertView textFieldAtIndex:0].text;
    NSInteger intval = [input intValue];
    if (intval >= 3) {
        _polygonEdgeCount = intval;
    }else{
        UIAlertView *warning = [[UIAlertView alloc]initWithTitle:@"Uyarı" message:@"Geçerli bir değer girmediniz. 3 veya daha büyük sayı girmelisiniz." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
        [warning show];
        _polygonEdgeCount = 0;
        
    }
}

#pragma mark - UIActionSheetDelegate Members
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    BOOL valid = YES;
    if (actionSheet.tag == kActionSheetDrawing) {
        switch (buttonIndex) {
            case 0:
                _drawToolType = kDrawToolTypePen;
                break;
            case 1:
                _drawToolType = kDrawToolTypeLine;
                break;
            case 2:
                _drawToolType = kDrawToolTypeSquare;
                break;
            case 3:
                _drawToolType = kDrawToolTypeCircle;
                break;
            case 4:
                _drawToolType = kDrawToolTypeEraser;
                break;
            default:
                valid = NO;
                break;
        }
        if(valid){
            if (_drawingMode != kDrawingViewDrawModeFreeHand) {
                [self setDrawingMode:kDrawingViewDrawModeFreeHand];
                [self.shapeButton setTitle:@"Shape"];
                self.selectedShapeIndex = NSNotFound;
            }
            [self.toolButton setTitle:[actionSheet buttonTitleAtIndex:buttonIndex]];
        }
    }else if (actionSheet.tag == kActionSheetShape){
        switch (buttonIndex) {
            case 0:
                _shapeToolType = kShapeToolTypeSelect;
                break;
            case 1:{
                _shapeToolType = kShapeToolTypeImage;
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                ImagePickerViewController *ipc = [sb instantiateViewControllerWithIdentifier:@"ImagePickerIdentfier"];

                self.colorPicker = [[UIPopoverController alloc]initWithContentViewController:ipc];
                self.colorPicker.delegate = self;
                ipc.popover = self.colorPicker;
                [self.colorPicker presentPopoverFromBarButtonItem:self.shapeButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                break;
            }
            case 2:{
                _shapeToolType = kShapeToolTypeTriangle;
                break;
            }
            case 3:{
                _shapeToolType = kShapeToolTypePentagon;
                break;
            }
            case 4:{
                _shapeToolType = kShapeToolTypePolygon;
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Seçiniz" message:@"Çokgen kenar sayısını girin:" delegate:self cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
                [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [[alertView textFieldAtIndex:0]setKeyboardType:UIKeyboardTypePhonePad];
                [alertView show];
                break;
            }
            default:
                valid = NO;
                break;
        }
        if (valid) {
            if (_drawingMode != kDrawingViewDrawModeShape) {
                [self setDrawingMode:kDrawingViewDrawModeShape];
                [self.toolButton setTitle:@"Tool"];
            }
            [self.shapeButton setTitle:[actionSheet buttonTitleAtIndex:buttonIndex]];
        }
    }
    [self enableDisableButtonsForPopover:YES];
}

#pragma mark - Hit Testing
//Tüm şekiller üzerinde tersten sıralı isabet kontrolü yap, ilk bulunan şeklin indisini döndür.
- (NSUInteger)hitTest:(CGPoint)point
{
    __block NSUInteger hitShapeIndex = NSNotFound;
    [self.shapes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id shape, NSUInteger idx, BOOL *stop) {
        if ([shape containsPoint:point]) {
            hitShapeIndex = idx;
            *stop = YES;
        }
    }];
    return hitShapeIndex;
}


#pragma mark - Touch handling
-(void)addShape:(Shape *)shape{
    [self.shapes addObject:shape];
    [self.drawingView.layer addSublayer:shape.layer];
    shape.superLayer = self.drawingView.layer;
    [self.shapeBuffer addObject:shape];
    [self refreshControlStates];
}

- (void)tapDetected:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint tapLocation = [tapRecognizer locationInView:self.drawingView];
    self.selectedShapeIndex = [self hitTest:tapLocation];
    
    //Tap noktasında önceden eklenmiş şekil yoksa, şu anki çizim moduna göre şekil ya da imaj oluştur
    if (self.selectedShapeIndex == NSNotFound) {
        if (_shapeToolType == kShapeToolTypeImage) {
            if(self.selectedImage){
                Shape *shape = [Shape shapeForImageDrawingWithImage:self.selectedImage atPoint:tapLocation];
                [self addShape:shape];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"UYARI" message:@"Önce resim seçilmelidir." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }else if(_shapeToolType == kShapeToolTypeTriangle){
            Shape *shape = [Shape shapeForShapeWithEdges:3 atPoint:tapLocation withLineWidth:self.lineWidth withColor:self.drawingColor];
            [self addShape:shape];
        }else if(_shapeToolType == kShapeToolTypePentagon){
            Shape *shape = [Shape shapeForShapeWithEdges:5 atPoint:tapLocation withLineWidth:self.lineWidth withColor:self.drawingColor];
            [self addShape:shape];
        }else if(_shapeToolType == kShapeToolTypePolygon && _polygonEdgeCount >= 3){
            Shape *shape = [Shape shapeForShapeWithEdges:_polygonEdgeCount atPoint:tapLocation withLineWidth:self.lineWidth withColor:self.drawingColor];
            [self addShape:shape];
        }
    }
}

//Konum değiştirmek için
- (void)panDetected:(UIPanGestureRecognizer *)panRecognizer
{
    switch (panRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint tapLocation = [panRecognizer locationInView:self.drawingView];
            self.selectedShapeIndex = [self hitTest:tapLocation];
            if (self.selectedShapeIndex != NSNotFound) {
                [self.selectedShape saveStateForAction:Moved];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panRecognizer translationInView:self.drawingView];
            [self.selectedShape moveBy:translation];
            [panRecognizer setTranslation:CGPointZero inView:self.drawingView];
            break;
        }case UIGestureRecognizerStateEnded:{
            if (self.selectedShape) {
                [self.selectedShape finishTransforming];
                [self refreshControlStates];
                [self.shapeBuffer addObject:self.selectedShape];
            }
            break;
        }
        default:
            break;
    }
}

//Boyutlandırmak için
-(void)pinchDetected:(UIPinchGestureRecognizer *)pinchRecognizer{
    if(self.selectedShape){
        switch (pinchRecognizer.state) {
            case UIGestureRecognizerStateBegan:{
                [self.selectedShape saveStateForAction:Transformed];
                break;
            }
            case UIGestureRecognizerStateChanged:{
                [self.selectedShape scaleBy:pinchRecognizer.scale];
                break;
            }
            case UIGestureRecognizerStateEnded:{
                [self.selectedShape finishTransforming];
                [self refreshControlStates];
                [self.shapeBuffer addObject:self.selectedShape];
                break;
            }                
            default:
                break;
        }
        pinchRecognizer.scale = 1;
    }
}

//Döndürmek için
-(void)rotationDetected:(UIRotationGestureRecognizer *)rotationRecognizer{
    if (self.selectedShape) {
        switch (rotationRecognizer.state) {
            case UIGestureRecognizerStateBegan:{
                [self.selectedShape saveStateForAction:Transformed];
                break;
            }
            case UIGestureRecognizerStateChanged:{
                [self.selectedShape rotateBy:rotationRecognizer.rotation];
                break;
            }
            case UIGestureRecognizerStateEnded:{
                [self.selectedShape finishTransforming];
                [self refreshControlStates];
                [self.shapeBuffer addObject:self.selectedShape];
                break;
            }
            default:
                break;
        }
        rotationRecognizer.rotation = 0;
    }
}

//Aynı anda döndürme, konumlandırma ve boyutlandırma etkileşimi çalışsın mı
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

//Sebest çizim modunda kullanılıyor. İlk dokunuşta bir shape oluşturup en son MDDrawingLayer üzerine ekliyor
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_drawingMode == kDrawingViewDrawModeFreeHand) {
        mouseSwiped = NO;
        UITouch *touch = [touches anyObject];
        lastPoint = [touch locationInView:self.drawingView];
        if (lastPoint.y < 0) {

            return;
        }
        lastRectangle = CGRectMake(lastPoint.x, lastPoint.y, 0, 0);
        UIColor *clr = self.drawingColor;
        if(_drawToolType == kDrawToolTypeEraser)
            clr = self.drawingView.backgroundColor;
        self.lastShape = [Shape shapeForHandDrawingWithLineColor:clr lineWidth:self.lineWidth origin:lastPoint drawToolType:_drawToolType];
        [self.shapeBuffer addObject:self.lastShape];

        if (_drawToolType == kDrawToolTypeSquare) {
            [self.lastShape.layer setLineJoin:kCALineJoinMiter];
        }
        [self.lastDrawingLayer addShape:self.lastShape];
    }
}
//Çizim tipine göre kontroller
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_drawingMode == kDrawingViewDrawModeFreeHand) {
        mouseSwiped = YES;
        
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.drawingView];
        CGPoint currentPointInLayer = CGPointMake(currentPoint.x - self.lastShape.layer.position.x, currentPoint.y - self.lastShape.layer.position.y);
        
//        CGFloat _left = currentPoint.x - 2 * kDefaultLineWidth;
//        CGFloat _top = currentPoint.y - 2 * kDefaultLineWidth;
//        CGFloat _wdth = currentPoint.x  + 2 * kDefaultLineWidth;
//        CGFloat _hght = currentPoint.y - lastRectangle.origin.y + 2 * kDefaultLineWidth;
        
        refreshRectangle = CGRectMake(0, 0, currentPointInLayer.x, currentPointInLayer.y);
        self.lastShape.startPoint = CGPointMake(MIN(currentPoint.x, lastRectangle.origin.x), MIN(currentPoint.y, lastRectangle.origin.y));
        self.lastShape.size = (CGSizeMake(ABS(currentPoint.x - lastRectangle.origin.x), ABS(currentPoint.y - lastRectangle.origin.y)));
        if (_drawToolType == kDrawToolTypeEraser || _drawToolType == kDrawToolTypePen) {
            CGMutablePathRef path = CGPathCreateMutableCopy(self.lastShape.layer.path);
            CGPathAddLineToPoint(path, NULL, currentPointInLayer.x, currentPointInLayer.y);
            CGPathRef layerPath = CGPathCreateCopy(path);
            CGPathRelease(path);
            self.lastShape.layer.path = layerPath;
            CGPathRelease(layerPath);
        }
        else{
            CGMutablePathRef path = CGPathCreateMutable();
            if (_drawToolType == kDrawToolTypeSquare){
                CGPathAddRect(path, NULL, refreshRectangle);
            }
            else if(_drawToolType == kDrawToolTypeCircle)
                CGPathAddEllipseInRect(path, NULL, refreshRectangle);
            else{
                self.lastShape.startPoint = CGPointMake(lastRectangle.origin.x, lastRectangle.origin.y);
                self.lastShape.size = CGSizeMake(currentPoint.x - lastRectangle.origin.x, currentPoint.y - lastRectangle.origin.y);
                CGPathMoveToPoint(path, NULL, 0, 0);
                CGPathAddLineToPoint(path, NULL, currentPointInLayer.x, currentPointInLayer.y);
            }
            CGPathRef layerPath = CGPathCreateCopy(path);
            CGPathRelease(path);
            self.lastShape.layer.path = layerPath;
            CGPathRelease(layerPath);
        }
                //NSLog(@"StartPoint:%@ Size:%@", NSStringFromCGPoint(self.lastShape.startPoint), NSStringFromCGSize(self.lastShape.size));
        lastPoint = currentPoint;
    }
}

//Çizim hareketi sonu. Yani el kaldırılması
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_drawingMode == kDrawingViewDrawModeFreeHand) {
        if (mouseSwiped || _drawToolType == kDrawToolTypePen || _drawToolType == kDrawToolTypeEraser) {
            if (!mouseSwiped) {
                [self touchesMoved:touches withEvent:event];
            }
            [self.lastDrawingLayer flattenLayers];
            [self refreshControlStates];
        }
        self.lastShape = nil;
    }
}


#pragma mark - UIPopoverDelegate Member
-(void)enableDisableButtonsForPopover:(BOOL)enable{
    self.toolButton.enabled = enable;
    self.shapeButton.enabled = enable;
    self.settingButton.enabled = enable;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    if ([popoverController.contentViewController isKindOfClass:[ColorPickerViewController class]]) {
        ColorPickerViewController *cpv = (ColorPickerViewController*)popoverController.contentViewController;
        self.drawingColor = cpv.lineColor;
        _lineWidth = cpv.lineWidth;
    }else if([popoverController.contentViewController isKindOfClass:[ImagePickerViewController class]]){
        ImagePickerViewController *ipc = (ImagePickerViewController*)popoverController.contentViewController;
        if (ipc.selectedImage) {
            self.selectedImage = ipc.selectedImage;
        }
    }
    [self enableDisableButtonsForPopover:YES];
}
@end
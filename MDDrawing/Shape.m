//
//  Shape.m
//  PathHitTesting
//
//  Created by Mahmut Duman on 30.01.12.
//  Copyright (c) 2012 Mahmut Duman. All rights reserved.
//

#define kDefaultEdgeLenth   120

#import "Shape.h"
#import "MDDrawingLayer.h"


struct ShapeState{
    CATransform3D transform;
    CGPoint location;
    ShapeAction action;
};
typedef struct ShapeState ShapeState;

@interface Shape ()
//Şekil için ilk oluşturma esnasındaki frame
@property (nonatomic, assign) CGRect initialFrame;
//Geometrik şekil için kenar sayısı
@property (nonatomic, assign) NSInteger edges;

@property (nonatomic, strong)NSMutableArray *states;
@property (nonatomic, strong)NSMutableArray *redoStates;
//Geometrik Şekil için Path döndürür.
- (CGPathRef)newPathForShapeAtPoint:(CGPoint)point;
//Cizim modundan donusen sekil icin Path dondurur
- (CGPathRef)newPathForDrawingShape;

@end


@implementation Shape
@synthesize startPoint = _startPoint;
@synthesize size = _size;
@synthesize edges = _edges;
@synthesize shapeType = _shapeType;
@synthesize layer = _layer;
@synthesize initialFrame = _initialFrame;
@synthesize states = _states, redoStates = _redoStates;
@synthesize drawingLayer = _drawingLayer;


+(id)shapeForHandDrawingWithLineColor :(UIColor *)lineColor lineWidth:(CGFloat)lineWidth origin:(CGPoint)point drawToolType:(NSInteger)tooltype{
    Shape *shape = [[Shape alloc]initWithToolType:tooltype];
    shape.layer.shadowColor = [UIColor yellowColor].CGColor;
    [shape.layer setLineWidth:lineWidth];
    [shape.layer setLineJoin:kCALineJoinRound];
    [shape.layer setLineCap:kCALineCapRound];
    [shape.layer setStrokeColor:lineColor.CGColor];
    shape.layer.fillColor = [UIColor clearColor].CGColor;
    [shape.layer setPosition:point];
    shape.layer.opaque = YES;
    shape.layer.opacity = 1.0;
    CGMutablePathRef pth = CGPathCreateMutable();
    CGPathMoveToPoint(pth, NULL, 0,0);
    shape.layer.path = pth;
    CGPathRelease(pth);
    return shape;

}

+(id)shapeForImageDrawingWithImage:(UIImage *)image atPoint:(CGPoint)point{
    Shape *shape = [[Shape alloc]initWithShapeType:kShapeTypeImage];
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    CGRect shapeFrame = CGRectMake(point.x - width/2, point.y- height/2, width, height);
    shape.initialFrame = shapeFrame;
    CGPathRef path = CGPathCreateWithRect(shapeFrame, NULL);
    shape.tapTarget = path;
    CGPathRelease(path);
    [shape.layer setFillColor:[UIColor clearColor].CGColor];
    shape.layer.contents = (id)image.CGImage;
    shape.layer.opaque = YES;

    [shape.layer setFrame:shapeFrame];
    [shape.layer setStrokeColor:[UIColor blackColor].CGColor];
    [shape.layer setLineWidth:1.0f];
    [shape.layer setFillColor:[UIColor clearColor].CGColor];
    [shape.layer setLineJoin:kCALineJoinRound];
    [shape.layer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:3],
      [NSNumber numberWithInt:3],nil]];
    return shape;
}

+(id)shapeForShapeWithEdges:(NSInteger)edges atPoint:(CGPoint)point withLineWidth:(CGFloat)lineWidth withColor:(UIColor *)color{
    Shape *shape = [[Shape alloc]initWithShapeType:kShapeTypeShape];
    shape.edges = edges;
    [shape.layer setLineWidth:lineWidth];
    shape.layer.shadowColor = [UIColor yellowColor].CGColor;
    [shape.layer setLineJoin:kCALineJoinMiter];
    [shape.layer setLineCap:kCALineCapRound];
    [shape.layer setStrokeColor:color.CGColor];
    [shape.layer setPosition:point];
    shape.layer.fillColor = [UIColor clearColor].CGColor;
    shape.layer.opaque = YES;
    shape.layer.opacity = 1.0;
    CGPathRef path = [shape newPathForShapeAtPoint:CGPointMake(0, 0)];
    shape.layer.path = path;
    CGPathRelease(path);
    CGPathRef tapPath = [shape newPathForShapeAtPoint:point];
    shape.tapTarget = tapPath;
    CGPathRelease(tapPath);
    return shape;
}

-(CGPathRef)newPathForShapeAtPoint:(CGPoint)point{
    CGMutablePathRef pth = CGPathCreateMutable();
    CGPathMoveToPoint(pth, NULL, point.x, point.y);
    
    float j = kDefaultEdgeLenth; //length of each edge
    float angle = 2*M_PI;
    float x = point.x - j/2;
    float y = point.y + j/2;
    CGPathMoveToPoint(pth, NULL, x, y);
    for (int i = 0; i < _edges; i++) {
        
        //CGRect frame = CGRectMake(x, y, 2, 2);//put a dot on x,y
        CGPathAddLineToPoint(pth, NULL, x, y);
        //NSLog(@"%f | %f, %f", angle, x, y);
        x = x + j*cosf(angle);
        y = y + j*sinf(angle); //move to the next point
        angle = angle - 2*M_PI/_edges; //update the angle
    }
    CGPathCloseSubpath(pth);
    return (CGPathRef)pth;

}

-(CGPathRef)newPathForDrawingShape
{
    CGMutablePathRef pth = CGPathCreateMutable();
    CGPathMoveToPoint(pth, NULL, self.startPoint.x, self.startPoint.y);
    if (self.drawToolType == kDrawToolTypeLine) {
        CGPathAddLineToPoint(pth, NULL, self.startPoint.x + self.size.width, self.startPoint.y + self.size.height);
        CGPathRef linePath = CGPathCreateCopyByStrokingPath(pth, NULL, self.layer.lineWidth*3, kCGLineCapRound, kCGLineJoinMiter, self.layer.miterLimit);
        CGPathRelease(pth);
        return linePath;
    }else if(self.drawToolType == kDrawToolTypeSquare){
        CGPathAddRect(pth, NULL, CGRectMake(self.startPoint.x, self.startPoint.y, self.size.width, self.size.height));
    }else{  //Ellipse
        CGPathAddEllipseInRect(pth, NULL, CGRectMake(self.startPoint.x, self.startPoint.y, self.size.width, self.size.height));
    }
    return (CGPathRef)pth;
    
}

- (id)init
{
    self.layer = [CAShapeLayer layer];
    _states = [NSMutableArray array];
    _redoStates = [NSMutableArray array];
    [self saveStateForAction:Added];
    return self;
}

-(id)initWithShapeType:(NSInteger)shapeType{
    _shapeType = shapeType;
    return [self init];
}

-(id)initWithToolType:(NSInteger)toolType{
    _shapeType = kShapeTypeDrawing;
    _drawToolType = toolType;
    return [self init];
}

#pragma mark - History Support

-(void)saveStateForAction:(ShapeAction)action{
    ShapeState shapeState;
    shapeState.action = action;
    shapeState.location = self.layer.position;
    shapeState.transform = self.layer.transform;
    [self.states addObject:[NSValue valueWithBytes:&shapeState objCType:@encode(ShapeState)]];
}

-(void)undoWithArray:(NSMutableArray *)array{
    ShapeState undoState;
    if (self.shapeType == kShapeTypeDrawing) {
        //Remove and Refresh layer
        [self.drawingLayer removeShape:self];
    }else{
        ShapeState state;
        [self.states.lastObject getValue:&state];
        undoState.action = state.action;
        switch (state.action) {
            case Added:{
                [array removeObject:self];
                [self.layer removeFromSuperlayer];
                break;
            }
            case Deleted:{
                [array addObject:self];
                [self.superLayer addSublayer:self.layer];
                break;
            }
            case Moved:{
                undoState.location = self.layer.position;
                self.layer.position = state.location;
                break;
            }
            case Transformed:{
                undoState.transform = self.layer.transform;
                self.layer.transform = state.transform;
                break;
            }
            default:
                break;
        }
        [self finishTransforming];
    }
    [self.redoStates addObject:[NSValue valueWithBytes:&undoState objCType:@encode(ShapeState)]];
    [self.states removeLastObject];
}

-(void)redoWithArray:(NSMutableArray *)array{
    ShapeState redoState;
    if (self.shapeType == kShapeTypeDrawing) {
        //Remove and Refresh layer
        [self.drawingLayer addShape:self];
    }else{
        ShapeState state;
        [self.redoStates.lastObject getValue:&state];
        redoState.action = state.action;
        switch (state.action) {
            case Added:{
                [array addObject:self];
                [self.superLayer addSublayer:self.layer];
                break;
            }
            case Deleted:{
                [array removeObject:self];
                [self.layer removeFromSuperlayer];
                break;
            }
            case Moved:{
                redoState.location = self.layer.position;
                self.layer.position = state.location;
                break;
            }
            case Transformed:{
                redoState.transform = self.layer.transform;
                self.layer.transform = state.transform;
                break;
            }
            default:
                break;
        }
        [self finishTransforming];
        
    }
    [self.states addObject:[NSValue valueWithBytes:&redoState objCType:@encode(ShapeState)]];
    [self.redoStates removeLastObject];
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Shape: %p - Bounds: %@>", self, NSStringFromCGRect(CGPathGetPathBoundingBox(self.layer.path))];
}


#pragma mark - Hit Testing

- (BOOL)containsPoint:(CGPoint)point
{
    if (self.drawToolType== kDrawToolTypeLine) {
        return CGRectContainsPoint(CGPathGetPathBoundingBox(self.tapTarget), point);
    }
    return CGPathContainsPoint(self.tapTarget, NULL, point, NO);
}



#pragma mark - Modifying Shapes
//Bu fonksiyon, buyutup kucultme ve dondurme islemlerinde, sekle ait tiklama alaninin tekrardan atanmasini saglar.
//Boylelikle, kullanici ekrana tikladiginda dogru sekli secebilmis olur.
-(void)finishTransforming{
    //if(self.shapeType == kShapeTypeImage){
    CGFloat angle = [(NSNumber *)[self.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
    CGFloat currentScale = [[self.layer valueForKeyPath: @"transform.scale.x"] floatValue];
    CGAffineTransform transform = CGAffineTransformIdentity;

    if (self.shapeType == kShapeTypeImage) {
            CGRect targetFrame =CGRectMake(
                                self.layer.position.x - self.initialFrame.size.width / 2.0,
                                self.layer.position.y - self.initialFrame.size.height / 2.0,
                                self.initialFrame.size.width, self.initialFrame.size.height);
        CGPoint center = CGPointMake(CGRectGetMidX(targetFrame), CGRectGetMidY(targetFrame));
        transform = CGAffineTransformTranslate(transform, center.x, center.y);
        transform = CGAffineTransformRotate(transform, angle);
        transform = CGAffineTransformScale(transform, currentScale, currentScale);
        transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
        //transform = CATransform3DGetAffineTransform(self.layer.transform);
        CGPathRef path = CGPathCreateWithRect(targetFrame, &transform);
        self.tapTarget = path;
        CGPathRelease(path);
    }else if(self.shapeType == kShapeTypeShape){
        CGPathRef path;
        if (self.drawToolType > 0) {//Cizimden donusen sekil ise
            path = [self newPathForDrawingShape];
        }else{  //Sekil ise
            path = [self newPathForShapeAtPoint:self.layer.position];
        }

        
        CGRect bounds = CGPathGetPathBoundingBox(path); // might want to use CGPathGetPathBoundingBox
        CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        transform = CGAffineTransformTranslate(transform, center.x, center.y);
        transform = CGAffineTransformRotate(transform, angle);
        if (self.drawToolType != kDrawToolTypeLine) {
            transform = CGAffineTransformScale(transform, currentScale, currentScale);
        }

        transform = CGAffineTransformTranslate(transform, -center.x, -center.y);
        CGPathRef newPath = CGPathCreateCopyByTransformingPath(path, &transform);
        CGPathRelease(path);
        self.tapTarget = newPath;
        CGPathRelease(newPath);
    }
}

- (void)moveBy:(CGPoint)delta
{
//    if (self.shapeType == kShapeTypeImage) {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.layer.position = CGPointMake(self.layer.position.x + delta.x, self.layer.position.y + delta.y);
    if (self.drawToolType > 0) {
        self.startPoint = CGPointMake(self.startPoint.x + delta.x, self.startPoint.y + delta.y);
    }
    [CATransaction commit];
 //   }
}

-(void)convertToShape{
    _shapeType = kShapeTypeShape;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-self.size.width/2.0, -self.size.height / 2.0);
    CGPathRef path = CGPathCreateCopyByTransformingPath(self.layer.path, &transform);
    
    self.layer.position = CGPointMake(self.layer.position.x + self.size.width/2.0, self.layer.position.y + self.size.height / 2.0);
    self.layer.path = path;
    [CATransaction commit];
    CGPathRelease(path);
    CGPathRef newPath = [self newPathForDrawingShape];
    self.tapTarget = newPath;
    CGPathRelease(newPath);
}

-(void)scaleBy:(CGFloat)scaleFactor{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.layer.transform = CATransform3DScale(self.layer.transform, scaleFactor, scaleFactor, 1);
    [CATransaction commit];
}

-(void)rotateBy:(CGFloat)angle{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CATransform3D current = self.layer.transform;
    self.layer.transform = CATransform3DRotate(current, angle, 0, 0, 1);
    [CATransaction commit];
}

-(void)selectShape{
    if (self.shapeType == kShapeTypeImage) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.1];
        CGPathRef path =CGPathCreateWithRect(self.layer.bounds, NULL);
        [self.layer setPath:path];
        CGPathRelease(path);
        [CATransaction commit];
    }else if(self.shapeType == kShapeTypeShape){
        self.layer.shadowOpacity = 0.4;
        if (self.drawToolType == kDrawToolTypeLine) {
            CGPathRef shadowPath = CGPathCreateCopyByStrokingPath(self.layer.path, NULL, self.layer.lineWidth*3, kCGLineCapRound, kCGLineJoinMiter, self.layer.miterLimit);
            self.layer.shadowPath = shadowPath;
            CGPathRelease(shadowPath);
        }else{
            self.layer.shadowPath= self.layer.path;
        }
    }
}
- (void)deselectShape{
    if (self.shapeType == kShapeTypeImage) {
        self.layer.path = nil;
    }else if(self.shapeType == kShapeTypeShape){
        self.layer.shadowOpacity = 0.0;
        self.layer.shadowPath = nil;
        self.layer.shadowRadius=0;
    }

}

@end

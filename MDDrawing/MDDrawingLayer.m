//
//  MDDrawingLayer.m
//  MDDrawingPad
//
//  Created by Mahmut Duman on 13/09/14.
//  Copyright (c) 2014 Mahmut Duman. All rights reserved.
//

#import "MDDrawingLayer.h"

@interface MDDrawingLayer ()
//Mevcut Shape nesnelerini tekrar cizmek icin..
-(void)refreshLayer;
@property(nonatomic, strong)NSMutableArray *shapes;
@end

@implementation MDDrawingLayer

-(id)init{
    self = [super init];
    _layer = [CAShapeLayer layer];
    self.layer.opacity = 1.0;
    self.layer.opaque = YES;
    self.layer.allowsGroupOpacity = NO;
    _shapes = [NSMutableArray array];
    return self;
}

+(MDDrawingLayer *)drawingLayerForShape{
    MDDrawingLayer *layer = [[MDDrawingLayer alloc]init];
    return layer;
}

+(MDDrawingLayer *)drawingLayerForFreehand{
    MDDrawingLayer *layer = [[MDDrawingLayer alloc]init];
    return layer;
}

-(void)addShape:(Shape *)shape{
    [self.shapes addObject:shape];
    shape.drawingLayer = self;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.layer addSublayer:shape.layer];
    [CATransaction commit];
}

- (void)removeShape:(Shape *)shape{
    [self.shapes removeObject:shape];
    [self refreshLayer];
}

-(void)flattenLayers{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    UIGraphicsBeginImageContext(self.layer.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.layer.sublayers = nil;
    self.layer.contents = (id)image.CGImage;
    [CATransaction commit];
}

//Sekil haricindeki kalanlari tekrar ciz...
-(void)refreshLayer{
    self.layer.contents = nil;
    for (Shape *shape in self.shapes) {
        [self.layer addSublayer:shape.layer];
    }
    [self flattenLayers];
}

-(void)convertShapeDrawingsWithAddingTo:(NSMutableArray *)array{
    for (int i=0; i<self.shapes.count; i++) {
        Shape *shape = (Shape*)[self.shapes objectAtIndex:i];
        if(shape.drawToolType == kDrawToolTypeCircle || shape.drawToolType == kDrawToolTypeLine || shape.drawToolType == kDrawToolTypeSquare){
            [shape convertToShape];
            //Listye ekle
            [array addObject:shape];
            //Editor uzerine ekle
            [self.layer.superlayer addSublayer:shape.layer];
            [self.shapes removeObject:shape];
            shape.drawingLayer = nil;
            i--;
        }
    }
    [self refreshLayer];
}

@end

//
//  MDDrawingLayer.h
//  MDDrawingPad




/*  Çizim işlemleri için kullanılacak. Her çizim hareketi bittiğinde yani el kaldırıldığında,
 *  Çizilen kısmı imaj yapıp kendi layerına kaydediyor. Çizim modundan şekil moduna geçildiğinde, bu 
 *  kaydediliyor. Bir sonraki çizim modunda yeni bir tane oluşturuluyor
 */
//  Created by Mahmut Duman on 13/09/14.
//  Copyright (c) 2014 Mahmut Duman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Shape.h"
@interface MDDrawingLayer : NSObject{

}
@property(nonatomic, strong, readonly) CAShapeLayer *layer;
+ (MDDrawingLayer*)drawingLayerForFreehand;
+ (MDDrawingLayer*)drawingLayerForShape;
- (void)addShape:(Shape*)shape;
- (void)removeShape:(Shape*)shape;
//Çizim hareketi bittiğinde, çizilen kısmı imaj yapıp layera kaydet. Performans için.
- (void)flattenLayers;
//Cizim modundan sekil moduna gecildiginde, sekilleri layer yapar. Olusturdugu nesneleri Verilen listeye ekler
- (void)convertShapeDrawingsWithAddingTo:(NSMutableArray*)array;
@end

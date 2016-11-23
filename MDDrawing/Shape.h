//
//  Shape.h
//  MDDrawingPad
//
/* Ekranda yapılan her çizim türü için 1 tane oluşturulur. Çizim işlemlerinde,
 sürükle hareketi bitip el kaldırıldığında, şekil işlemlerinde ise, şekil başına 1 tane
 eklenir.
 
 */
//  Created by Mahmut Duman on 30.01.12.
//  Copyright (c) 2012 Mahmut Duman. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

#define kDrawToolTypePen    11
#define kDrawToolTypeLine   12
#define kDrawToolTypeSquare 13
#define kDrawToolTypeCircle 14
#define kDrawToolTypeEraser 15

#define kShapeTypeDrawing   1
#define kShapeTypeImage     2
#define kShapeTypeShape     3

#define kDefaultLineWidth   3.0f

typedef enum{
    Added,
    Deleted,
    Moved,
    Transformed
} ShapeAction;

@class MDDrawingLayer;
@class ViewController;
@interface Shape : NSObject{
}
//Elle çizim için Shape nesnesi döndürür.
+ (id)shapeForHandDrawingWithLineColor:(UIColor *)lineColor lineWidth:(CGFloat)lineWidth origin:(CGPoint)point drawToolType:(NSInteger)tooltype;
//Resim için Shape nesnesi döndürür
+ (id)shapeForImageDrawingWithImage:(UIImage*)image atPoint:(CGPoint)point;
//Geometrik şekil için Shape nesnesi döndürür.
+ (id)shapeForShapeWithEdges:(NSInteger)edges atPoint:(CGPoint)point withLineWidth:(CGFloat)lineWidth withColor:(UIColor*)color;

//Ekranda dokunulan bir nokta, şekil ya da resim üzerine denk geliyor mu kontrolünü yapar
- (BOOL)containsPoint:(CGPoint)point;
//Seçili resim ya da şekli delta kadar yer değiştiri.
- (void)moveBy:(CGPoint)delta;
//Seçili resim ya da şekli scaleFactor kadar boyutlandırı.
- (void)scaleBy:(CGFloat)scaleFactor;
//Seçili resim ya da şekli angle açısı kadar döndürür.
- (void)rotateBy:(CGFloat)angle;
//Resim ve şekil modunda tıklanan şekli ya da resmin seçildiğine ait bir çizim yapar.
//Resim için kesik çizgi, şekil için açık sarı boyama yapar.
- (void)selectShape;
//Seçim için yapılan boyamayı ya da çizimi kaldırır
- (void)deselectShape;
//Yeni Shape nesnesini verilen türden oluşturur
- (id)initWithShapeType:(NSInteger) shapeType;
//Yeni Shape nesnesini verilen kDrawTool türunden oluşturur
- (id)initWithToolType:(NSInteger) toolType;
//Kullanıcı hareketi tamamlandığında (Konum değiştirme, boyut değiştirme ya da döndürme)
//Şekli ya da resmi tekrar seçebilmek için gerekli hesaplamayı yapıp tapTarget değişkenine atar
- (void)finishTransforming;
//Çizim modunda çizilen şekilleri (silgi ve kalem dışında), Editör şekil moduna geçtiğinde şekle dönüştürmek için kullanılıyor.
- (void)convertToShape;

-(void)undoWithArray:(NSMutableArray*)array;
-(void)redoWithArray:(NSMutableArray *)array;

-(void)saveStateForAction:(ShapeAction)action;

@property (nonatomic, strong) __attribute__((NSObject)) CGPathRef tapTarget;
@property (nonatomic, strong) CAShapeLayer *layer;
@property (nonatomic, strong) CALayer *superLayer;
@property (nonatomic, strong) MDDrawingLayer *drawingLayer;
@property (nonatomic, assign, readonly) NSInteger shapeType;
@property (nonatomic, assign, readonly) NSInteger drawToolType;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGSize size;;

@end

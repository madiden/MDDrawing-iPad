//
//  ImagePickerViewController.m
//  MDDrawingPad
//
//  Created by Mahmut Duman on 10/09/14.
//  Copyright (c) 2014 Mahmut Duman. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "ImagePickerCell.h"

@interface ImagePickerViewController ()<UICollectionViewDelegateFlowLayout>
-(void)reloadImages;
@end

@implementation ImagePickerViewController
@synthesize images=_images;
@synthesize selectedImage = _selectedImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadImages];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadImages{
    self.images = [NSMutableArray arrayWithObjects:
                   [UIImage imageNamed:@"1.jpeg"],
                   [UIImage imageNamed:@"2.jpeg"],
                   [UIImage imageNamed:@"3.jpeg"],nil];
}

#pragma mark - CollectionViewController Overridden Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"drawingImageCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.borderWidth = 1.0;
    cell.imageView.image = [self.images objectAtIndex:indexPath.row];
    cell.imageLabel.text = cell.imageView.image.description;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedImage = [self.images objectAtIndex:indexPath.row];
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        [self.popover.delegate popoverControllerDidDismissPopover:self.popover];
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(2, 2, 2, 2);
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

@end

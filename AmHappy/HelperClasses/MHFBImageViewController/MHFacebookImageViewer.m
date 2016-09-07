//
// MHFacebookImageViewer.m
// Version 2.0
//
// Copyright (c) 2013 Michael Henry Pantaleon (http://www.iamkel.net). All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "MHFacebookImageViewer.h"
#import "UIImageView+AFNetworking.h"
#import <objc/runtime.h>



static const CGFloat kMinBlackMaskAlpha = 0.3f;
static const CGFloat kMaxImageScale = 2.5f;
static const CGFloat kMinImageScale = 1.0f;


@interface MHFacebookImageViewerCell : UITableViewCell<UIGestureRecognizerDelegate,UIScrollViewDelegate>{
    UIImageView * __imageView;
    UIScrollView * __scrollView;
    NSMutableArray *_gestures;
    CGPoint _panOrigin;
    BOOL _isAnimating;
    BOOL _isDoneAnimating;
    BOOL _isLoaded;
    
    
    
    //******* Add Another Subviews
    
    //**** Step 1
    imageLikeComment *objLikeComment;
    UIView *TopHeader;
    
    
}


//**** Step 2
@property(nonatomic,weak) imageLikeComment * viewLikeComment;
@property(nonatomic,weak) UIView *TopHeader;


@property(nonatomic,assign) CGRect originalFrameRelativeToScreen;
@property(nonatomic,weak) UIViewController * rootViewController;
@property(nonatomic,weak) UIViewController * viewController;
@property(nonatomic,weak) UIView * blackMask;
@property(nonatomic,weak) UIButton * doneButton;
@property(nonatomic,weak) UIButton * SaveButton;

@property(nonatomic,weak) UIImageView * senderView;
@property(nonatomic,assign) NSInteger imageIndex;

@property(nonatomic,weak) UIImage * defaultImage;
@property(nonatomic,assign) NSInteger initialIndex;
@property(nonatomic,strong) UIPanGestureRecognizer* panGesture;

@property (nonatomic,weak) MHFacebookImageViewerOpeningBlock openingBlock;
@property (nonatomic,weak) MHFacebookImageViewerClosingBlock closingBlock;

@property(nonatomic,weak) UIView * superView;

@property(nonatomic) UIStatusBarStyle statusBarStyle;

- (void) loadAllRequiredViews;
- (void) setImageURL:(NSURL *)imageURL defaultImage:(UIImage*)defaultImage imageIndex:(NSInteger)imageIndex;

@end

@implementation MHFacebookImageViewerCell

@synthesize originalFrameRelativeToScreen = _originalFrameRelativeToScreen;
@synthesize rootViewController = _rootViewController;
@synthesize viewController = _viewController;
@synthesize blackMask = _blackMask;
@synthesize closingBlock = _closingBlock;
@synthesize openingBlock = _openingBlock;
@synthesize doneButton = _doneButton;
@synthesize SaveButton = _SaveButton;



//***** Step 3
@synthesize viewLikeComment = _viewLikeComment;
@synthesize TopHeader = _TopHeader;

@synthesize senderView = _senderView;
@synthesize imageIndex = _imageIndex;
@synthesize superView = _superView;
@synthesize defaultImage = _defaultImage;
@synthesize initialIndex = _initialIndex;
@synthesize panGesture = _panGesture;

- (void) loadAllRequiredViews{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect frame = [UIScreen mainScreen].bounds;
    __scrollView = [[UIScrollView alloc]initWithFrame:frame];
    __scrollView.delegate = self;
    __scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:__scrollView];
    [_doneButton addTarget:self
                    action:@selector(close:)
          forControlEvents:UIControlEventTouchUpInside];
   
   /* [_SaveButton addTarget:self
                    action:@selector(save:)
          forControlEvents:UIControlEventTouchUpInside];*/
}

- (void) setImageURL:(NSURL *)imageURL defaultImage:(UIImage*)defaultImage imageIndex:(NSInteger)imageIndex
{
    _imageIndex = imageIndex;
    _defaultImage = defaultImage;
    
  
        _senderView.alpha = 0.0f;
        if(!__imageView){
            
            __imageView = [[UIImageView alloc]init];
            __imageView.tag = 100;
            __scrollView.tag = 500;
            [__scrollView addSubview:__imageView];
            
  
            __imageView.contentMode = UIViewContentModeScaleAspectFill;
            
            
            //******** add like Comment View Here
            
          
            
            
            
            
        }
        __block UIImageView * _imageViewInTheBlock = __imageView;
        __block MHFacebookImageViewerCell * _justMeInsideTheBlock = self;
        __block UIScrollView * _scrollViewInsideBlock = __scrollView;

        [__imageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:defaultImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [_scrollViewInsideBlock setZoomScale:1.0f animated:YES];
            [_imageViewInTheBlock setImage:image];
            _imageViewInTheBlock.frame = [_justMeInsideTheBlock centerFrameFromImage:_imageViewInTheBlock.image];

        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Image From URL Not loaded");
        }];

        if(_imageIndex==_initialIndex && !_isLoaded)
        {
            __imageView.frame = _originalFrameRelativeToScreen;
            [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
                __imageView.frame = [self centerFrameFromImage:__imageView.image];
                CGAffineTransform transf = CGAffineTransformIdentity;
                // Root View Controller - move backward
                _rootViewController.view.transform = CGAffineTransformScale(transf, 0.95f, 0.95f);
                // Root View Controller - move forward
                //                _viewController.view.transform = CGAffineTransformScale(transf, 1.05f, 1.05f);
                _blackMask.alpha = 1;
            }   completion:^(BOOL finished) {
                if (finished) {
                    _isAnimating = NO;
                    _isLoaded = YES;
                    if(_openingBlock)
                        _openingBlock();
                }
            }];

        }
        __imageView.userInteractionEnabled = YES;
        [self addPanGestureToView:__imageView];
        [self addMultipleGesture];

}

#pragma mark - Add Pan Gesture
- (void) addPanGestureToView:(UIView*)view
{
/*_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerDidPan:)];
    _panGesture.cancelsTouchesInView = NO;
    _panGesture.delegate = self;
     __weak UITableView * weakSuperView = (UITableView*) view.superview.superview.superview.superview.superview;
   // [weakSuperView.panGestureRecognizer requireGestureRecognizerToFail:_panGesture];
    [view addGestureRecognizer:_panGesture];
    [_gestures addObject:_panGesture];*/
    
    
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerDidPan:)];
    _panGesture.cancelsTouchesInView = NO;
    _panGesture.delegate = self;
    
    __weak UIView *weakSuperView = view.superview;
    while (![weakSuperView isKindOfClass:[UITableView class]]) {
        weakSuperView = weakSuperView.superview;
        if (weakSuperView == Nil) {
            break;
        }
    }
    
    if ([weakSuperView isKindOfClass:[UITableView class]]) {
        [((UITableView*)weakSuperView).panGestureRecognizer requireGestureRecognizerToFail:_panGesture];
    }
    
    
    [view addGestureRecognizer:_panGesture];
    [_gestures addObject:_panGesture];

}

# pragma mark - Avoid Unwanted Horizontal Gesture
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:__scrollView];
    return fabs(translation.y) > fabs(translation.x) ;
}

#pragma mark - Gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    _panOrigin = __imageView.frame.origin;
    gestureRecognizer.enabled = YES;
    return !_isAnimating;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if(gestureRecognizer == _panGesture) {
        return YES;
    }
    return NO;
}

#pragma mark - Handle Panning Activity
- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGesture {
    if(__scrollView.zoomScale != 1.0f || _isAnimating)return;
    if(_imageIndex==_initialIndex)
    {
        if(_senderView.alpha!=0.0f)
            _senderView.alpha = 0.0f;
    }else {
        if(_senderView.alpha!=1.0f)
            _senderView.alpha = 1.0f;
    }
    // Hide the Done Button
    [self hideDoneButton];
    [self hidesaveButton];
    [self hideimgLikeComment];
    [self hideTopHeader];
    
    __scrollView.bounces = NO;
    CGSize windowSize = _blackMask.bounds.size;
    CGPoint currentPoint = [panGesture translationInView:__scrollView];
    CGFloat y = currentPoint.y + _panOrigin.y;
    CGRect frame = __imageView.frame;
    frame.origin.y = y;

    __imageView.frame = frame;

    CGFloat yDiff = abs((y + __imageView.frame.size.height/2) - windowSize.height/2);
    _blackMask.alpha = MAX(1 - yDiff/(windowSize.height/0.5),kMinBlackMaskAlpha);

    if ((panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) && __scrollView.zoomScale == 1.0f) {

        if(_blackMask.alpha < 0.95f) {
            [self dismissViewController];
        }else {
           [self rollbackViewController];
        }
    }
}

#pragma mark - Just Rollback
- (void)rollbackViewController
{
    _isAnimating = YES;
    [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
        __imageView.frame = [self centerFrameFromImage:__imageView.image];
        _blackMask.alpha = 1;
    }   completion:^(BOOL finished) {
        if (finished) {
            _isAnimating = NO;
        }
    }];
}


#pragma mark - Dismiss
- (void)dismissViewController
{
    _isAnimating = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideDoneButton];
        [self hidesaveButton];
        [self hideimgLikeComment];
        [self hideTopHeader];
        
        __imageView.clipsToBounds = YES;
        CGFloat screenHeight =  [[UIScreen mainScreen] bounds].size.height;
        CGFloat imageYCenterPosition = __imageView.frame.origin.y + __imageView.frame.size.height/2 ;
        BOOL isGoingUp =  imageYCenterPosition < screenHeight/2;
        [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
            if(_imageIndex==_initialIndex){
                __imageView.frame = _originalFrameRelativeToScreen;
            }else {
                __imageView.frame = CGRectMake(__imageView.frame.origin.x, isGoingUp?-screenHeight:screenHeight, __imageView.frame.size.width, __imageView.frame.size.height);
            }
            CGAffineTransform transf = CGAffineTransformIdentity;
            
            _rootViewController.view.transform = CGAffineTransformScale(transf, 1.0f, 1.0f);
            _blackMask.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                [_viewController.view removeFromSuperview];
                [_viewController removeFromParentViewController];
                _senderView.alpha = 1.0f;
                [UIApplication sharedApplication].statusBarHidden = NO;
                [UIApplication sharedApplication].statusBarStyle = _statusBarStyle;
                _isAnimating = NO;
                if(_closingBlock)
                    _closingBlock();
            }
        }];
    });
}

#pragma mark - Compute the new size of image relative to width(window)
- (CGRect) centerFrameFromImage:(UIImage*) image {
    if(!image) return CGRectZero;

    CGRect windowBounds = _rootViewController.view.bounds;
    CGSize newImageSize = [self imageResizeBaseOnWidth:windowBounds
                           .size.width oldWidth:image
                           .size.width oldHeight:image.size.height];
    // Just fit it on the size of the screen
    newImageSize.height = MIN(windowBounds.size.height,newImageSize.height);
    return CGRectMake(0.0f, windowBounds.size.height/2 - newImageSize.height/2, newImageSize.width, newImageSize.height);
}

- (CGSize)imageResizeBaseOnWidth:(CGFloat) newWidth oldWidth:(CGFloat) oldWidth oldHeight:(CGFloat)oldHeight {
    CGFloat scaleFactor = newWidth / oldWidth;
    CGFloat newHeight = oldHeight * scaleFactor;
    return CGSizeMake(newWidth, newHeight);

}

# pragma mark - UIScrollView Delegate
- (void)centerScrollViewContents {
    CGSize boundsSize = _rootViewController.view.bounds.size;
    CGRect contentsFrame = __imageView.frame;

    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }

    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    __imageView.frame = contentsFrame;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return __imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _isAnimating = YES;
    
    //***** Step 7
    [self hideDoneButton];
    [self hidesaveButton];
    [self hideimgLikeComment];
    [self hideTopHeader];
    [self centerScrollViewContents];
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
    if (scale == 1.0)
    {
        [self displayCustomViews];
    }

    _isAnimating = NO;
}

- (void)addMultipleGesture
{
    
    
    //****** Step 6
    
    [self displayCustomViews];
    
    
    UITapGestureRecognizer *twoFingerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTwoFingerTap:)];
    twoFingerTapGesture.numberOfTapsRequired = 1;
    twoFingerTapGesture.numberOfTouchesRequired = 2;
    [__scrollView addGestureRecognizer:twoFingerTapGesture];

    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [__scrollView addGestureRecognizer:singleTapRecognizer];

    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDobleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [__scrollView addGestureRecognizer:doubleTapRecognizer];

    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];

    __scrollView.minimumZoomScale = kMinImageScale;
    __scrollView.maximumZoomScale = kMaxImageScale;
    __scrollView.zoomScale = 1;
    [self centerScrollViewContents];
}

#pragma mark - For Zooming
- (void)didTwoFingerTap:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = __scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, __scrollView.minimumZoomScale);
    [__scrollView setZoomScale:newZoomScale animated:YES];
}

-(void)displayCustomViews
{
    _isDoneAnimating = YES;
    
    
    //****** Step 6
    
    [self.viewController.view addSubview:_doneButton];
    [self.viewController.view addSubview:_SaveButton];
    [self.viewController.view addSubview:_viewLikeComment];
    [self.viewController.view addSubview:_TopHeader];
    
    _doneButton.alpha = 0.0f;
    _SaveButton.alpha = 0.0f;
    _viewLikeComment.alpha = 0.0f;
    _TopHeader.alpha = 0.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^
     {
         _doneButton.alpha = 1.0f;
         _SaveButton.alpha = 1.0f;
         _viewLikeComment.alpha = 1.0f;
         _TopHeader.alpha = 1.0f;
         
         
     } completion:^(BOOL finished)
     {
         
         [self.viewController.view bringSubviewToFront:_TopHeader];
         
         [self.viewController.view bringSubviewToFront:_doneButton];
         
         [self.viewController.view bringSubviewToFront:_SaveButton];
         
         [self.viewController.view bringSubviewToFront:_viewLikeComment];
         
         _isDoneAnimating = NO;
     }];

}

#pragma mark - Showing of Done Button if ever Zoom Scale is equal to 1
-(void)didSingleTap:(UITapGestureRecognizer*)recognizer
{
    if(_doneButton.superview)
    {
        [self hideDoneButton];
        [self hidesaveButton];
        [self hideimgLikeComment];
        [self hideTopHeader];
        
    }else
    {
        if(__scrollView.zoomScale == __scrollView.minimumZoomScale)
        {
            if(!_isDoneAnimating)
            {
                _isDoneAnimating = YES;
                
                
                //****** Step 6
                
                [self.viewController.view addSubview:_doneButton];
                [self.viewController.view addSubview:_SaveButton];
                [self.viewController.view addSubview:_viewLikeComment];
                [self.viewController.view addSubview:_TopHeader];
                
                _doneButton.alpha = 0.0f;
                _SaveButton.alpha = 0.0f;
                _viewLikeComment.alpha = 0.0f;
                _TopHeader.alpha = 0.0f;
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^
                {
                    _doneButton.alpha = 1.0f;
                    _SaveButton.alpha = 1.0f;
                    _viewLikeComment.alpha = 1.0f;
                    _TopHeader.alpha = 1.0f;
                    
                    
                } completion:^(BOOL finished)
                 {
                   
                    [self.viewController.view bringSubviewToFront:_TopHeader];
                     
                    [self.viewController.view bringSubviewToFront:_doneButton];
                     
                    [self.viewController.view bringSubviewToFront:_SaveButton];
                     
                    [self.viewController.view bringSubviewToFront:_viewLikeComment];
                
                    _isDoneAnimating = NO;
                }];
            }
        }else if(__scrollView.zoomScale == __scrollView.maximumZoomScale)
        {
            CGPoint pointInView = [recognizer locationInView:__imageView];
            [self zoomInZoomOut:pointInView];
        }
    }
}

#pragma mark - Zoom in or Zoom out
- (void)didDobleTap:(UITapGestureRecognizer*)recognizer
{
    CGPoint pointInView = [recognizer locationInView:__imageView];
    [self zoomInZoomOut:pointInView];
}

- (void) zoomInZoomOut:(CGPoint)point
{
    // Check if current Zoom Scale is greater than half of max scale then reduce zoom and vice versa
    CGFloat newZoomScale = __scrollView.zoomScale > (__scrollView.maximumZoomScale/2)?__scrollView.minimumZoomScale:__scrollView.maximumZoomScale;

    CGSize scrollViewSize = __scrollView.bounds.size;
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    [__scrollView zoomToRect:rectToZoomTo animated:YES];
}

#pragma mark - Hide the Done Button
- (void) hideDoneButton {
    if(!_isDoneAnimating){
        if(_doneButton.superview) {
            _isDoneAnimating = YES;
            _doneButton.alpha = 1.0f;
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                _doneButton.alpha = 0.0f;
            } completion:^(BOOL finished) {
                _isDoneAnimating = NO;
                [_doneButton removeFromSuperview];
            }];
        }
    }
}


-(void)hideimgLikeComment
{
   
    if(_viewLikeComment.superview)
    {
        _viewLikeComment.alpha = 1.0f;
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^
        {
            _viewLikeComment.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
          
            [_viewLikeComment removeFromSuperview];
        }];
    }
    
}

-(void)hideTopHeader
{
    
    if(_TopHeader.superview)
    {
        _TopHeader.alpha = 1.0f;
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^
         {
             _TopHeader.alpha = 0.0f;
         } completion:^(BOOL finished)
         {
             
             [_TopHeader removeFromSuperview];
         }];
    }
    
}


- (void)hidesaveButton
{
    if(_SaveButton.superview)
    {
        _SaveButton.alpha = 1.0f;
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^
        {
            _SaveButton.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
           
            [_SaveButton removeFromSuperview];
            
        }];
    }
}

- (void)close:(UIButton *)sender
{
    self.userInteractionEnabled = NO;
    if (sender != nil)
    {
        [sender removeFromSuperview];
        
    }
    [self dismissViewController];
}


- (void)save:(UIButton *)sender
{
    //NSLog(@"%d",sender.tag);
    
    
    

//     [[NSNotificationCenter defaultCenter] postNotificationName:@"saveClicked" object:sender];
    
     //[sender removeTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    
   // self.userInteractionEnabled = NO;
   // [sender removeFromSuperview];
    //[self dismissViewController];
}

//-(void)saveclicked:(id)sender
//{
//    
//    
//    
//    
//}


- (void) dealloc {

}

@end

@interface MHFacebookImageViewer()<UIGestureRecognizerDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *_gestures;

    UITableView * _tableView;
    UIView *_blackMask;
    UIImageView * _imageView;
    UIButton * _doneButton;
    
    UIView *_TopHeader;
    
    UIButton * _saveButton;
    imageLikeComment * _viewLikeComment;
    UIView * _superView;

    CGPoint _panOrigin;
    CGRect _originalFrameRelativeToScreen;

    BOOL _isAnimating;
    BOOL _isDoneAnimating;

    UIStatusBarStyle _statusBarStyle;
    
    int imageIndex;
    
    int start;
    
    
}

@end

@implementation MHFacebookImageViewer
@synthesize rootViewController = _rootViewController;
@synthesize imageURL = _imageURL;
@synthesize openingBlock = _openingBlock;
@synthesize closingBlock = _closingBlock;
@synthesize senderView = _senderView;
@synthesize initialIndex = _initialIndex;

#pragma mark - TableView datasource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Just to retain the old version
    if(!self.imageDatasource) return 1;
    return [self.imageDatasource numberImagesForImageViewer:self];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"mhfacebookImageViewerCell";
    MHFacebookImageViewerCell * imageViewerCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!imageViewerCell)
    {
        CGRect windowFrame = [[UIScreen mainScreen] bounds];
        imageViewerCell = [[MHFacebookImageViewerCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        imageViewerCell.transform = CGAffineTransformMakeRotation(M_PI_2);
        imageViewerCell.frame = CGRectMake(0,0,windowFrame.size.width, windowFrame.size.height);
        imageViewerCell.originalFrameRelativeToScreen = _originalFrameRelativeToScreen;
        imageViewerCell.viewController = self;
        imageViewerCell.blackMask = _blackMask;
        imageViewerCell.rootViewController = _rootViewController;
        imageViewerCell.closingBlock = _closingBlock;
        imageViewerCell.openingBlock = _openingBlock;
        imageViewerCell.superView = _senderView.superview;
        imageViewerCell.senderView = _senderView;
        imageViewerCell.doneButton = _doneButton;
     
        
        //***** Step 4
  
        imageViewerCell.viewLikeComment.tag = indexPath.row;
        
        imageViewerCell.viewLikeComment.btnLike.tag = indexPath.row;
        imageViewerCell.viewLikeComment.btnComments.tag = indexPath.row;
        
        
        imageViewerCell.viewLikeComment = _viewLikeComment;
        imageViewerCell.TopHeader = _TopHeader;
    
       // _saveButton.tag=indexPath.row;
        imageViewerCell.SaveButton = _saveButton;
        _saveButton.tag = indexPath.row;
        imageViewerCell.SaveButton.tag = indexPath.row;
        //imageViewerCell.SaveButton.tag = indexPath.row;
        
        //******** for Save image ****
        
//        [imageViewerCell.SaveButton addTarget:self
//                        action:@selector(saveMY:)
//              forControlEvents:UIControlEventTouchUpInside];
        
        imageViewerCell.initialIndex = _initialIndex;
        imageViewerCell.statusBarStyle = _statusBarStyle;
        [imageViewerCell loadAllRequiredViews];
        imageViewerCell.backgroundColor = [UIColor clearColor];
    }
    if(!self.imageDatasource) {
        // Just to retain the old version
        
        //imageViewerCell.SaveButton.tag = indexPath.row;
        
        [imageViewerCell setImageURL:_imageURL defaultImage:_senderView.image imageIndex:0];
        
    } else {
        
         // imageViewerCell.SaveButton.tag = indexPath.row;
        
        [imageViewerCell setImageURL:[self.imageDatasource imageURLAtIndex:indexPath.row imageViewer:self] defaultImage:[self.imageDatasource imageDefaultAtIndex:indexPath.row imageViewer:self]imageIndex:indexPath.row];

        
    }

    
    if (start == 0)
    {
        NSLog(@"%ld",(long)indexPath.row);
        start ++;
        imageIndex = (int)indexPath.row;
        [self updateLikeComment:_viewLikeComment];
    }
  
    return imageViewerCell;
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==_tableView)
    {
        int page;
        
        if (IS_IPAD)
        {
            CGFloat pageWidth = scrollView.frame.size.width;
            page = floor((scrollView.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
            NSLog(@"%d",page);
            
            imageIndex = page;
            
            _viewLikeComment.tag = page;
            [self updateLikeComment:_viewLikeComment];
            //self.pageControl.currentPage = page;
        }
        else
        {
            // self.scrolview.contentSize = CGSizeMake(960, 150);
            
            CGFloat pageWidth = scrollView.frame.size.width;
            page = floor((scrollView.contentOffset.y - pageWidth / 2) / pageWidth) + 1;
            NSLog(@"%d",page);
            
            imageIndex = page;
             _viewLikeComment.tag = page;
            
            [self updateLikeComment:_viewLikeComment];
            //self.pageControl.currentPage = page;
        }
    }
    
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _rootViewController.view.bounds.size.width;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGallery:) name:@"updateGallery" object:nil];
    
    start = 0;
    
    _statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [UIApplication sharedApplication].statusBarHidden = YES;
    CGRect windowBounds = [[UIScreen mainScreen] bounds];

    // Compute Original Frame Relative To Screen
    CGRect newFrame = [_senderView convertRect:windowBounds toView:nil];
    newFrame.origin = CGPointMake(newFrame.origin.x, newFrame.origin.y);
    newFrame.size = _senderView.frame.size;
    _originalFrameRelativeToScreen = newFrame;

    self.view = [[UIView alloc] initWithFrame:windowBounds];
    //    NSLog(@"WINDOW :%@",NSStringFromCGRect(windowBounds));
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // Add a Tableview
    _tableView = [[UITableView alloc]initWithFrame:windowBounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    //rotate it -90 degrees
    _tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _tableView.frame = CGRectMake(0,0,windowBounds.size.width,windowBounds.size.height);
    _tableView.pagingEnabled = YES;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delaysContentTouches = YES;
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setContentOffset:CGPointMake(0, _initialIndex * windowBounds.size.width)];

    _blackMask = [[UIView alloc] initWithFrame:windowBounds];
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0.0f;
    _blackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view insertSubview:_blackMask atIndex:0];

    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setImageEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];  // make click area bigger
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_saveButton setImageEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];  // make click area bigger
    
   
    
    //********* Step 5
    
    _viewLikeComment= [[[NSBundle mainBundle]
                                 
                                 loadNibNamed:@"imageLikeComment"
                                 
                                 owner:self options:nil]
                                
                                firstObject];
    
    [_viewLikeComment.superview setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75]];
    
    [_viewLikeComment setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75]];

    _viewLikeComment.frame = CGRectMake(0,windowBounds.size.height-_viewLikeComment.frame.size.height,windowBounds.size.width,_viewLikeComment.frame.size.height);
 
    [_viewLikeComment.btnLike addTarget:self action:@selector(likeTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [_viewLikeComment.btnComments addTarget:self action:@selector(CommentTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _TopHeader = [[UIView alloc]initWithFrame:CGRectMake(0,0,windowBounds.size.width,64)];
    _TopHeader.backgroundColor = [UIColor colorWithRed:44/255.0f green:44/255.0f blue:44/255.0f alpha:1];//AmHappyColor;
    
 
    _doneButton.frame = CGRectMake(0,26, 50.0f, 25.0f);
    [_doneButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    
     _saveButton.frame = CGRectMake(windowBounds.size.width - 50,28, 50.0f, 25.0f);
    [_saveButton setImage:[UIImage imageNamed:@"tag"] forState:UIControlStateNormal];
    [_saveButton setContentMode:UIViewContentModeScaleAspectFit];
    _saveButton.clipsToBounds = YES;
    

}


-(void)updateGallery:(NSNotification *)notification
{
    if ([notification.name isEqualToString:@"updateGallery"])
    {
        NSDictionary* userInfo = notification.object;
        NSNumber* total = (NSNumber*)userInfo[@"imageIndex"];
        NSLog (@"Successfully received test notification! %i", total.intValue);
        imageIndex =  total.intValue;
        [self updateLikeComment:_viewLikeComment];
    }
  
}


-(void)updateLikeComment:(imageLikeComment *)view
{
    //[[_tableView delegate] scrollViewDidEndDecelerating:_tableView];
    
    NSLog(@"%d",imageIndex);
    view.tag = imageIndex;
    [self.imageDatasource updateLikeComment:view];
}

-(void)likeTapped:(UIButton *)sender
{
    [[_tableView delegate] scrollViewDidEndDecelerating:_tableView];
    
    sender.tag = imageIndex;
    [self.imageDatasource likeTapped:sender];
}
-(void)CommentTapped:(UIButton *)sender
{
    [[_tableView delegate] scrollViewDidEndDecelerating:_tableView];
    
    sender.tag = imageIndex;
    [self.imageDatasource CommentTapped:sender];
  
    for (UIView *view in _tableView.subviews)
    {
        for (MHFacebookImageViewerCell *cell in view.subviews)
        {
            //do
            
            NSLog(@"%@",cell);
            
             [cell close:_doneButton];
            
            break;
            
            
        }
    }
 
}
#pragma mark - Show
- (void)presentFromRootViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self presentFromViewController:rootViewController];
}

- (void)presentFromViewController:(UIViewController *)controller
{
    _rootViewController = controller;
    [[[[UIApplication sharedApplication]windows]objectAtIndex:0]addSubview:self.view];
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
}



- (void) dealloc {
    _rootViewController = nil;
    _imageURL = nil;
    _senderView = nil;
    _imageDatasource = nil;

}


- (void)saveMY:(UIButton *)sender
{

    NSArray *paths = [_tableView indexPathsForVisibleRows];
    
    //  For getting the cells themselves
   // NSMutableSet *visibleCells = [[NSMutableSet alloc] init];
    
    for (NSIndexPath *path in paths) {
        
        NSLog(@"%ld",(long)path.row);
        
            MHFacebookImageViewerCell *imageViewerCell = (MHFacebookImageViewerCell *)[_tableView cellForRowAtIndexPath:path];
        
            UIScrollView *scroll = (UIScrollView *)[imageViewerCell viewWithTag:500];
        
             UIImageView *img = (UIImageView *)[scroll viewWithTag:100];
        
            //NSLog(@"%@",img.image);
        
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
            [library writeImageToSavedPhotosAlbum:[img.image CGImage] orientation:(ALAssetOrientation)[img.image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 if (error) {
                     // TODO: error handling
        
                     NSLog(@"failed");
        
                    [JDStatusBarNotification showWithStatus:@"Error in Saving!" dismissAfter:2.0 styleName:JDStatusBarStyleError];
        
        
                 } else {
                     // TODO: success handling
        
        
                      NSLog(@"success");
        
                     [JDStatusBarNotification showWithStatus:@"Image Successfully Saved" dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
                     
                     
                 }
             }];
        
       
    }

    
    
    
    
    
//    feedDetail *obj = [[feedDetail alloc]init];
//   
//    NSLog(@"%ld",(long)obj.ImageIndex);
//   
//    NSIndexPath *path = [NSIndexPath indexPathForRow:sender.tag inSection:0];
//    //static NSString * cellID = @"mhfacebookImageViewerCell";
//    MHFacebookImageViewerCell *imageViewerCell = (MHFacebookImageViewerCell *)[_tableView cellForRowAtIndexPath:path];
//    
//    UIScrollView *scroll = (UIScrollView *)[imageViewerCell viewWithTag:500];
//    
//     UIImageView *img = (UIImageView *)[scroll viewWithTag:100];
//  
//    NSLog(@"%@",img.image);
//    
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    
//    [library writeImageToSavedPhotosAlbum:[img.image CGImage] orientation:(ALAssetOrientation)[img.image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error)
//     {
//         if (error) {
//             // TODO: error handling
//             
//             NSLog(@"failed");
//             
//            [JDStatusBarNotification showWithStatus:@"Error in Saving!" dismissAfter:2.0 styleName:JDStatusBarStyleError];
//
//             
//         } else {
//             // TODO: success handling
//             
//             
//              NSLog(@"success");
//             
//             [JDStatusBarNotification showWithStatus:@"Image Successfully Saved" dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
//             
//             
//         }
//     }];
    
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"saveClicked" object:sender];
    
    //[sender removeTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    
    // self.userInteractionEnabled = NO;
    // [sender removeFromSuperview];
    //[self dismissViewController];
}
@end


#pragma mark - Custom Gesture Recognizer that will Handle imageURL
@interface MHFacebookImageViewerTapGestureRecognizer()

@end

@implementation MHFacebookImageViewerTapGestureRecognizer
@synthesize imageURL;
@synthesize openingBlock;
@synthesize closingBlock;
@synthesize imageDatasource;
@end


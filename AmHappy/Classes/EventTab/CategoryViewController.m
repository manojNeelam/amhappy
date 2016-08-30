//
//  CategoryViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 07/02/15.
//
//

#import "CategoryViewController.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController
{
    int catID;
    BOOL isall;
}
@synthesize lblTitle,img1,img10,img11,img12,img13,img14,img15,img16,img17,img18,img19,img2,img20,img21,img3,img4,img5,img6,img7,img8,img9,scrollview,isMultiSelect,btnDone;

@synthesize btnBar,btnBirthday,btnCards,btnCinema,btnConcert,btndance,btnDating,btnFamily,btnGin,btnHunt,btnIdiom,btnMuseum,btnOther,btnParty,btnPhoto,btnRestaurant,btnSelectAll,btnSingle,btnSport,btnTheatre,btnTrip,btnWine;

- (void)viewDidLoad {
    [super viewDidLoad];
    catID =0;
    
    [self setButtonTitles];
    
    if([USER_DEFAULTS valueForKey:@"catid"])
    {
        catID =[[USER_DEFAULTS valueForKey:@"catid"] intValue];
    }

    
    [self.scrollview setContentSize:CGSizeMake(320, 750)];
    if(isMultiSelect)
    {
        if(DELEGATE.selectedCategoryArray.count==0)
        {
           // [DELEGATE.selectedCategoryArray addObjectsFromArray:DELEGATE.categoryArray];
        }
        
        if(DELEGATE.selectedCategoryArray.count==21)
        {
            isall =YES;
            [self.btnSelectAll setImage:[UIImage imageNamed:@"tick2.png"] forState:UIControlStateNormal];
            // [DELEGATE.selectedCategoryArray addObjectsFromArray:DELEGATE.categoryArray];
        }
        [self selectImages];
    }
    else
    {
        [self.btnSelectAll setHidden:YES];

        if([USER_DEFAULTS valueForKey:@"catid"])
        {
            for(UIImageView *img in self.scrollview.subviews)
            {
                if([img isKindOfClass:[UIImageView class]])
                {
                    if(img.tag==[[USER_DEFAULTS valueForKey:@"catid"] integerValue])
                    {
                        [img setHidden:NO];
                    }
                    
                }
                else if([img isKindOfClass:[UIView class]])
                {
                    for(UIImageView *imgview in img.subviews)
                    {
                        if([imgview isKindOfClass:[UIImageView class]])
                        {
                            if(imgview.tag==[[USER_DEFAULTS valueForKey:@"catid"] integerValue])
                            {
                                [imgview setHidden:NO];
                            }
                            
                        }
                    }
                    
                    //NSLog(@"class is %@",[img class]);
                }
            }
        }
    }
}

-(void)setButtonTitles
{
    [self.btnWine setTitle:[localization localizedStringForKey:@"Wine"] forState:UIControlStateNormal];
    [self.btnTrip setTitle:[localization localizedStringForKey:@"Trip"] forState:UIControlStateNormal];
    [self.btnTheatre setTitle:[localization localizedStringForKey:@"Thearter"] forState:UIControlStateNormal];
    [self.btnSport setTitle:[localization localizedStringForKey:@"Sport"] forState:UIControlStateNormal];
    [self.btnSingle setTitle:[localization localizedStringForKey:@"Single"] forState:UIControlStateNormal];
    [self.btnPhoto setTitle:[localization localizedStringForKey:@"Photography"] forState:UIControlStateNormal];
    [self.btnRestaurant setTitle:[localization localizedStringForKey:@"Restaurant"] forState:UIControlStateNormal];
    [self.btnParty setTitle:[localization localizedStringForKey:@"Party"] forState:UIControlStateNormal];
    [self.btnOther setTitle:[localization localizedStringForKey:@"Other"] forState:UIControlStateNormal];
    [self.btnMuseum setTitle:[localization localizedStringForKey:@"Museum"] forState:UIControlStateNormal];
    [self.btnIdiom setTitle:[localization localizedStringForKey:@"idioms"] forState:UIControlStateNormal];
    [self.btnHunt setTitle:[localization localizedStringForKey:@"Hunt"] forState:UIControlStateNormal];
    [self.btnGin setTitle:[localization localizedStringForKey:@"Gin Tonic"] forState:UIControlStateNormal];
    [self.btnFamily setTitle:[localization localizedStringForKey:@"Family"] forState:UIControlStateNormal];
    [self.btnDating setTitle:[localization localizedStringForKey:@"Dating"] forState:UIControlStateNormal];
    [self.btndance setTitle:[localization localizedStringForKey:@"Dancing"] forState:UIControlStateNormal];
    [self.btnConcert setTitle:[localization localizedStringForKey:@"Concert"] forState:UIControlStateNormal];
    [self.btnCinema setTitle:[localization localizedStringForKey:@"Cinema"] forState:UIControlStateNormal];
    [self.btnCards setTitle:[localization localizedStringForKey:@"Cards"] forState:UIControlStateNormal];
    [self.btnBirthday setTitle:[localization localizedStringForKey:@"Birthday"] forState:UIControlStateNormal];
    [self.btnBar setTitle:[localization localizedStringForKey:@"Bar"] forState:UIControlStateNormal];


}
-(void)selectImages
{
    if(DELEGATE.selectedCategoryArray.count>0)
    {
        for(int i=0; i<DELEGATE.selectedCategoryArray.count;i++)
        {
            for(UIImageView *img in self.scrollview.subviews)
            {
                if([img isKindOfClass:[UIImageView class]])
                {
                    if(img.tag==[[DELEGATE.selectedCategoryArray objectAtIndex:i] integerValue])
                    {
                        [img setHidden:NO];
                    }
                    
                }
                else if([img isKindOfClass:[UIView class]])
                {
                    for(UIImageView *imgview in img.subviews)
                    {
                        if([imgview isKindOfClass:[UIImageView class]])
                        {
                            if(imgview.tag==[[DELEGATE.selectedCategoryArray objectAtIndex:i] integerValue])
                            {
                                [imgview setHidden:NO];
                            }
                            
                        }
                    }
                
                    //NSLog(@"class is %@",[img class]);
                }
            }
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
}
-(void)localize
{
    
    [self.lblTitle setText:[localization localizedStringForKey:@"Categories"]];
    //[self.btnDone.titleLabel setText:[localization localizedStringForKey:@"Done"]];
    
    [self.btnDone setTitle:[localization localizedStringForKey:@"Done"] forState:UIControlStateNormal];
    
   // NSLog(@"done is %@",[localization localizedStringForKey:@"Done"]);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)hideEveryImage
{
    for(UIImageView *img in self.scrollview.subviews)
    {
        if([img isKindOfClass:[UIImageView class]])
        {
                [img setHidden:YES];
            
            
        }
    }
    for(UIView *view1 in self.scrollview.subviews)
    {
        if([view1 isKindOfClass:[UIView class]])
        {
            if(view1.tag==500)
            {
                for(UIImageView *imgview in view1.subviews)
                {
                    if([imgview isKindOfClass:[UIImageView class]])
                    {
                      
                            
                            [imgview setHidden:YES];
                        
                    }
                }
            }
            
            
            //NSLog(@"class is %@",[img class]);
        }
    }
}
-(void)hideAllImages:(int)imgTag
{
    if(!self.isMultiSelect)
    {
        for(UIImageView *img in self.scrollview.subviews)
        {
            if([img isKindOfClass:[UIImageView class]])
            {
                if(img.tag!=imgTag)
                {
                    [img setHidden:YES];
                  //  NSLog(@"image view1 tag is %d",[img tag]);

                }
                
            }
//            else
//            {
//                if([img isKindOfClass:[UIButton class]])
//                                {
//                                    for(UIImageView *imgview in img.subviews)
//                                    {
//                                        if([imgview isKindOfClass:[UIImageView class]])
//                                        {
//                                            if(imgview.tag!=imgTag)
//                                            {
//                                                [imgview setHidden:YES];
//                                                NSLog(@"image view2 tag is %d",[imgview tag]);
//
//                                            }
//                                            
//                                        }
//                                    }
//                                    
//                                    //NSLog(@"class is %@",[img class]);
//                                }
//            }
            
        }
        for(UIView *view1 in self.scrollview.subviews)
        {
            if([view1 isKindOfClass:[UIView class]])
            {
                if(view1.tag==500)
                {
                    for(UIImageView *imgview in view1.subviews)
                    {
                        if([imgview isKindOfClass:[UIImageView class]])
                        {
                            if(imgview.tag!=imgTag)
                            {
                                NSLog(@"image view2 tag is %ld",(long)[imgview tag]);
                                
                                [imgview setHidden:YES];
                            }
                            
                        }
                    }
                }
                
                
                //NSLog(@"class is %@",[img class]);
            }
        }
    }
    
}



-(void)addMark
{
    if(isall)
    {
        isall =NO;
        [self.btnSelectAll setImage:[UIImage imageNamed:@"tick1.png"] forState:UIControlStateNormal];
        
    }
}

- (IBAction)cat1Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];

    if(self.img1.hidden)
    {
        [self.img1 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];

        }

    }
    else
    {
        [self.img1 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];

        }

    }
   

}

- (IBAction)cat2Tapped:(UIButton *)sender
{

        [self hideAllImages:(int)[sender tag]];
        
    if(self.img2.hidden)
    {
        [self.img2 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img2 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    
    
}

- (IBAction)cat3Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    
    if(self.img3.hidden)
    {
        [self.img3 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img3 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    
   
    
    
}

- (IBAction)cat4Tapped:(UIButton *)sender
{
     [self hideAllImages:(int)[sender tag]];
    
    if(self.img4.hidden)
    {
        [self.img4 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img4 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    
}


- (IBAction)cat5Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img5.hidden)
    {
        [self.img5 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img5 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    
  
}

- (IBAction)cat6Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img6.hidden)
    {
        [self.img6 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img6 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    
}
- (IBAction)cat7Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img7.hidden)
    {
        [self.img7 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img7 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
   
}
- (IBAction)cat8Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img8.hidden)
    {
        [self.img8 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    else
    {
        [self.img8 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    
}
- (IBAction)cat9Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img9.hidden)
    {
        [self.img9 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img9 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    
}
- (IBAction)cat10Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img10.hidden)
    {
        [self.img10 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img10 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    
}
- (IBAction)cat11Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img11.hidden)
    {
        [self.img11 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img11 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    
    
}
- (IBAction)cat12Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img12.hidden)
    {
        [self.img12 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img12 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    
}

- (IBAction)cat13Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img13.hidden)
    {
        [self.img13 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img13 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    
}
- (IBAction)cat14tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img14.hidden)
    {
        [self.img14 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img14 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    
    
}
- (IBAction)cat15Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img15.hidden)
    {
        [self.img15 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img15 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    
}
- (IBAction)cat16Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img16.hidden)
    {
        [self.img16 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img16 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    
    
}
- (IBAction)cat17Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img17.hidden)
    {
        [self.img17 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img17 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    
}
- (IBAction)cat18Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img18.hidden)
    {
        [self.img18 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img18 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    
}

- (IBAction)cat19Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img19.hidden)
    {
        [self.img19 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img19 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    
    
}
- (IBAction)cat20Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img20.hidden)
    {
        [self.img20 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img20 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
    
}
- (IBAction)cat21Tapped:(UIButton *)sender
{
    [self hideAllImages:(int)[sender tag]];
    if(self.img21.hidden)
    {
        [self.img21 setHidden:NO];
        catID=(int)[sender tag];
        if(isMultiSelect)
        {
            [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
        
    }
    else
    {
        [self.img21 setHidden:YES];
        catID=0;
        if(isMultiSelect)
        {
            [self addMark];
            [DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%ld",(long)[sender tag]]];
            
        }
    }
   // [DELEGATE.selectedCategoryArray addObject:[NSString stringWithFormat:@"%d",[sender tag]]];
    //[DELEGATE.selectedCategoryArray removeObject:[NSString stringWithFormat:@"%d",[sender tag]]];
}
- (IBAction)backTapped:(id)sender
{
    if(catID>0)
    {
        [USER_DEFAULTS setValue:[NSString stringWithFormat:@"%d",catID] forKey:@"catid"];
        [USER_DEFAULTS synchronize];
    }
    else
    {
          [USER_DEFAULTS removeObjectForKey:@"catid"];
          [USER_DEFAULTS synchronize];
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)selectAllCat:(id)sender
{
    if(isall)
    {
        isall =NO;
        [DELEGATE.selectedCategoryArray removeAllObjects];
        [self hideEveryImage];
        [self.btnSelectAll setImage:[UIImage imageNamed:@"tick1.png"] forState:UIControlStateNormal];


    }
    else
    {
        isall =YES;
        [DELEGATE.selectedCategoryArray removeAllObjects];
         [DELEGATE.selectedCategoryArray addObjectsFromArray:DELEGATE.categoryArray];
        [self selectImages];
        [self.btnSelectAll setImage:[UIImage imageNamed:@"tick2.png"] forState:UIControlStateNormal];

    }
    

}
@end

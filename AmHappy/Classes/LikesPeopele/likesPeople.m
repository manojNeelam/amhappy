//
//  likesPeople.m
//  AmHappy
//
//  Created by Peerbits MacMini9 on 30/11/15.
//
//

#import "likesPeople.h"
#import "FriendCell.h"
#import "UIImageView+WebCache.h"
#import "ModelClass.h"
#import "OtherUserProfileViewController.h"




@interface likesPeople ()<UIGestureRecognizerDelegate>
{
    NSMutableArray *likedPeople;
 
    ModelClass *mc;
    
    BOOL isLast;
}

@end

@implementation likesPeople
@synthesize likedDetail,gettedId,gettedType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.lblwhoLikedThis setText:[localization localizedStringForKey:@"People who like this"]];
    
    
    likedPeople = [[NSMutableArray alloc]init];
    
    mc = [[ModelClass alloc]init];
    mc.delegate =self;
    
    NSLog(@"%@",likedDetail);
    
    if ([DELEGATE connectedToNetwork])
    {
        
        
        if (likedDetail)
        {
            
            if ([[likedDetail valueForKey:@"type"]isEqualToString:@"CL"]||[[likedDetail valueForKey:@"type"]isEqualToString:@"C"])
            {
                
                [mc likedUserList:[USER_DEFAULTS valueForKey:@"userid"] type:@"C" Id:[[likedDetail valueForKey:@"Comment"] valueForKey:@"id"] start:[NSString stringWithFormat:@"%lu",(unsigned long)likedPeople.count] limit:@"10" Sel:@selector(responseUserList:)];
                
                
            }
            
            else if ([[likedDetail valueForKey:@"type"]isEqualToString:@"NE"]||[[likedDetail valueForKey:@"type"]isEqualToString:@"EL"])
            {
                
                [mc likedUserList:[USER_DEFAULTS valueForKey:@"userid"] type:@"E" Id:[[likedDetail valueForKey:@"Event"] valueForKey:@"id"] start:[NSString stringWithFormat:@"%lu",(unsigned long)likedPeople.count] limit:@"10" Sel:@selector(responseUserList:)];
                
            }

            
        }
        else
        {
            
            
            if ([gettedType isEqualToString:@"CL"]|| [gettedType isEqualToString: @"C"])
            {
                
                [mc likedUserList:[USER_DEFAULTS valueForKey:@"userid"] type:@"C" Id:gettedId start:[NSString stringWithFormat:@"%lu",(unsigned long)likedPeople.count] limit:@"10" Sel:@selector(responseUserList:)];
                
                
            }
            
            else if ([gettedType isEqualToString:@"NE"] || [gettedType isEqualToString:@"EL"])
            {
                
                [mc likedUserList:[USER_DEFAULTS valueForKey:@"userid"] type:@"E" Id:gettedId start:[NSString stringWithFormat:@"%lu",(unsigned long)likedPeople.count] limit:@"10" Sel:@selector(responseUserList:)];
                
            }
        
            
        }
        
        
        
    }
    
     [self.tblView registerClass:[FriendCell class] forCellReuseIdentifier:@"FriendCellNew"];
    
  
    
    // Do any additional setup after loading the view from its nib.
}



-(void)callAPI
{
    
    if ([DELEGATE connectedToNetwork])
    {
        
        if ([[likedDetail valueForKey:@"type"]isEqualToString:@"CL"]||[[likedDetail valueForKey:@"type"]isEqualToString:@"C"])
        {
            
            [mc likedUserList:[USER_DEFAULTS valueForKey:@"userid"] type:@"C" Id:[[likedDetail valueForKey:@"Comment"] valueForKey:@"id"] start:[NSString stringWithFormat:@"%lu",(unsigned long)likedPeople.count] limit:@"10" Sel:@selector(responseUserList:)];
            
            
        }
        
        else if ([[likedDetail valueForKey:@"type"]isEqualToString:@"NE"]||[[likedDetail valueForKey:@"type"]isEqualToString:@"EL"])
        {
            
            [mc likedUserList:[USER_DEFAULTS valueForKey:@"userid"] type:@"E" Id:[[likedDetail valueForKey:@"Event"] valueForKey:@"id"] start:[NSString stringWithFormat:@"%lu",(unsigned long)likedPeople.count] limit:@"10" Sel:@selector(responseUserList:)];
            
        }

        
        
    }
    
   
}


-(void)responseUserList:(NSDictionary *)dict
{

    NSLog(@"%@",dict);
    
    if ([[NSString stringWithFormat:@"%@",[dict valueForKey:@"code"]] isEqualToString:@"200"])
    {
       
        
        if ([[dict valueForKey:@"is_last"]isEqualToString:@"Y"])
        {
            
            isLast = YES;
            
        }
        else
        {
            
            isLast = NO;
            
        }
     
        [likedPeople addObjectsFromArray:[dict valueForKey:@"User"]];
        
        if ([likedPeople count]>0)
        {
            
            [self.tblView reloadData];
            
        }
      
    }
    else
    {
        [DELEGATE showalert:self Message:[dict valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }

}


#pragma mark ---------- TableView Datasource & Delegate ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
  
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([likedPeople count]>0)
    {
        return [likedPeople count];
        
    }
    else{
        
        return 0;
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
    }
    
    [cell.lblName setFont:FONT_Regular(14)];
    
    cell.imgUser.layer.masksToBounds = YES;
    cell.imgUser.layer.cornerRadius = 25.0;
    
    [cell.btnInvite setHidden:YES];
    [cell.btnAccept setHidden:YES];
    [cell.btnAdd setHidden:YES];
    
    
    cell.imgUser.userInteractionEnabled = YES;
    cell.imgUser.tag = indexPath.row;
    
    
    
    //************* Add Tap Gesture on like Label ******
    
    UITapGestureRecognizer *imageRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagecliked:)];
    imageRecognizer.delegate = self;
    [cell.imgUser setUserInteractionEnabled:YES];
    cell.imgUser.tag =indexPath.row;
    [cell.imgUser addGestureRecognizer:imageRecognizer];
    
    
    
    cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.width/2;
    cell.imgUser.clipsToBounds = YES;
    
    
    cell.lblName.text = [[likedPeople objectAtIndex:indexPath.row]valueForKey:@"name"];
    
    if (![[[likedPeople objectAtIndex:indexPath.row]valueForKey:@"thumb_image"]isEqualToString:@""])
    {
        
        
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[[likedPeople objectAtIndex:indexPath.row]valueForKey:@"thumb_image"]] placeholderImage:[UIImage imageNamed:@"iconBlack"]];
        
    }
 
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
  
}

#pragma mark ----------- likes Tapped ------------

-(void)imagecliked:(UIGestureRecognizer *)gestureRecognizer
{
    
    
    if (![[[likedPeople objectAtIndex:gestureRecognizer.view.tag]valueForKey:@"thumb_image"]isEqualToString:@""])
    {

           [DELEGATE showCustomImageAlert:[NSString stringWithFormat:@"%@",[[likedPeople objectAtIndex:gestureRecognizer.view.tag]valueForKey:@"thumb_image"]] Type:2];
        
    }
  
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    OtherUserProfileViewController *otherVC =[[OtherUserProfileViewController alloc] initWithNibName:@"OtherUserProfileViewController" bundle:nil];
   
    otherVC.userId=[NSString stringWithFormat:@"%@",[[likedPeople objectAtIndex:indexPath.row]valueForKey:@"id"]];
    
    
    [self.navigationController pushViewController:otherVC animated:YES];

    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ------------ Load More --------------------

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;

    if (maximumOffset - currentOffset <= 10.0  )
    {
        if(!isLast)
        {
  
            [self callAPI];
            
        }
    }
 
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark --------------- Click Events --------------

- (IBAction)clickBack:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end

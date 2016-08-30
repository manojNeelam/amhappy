//
//  HobbiyViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 16/02/15.
//
//

#import "HobbiyViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
#import "TYMActivityIndicatorViewViewController.h"

@interface HobbiyViewController ()

@end

@implementation HobbiyViewController
{
    ModelClass *mc;
    NSMutableArray *hobbyArray;
    NSMutableArray *selectedHobbyArray;
    NSMutableArray *preIdArray;
    TYMActivityIndicatorViewViewController *drk;



}
@synthesize lblTitle,tableView,isEdit,isFirst,isOther,btnBack,btnSave;
-(id)initWithNibName:(NSString *)nibNameOrNil IdArray:(NSArray *)idArray bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        preIdArray =[[NSMutableArray alloc] initWithArray:idArray];
        
    }
    
    return self;
}
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        preIdArray =[[NSMutableArray alloc] init];

    }
    
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
}
-(void)localize
{
    [self.lblTitle setText:[localization localizedStringForKey:@"Hobbies"]];
    [self.btnSave setTitle:[localization localizedStringForKey:@"Done"] forState:UIControlStateNormal];
   // [self.btnSave.titleLabel setText:[localization localizedStringForKey:@"Done"]];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    if(self.isOther)
    {
        [self.btnSave setHidden:YES];
        [self.btnBack setHidden:NO];
      //  [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-49)];
        
    }
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    
    hobbyArray =[[ NSMutableArray alloc] init];
    selectedHobbyArray =[[ NSMutableArray alloc] init];
    if(!isFirst)
    {
        [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-49)];
    }
    [self callApi];
}
-(NSArray *)getIDArrays:(NSArray *)array
{
    NSMutableArray *temp=[[NSMutableArray alloc] initWithArray:array];
    for(int i=0; i<temp.count;i++)
    {
        BOOL isfound;
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[temp objectAtIndex:i]];

        for(int j=0; j<preIdArray.count;j++)
        {
            if([[NSString stringWithFormat:@"%@",[[temp objectAtIndex:i] valueForKey:@"id"]] isEqualToString:[NSString stringWithFormat:@"%@",[preIdArray objectAtIndex:j] ] ])
            {
                isfound=YES;
                [dict setValue:@"Y" forKey:@"select"];
                [selectedHobbyArray addObject:[NSString stringWithFormat:@"%@",[preIdArray objectAtIndex:j]]];
                break;

            }
        }
        if(!isfound)
        {
            [dict setValue:@"N" forKey:@"select"];

        }
        [temp replaceObjectAtIndex:i withObject:dict ];
        
    }
    return temp;
}
-(void)callApi
{
     if(DELEGATE.connectedToNetwork)
        {
            if([USER_DEFAULTS valueForKey:@"userid"])
            {
                  [mc getDropDowns:[USER_DEFAULTS valueForKey:@"userid"] Sel:@selector(responseGetDropDown1:)];
            }
            else
            {
                [mc getDropDowns:nil Sel:@selector(responseGetDropDown1:)];
            }
            //[mc getDropDowns:@selector(responseGetDropDown1:)];
        }
    
}
-(void)responseGetDropDown1:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        if([[results valueForKey:@"hobbies"] count]>0)
        {
            if(preIdArray.count>0)
            {
                [hobbyArray addObjectsFromArray:[self getIDArrays:[results valueForKey:@"hobbies"]]];

            }
            else
            {
                [hobbyArray addObjectsFromArray:[self getArrays:[results valueForKey:@"hobbies"]]];

            }
        }
        NSLog(@"hobbyArray is %@",hobbyArray);

        [self.tableView reloadData];
       
        
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
       /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:[results valueForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
        [alert show];*/
    }
    
}

-(NSArray *)getArrays:(NSArray *)array
{
        NSMutableArray *temp=[[NSMutableArray alloc] initWithArray:array];
        for(int i=0; i<temp.count;i++)
        {
            NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[array objectAtIndex:i]];
            [dict setValue:@"N" forKey:@"select"];
            [temp replaceObjectAtIndex:i withObject:dict ];
            
        }
    return temp;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)checkBtnTapped:(UIButton *)sender
{
    //[drk showWithMessage:nil];
    [self.tableView setUserInteractionEnabled:NO];
    NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[hobbyArray objectAtIndex:[sender tag]]];
    if ([[[hobbyArray objectAtIndex:[sender tag]] objectForKey:@"select"] isEqualToString:@"Y"])
    {        //[selectedHobbyArray removeObjectAtIndex:[sender tag]];
        [selectedHobbyArray removeObject:[NSString stringWithFormat:@"%@",[[hobbyArray objectAtIndex:[sender tag]] objectForKey:@"id"]]];
        
        
        [dict setValue:@"N" forKey:@"select"];
    }
    else
    {
        [dict setValue:@"Y" forKey:@"select"];
        [selectedHobbyArray addObject:[NSString stringWithFormat:@"%@",[[hobbyArray objectAtIndex:[sender tag]] objectForKey:@"id"]]];
    }
    [hobbyArray replaceObjectAtIndex:[sender tag] withObject:dict ];
    [self.tableView reloadData];
    [self.tableView setUserInteractionEnabled:YES];

    //[drk hide];
}
- (IBAction)backTapped:(id)sender
{
    if(selectedHobbyArray.count>0)
    {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
        [dict setValue:[NSString stringWithFormat:@"%lu",(unsigned long)selectedHobbyArray.count] forKey:@"count"];
        [dict setValue:[NSString stringWithFormat:@"%@",[selectedHobbyArray componentsJoinedByString:@","]] forKey:@"ids"];
        [dict setValue:selectedHobbyArray forKey:@"selected"];
        if(isFirst)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"Hobby" object:nil userInfo:dict];

        }
        else
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"selectHobby" object:nil userInfo:dict];

        }

    }
    else
    {
        NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];

        [[NSNotificationCenter defaultCenter]postNotificationName:@"selectHobby" object:nil userInfo:dict];

    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(hobbyArray.count>0)
    {
        return hobbyArray.count;
    }
    else return 0;
    
    
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    HobbyCell *cell = (HobbyCell *)[tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HobbyCell" owner:self options:nil];
        cell=[nib objectAtIndex:0] ;
    }
    cell.delegate =self;
    
   
    
    if(IS_IPAD)
    {
        //[cell.lblHobbyName setFont:FONT_Regular(22)];
        
    }
    else
    {
        /* [cell.lblPrivate setFont:FONT_Regular(10)];
         [cell.lblName setFont:FONT_Regular(15)];
         [cell.lblDate setFont:FONT_Regular(12)];*/
        
        
    }
    
    cell.btnCheck.tag =indexPath.row;
    cell.imgHobby.layer.masksToBounds = YES;
    cell.imgHobby.layer.cornerRadius = 25.0;
    
    cell.lblHobbyName.text =[[hobbyArray objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    if([[[hobbyArray objectAtIndex:indexPath.row] valueForKey:@"image"] length]>0)
    {
        [cell.imgHobby sd_setImageWithURL:[NSURL URLWithString:[[hobbyArray objectAtIndex:indexPath.row] valueForKey:@"image"]]];
    }
    
    
  

    
    if ([[[hobbyArray objectAtIndex:indexPath.row] objectForKey:@"select"] isEqualToString:@"Y"])
    {
        [cell.btnCheck setImage:[UIImage imageNamed:@"tick2.png"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.btnCheck setImage:[UIImage imageNamed:@"tick1.png"] forState:UIControlStateNormal];
    }
   
    if(isOther)
    {
        [cell setUserInteractionEnabled:NO];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    


}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

@end

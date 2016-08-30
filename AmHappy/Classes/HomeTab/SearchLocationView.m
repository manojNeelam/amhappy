//
//  SearchLocationView.m
//  AmHappy
//
//  Created by Syntel-Amargoal1 on 8/24/16.
//
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#import "SearchLocationView.h"

@implementation SearchLocationView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
   if ((self = [super initWithCoder:aDecoder]))
    {
        [self.txtFldSearch setDelegate:self];
        [self.txtFldSearch setPlaceholder:[localization localizedStringForKey:@"Search location"]];
        [self.searchTableView setHidden:YES];
        
        [self.searchTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        self.baseSearchView.layer.borderWidth = 1.0f;
        self.baseSearchView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor lightGrayColor]);
        
        [self.txtFldSearch becomeFirstResponder];
    }
    return self;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if([self.txtFldSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length >0)
    {
        [self searchMap:textField.text];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.searchTableView setHidden:YES];
}

-(void)searchMap:(NSString *)searchAddress
{
    //https://maps.googleapis.com/maps/api/place/search/json?location=-33.8670522,151.1957362&radius=500&types=grocery_or_supermarket&sensor=true&key=AIzaSyAiFpFd85eMtfbvmVNEYuNds5TEF9FjIPI
    
    if([DELEGATE connectedToNetwork])
    {
        [self queryGooglePlaces:searchAddress];
    }
}

-(void) queryGooglePlaces:(NSString *)addressStr {
    
    NSString *url = [[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", addressStr]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    
    NSArray* places = [json objectForKey:@"results"];
    if(places)
    {
        [self.searchTableView setHidden:NO];
        [self.txtFldSearch resignFirstResponder];
        
        placesList = places;
        
        [self.searchTableView reloadData];
    }
    else
    {
        
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SearchLocationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *addressDict = [placesList objectAtIndex:indexPath.row];
    NSString *formatedAddress = [addressDict objectForKey:@"formatted_address"];
    NSMutableArray *sep = [NSMutableArray arrayWithArray:[formatedAddress componentsSeparatedByString:@","]];
    
    if(sep.count > 0)
    {
        [cell.textLabel setText:[sep objectAtIndex:0]];
        [sep removeObjectAtIndex:0];
    }
    
    NSMutableString *addressString = [NSMutableString string];
    for(int i=0; i<sep.count; i++)
    {
        if(i==0)
        {
            [[sep objectAtIndex:i] stringByReplacingOccurrencesOfString:@"," withString:@""];
        }
        [addressString appendString:[sep objectAtIndex:i]];
    }
    
    [cell.detailTextLabel setText:addressString];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = [placesList objectAtIndex:indexPath.row];
    [self.searchDelegate selectedAddress:dict];
    
    [self removeFromSuperview];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return placesList.count;
}

@end

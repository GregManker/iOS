//
//  SettingsViewController.m
//  AccelerometerGraph
//
//  Created by Ian Garcia-Doty on 5/19/14.
//
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize footStrikeCutoffSlider, footStrikeSliderLabel,soundSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set slider parameters and update label
    footStrikeCutoffSlider.continuous = YES;
    footStrikeCutoffSlider.minimumValue = 1;
    footStrikeCutoffSlider.maximumValue = 4;
    footStrikeCutoffSlider.value = 2;
    _footStrikeLabelString = [NSString stringWithFormat:@"%0.1f", footStrikeCutoffSlider.value];
    [footStrikeSliderLabel setText:_footStrikeLabelString];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)soundOnOrOff:(id)sender
{
    NSLog(@"Soundswitch pressed");
    
    [self.delegate addItemViewController:self didFinishEnteringItem:soundSwitch.isOn];
//    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)footStrikeCutoffSelect:(id)sender
{
    _footStrikeLabelString = [NSString stringWithFormat:@"%0.1f", footStrikeCutoffSlider.value];
    NSLog([NSString stringWithFormat:@"%.f", footStrikeCutoffSlider.value]);
    [footStrikeSliderLabel setText:_footStrikeLabelString];
    [self.delegate setFootstrikeCutoff:self didFinishEnteringItem:(double)footStrikeCutoffSlider.value];
    
}


- (void)dealloc {
    [soundSwitch release];
    [footStrikeCutoffSlider release];
    [footStrikeSliderLabel release];
    [footStrikeSliderLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setSoundSwitch:nil];
    [self setFootStrikeCutoffSlider:nil];
    [self setFootStrikeSliderLabel:nil];
    [super viewDidUnload];
}
@end

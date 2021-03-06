#import "MainViewController.h"
#import "GraphView.h"
#import "AccelerometerFilter.h"

#define kUpdateFrequency	60.0
#define kLocalizedPause		NSLocalizedString(@"Pause","pause taking samples")
#define kLocalizedResume	NSLocalizedString(@"Resume","resume taking samples")
#define systemSoundID    1025

@interface MainViewController()

// Sets up a new filter. Since the filter's class matters and not a particular instance
// we just pass in the class and -changeFilter: will setup the proper filter.
-(void)changeFilter:(Class)filterClass;

@end

@implementation MainViewController

@synthesize unfiltered, filtered, pause, filterLabel/*, settingsButton*/;

// Implement viewDidLoad to do additional setup after loading the view.
-(void)viewDidLoad
{
	[super viewDidLoad];
    [self setTitle:@"Gait Audibilizer"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(goToSettings)];
    
    //initialize ivariables
    footStrikeCutoff = 2;
    _soundOn = YES;
	pause.possibleTitles = [NSSet setWithObjects:kLocalizedPause, kLocalizedResume, nil];
	isPaused = NO;
	useAdaptive = NO;
	[self changeFilter:[LowpassFilter class]];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / kUpdateFrequency];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	[unfiltered setIsAccessibilityElement:YES];
	[unfiltered setAccessibilityLabel:NSLocalizedString(@"unfilteredGraph", @"")];

	[filtered setIsAccessibilityElement:YES];
	[filtered setAccessibilityLabel:NSLocalizedString(@"filteredGraph", @"")];
    
}

-(void) goToSettings {
    NSLog(@"settings button pressed");
    
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController"bundle:nil];
    settingsViewController.delegate=self;
    [self.navigationController pushViewController:settingsViewController animated:YES];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void)addItemViewController:(SettingsViewController *)controller didFinishEnteringItem:(BOOL *)item
{
    _soundOn = item;
    NSLog(item ? @"Yes" : @"No");
}

- (void)setFootstrikeCutoff:(SettingsViewController *)controller didFinishEnteringItem:(double)item
{
    footStrikeCutoff = item;
    NSLog([NSString stringWithFormat:@"%0.1f", footStrikeCutoff]);
}

-(void)viewDidUnload
{
    [self setSettingsButton:nil];
    [self setSettingsButton:nil];
	[super viewDidUnload];
	self.unfiltered = nil;
	self.filtered = nil;
	self.pause = nil;
	self.filterLabel = nil;
}

// UIAccelerometerDelegate method, called when the device accelerates.
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// Update the accelerometer graph view
	if(!isPaused)
	{
        //Play tone if acceleration is greater than cutoff value and sound is turned on
        //More complete step detection will be added here later
        if(self.soundOn){
            if (acceleration.y > footStrikeCutoff) {
                //play sound
                AudioServicesPlaySystemSound (systemSoundID);
                
                //Foot is now down
                self.footIsDown = YES;
            }
        }
        
		[filter addAcceleration:acceleration];
		[unfiltered addX:acceleration.x y:acceleration.y z:acceleration.z];
		[filtered addX:filter.x y:filter.y z:filter.z];
	}
}

-(void)changeFilter:(Class)filterClass
{
	// Ensure that the new filter class is different from the current one...
	if(filterClass != [filter class])
	{
		// And if it is, release the old one and create a new one.
		[filter release];
		filter = [[filterClass alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency:5.0];
		// Set the adaptive flag
		filter.adaptive = useAdaptive;
		// And update the filterLabel with the new filter name.
		filterLabel.text = filter.name;
	}
}

-(IBAction)pauseOrResume:(id)sender
{
    NSLog(@"pausing");
	if(isPaused)
	{
		// If we're paused, then resume and set the title to "Pause"
		isPaused = NO;
		pause.title = kLocalizedPause;
	}
	else
	{
		// If we are not paused, then pause and set the title to "Resume"
		isPaused = YES;
		pause.title = kLocalizedResume;
        AudioServicesPlaySystemSound (systemSoundID);
	}
	
	// Inform accessibility clients that the pause/resume button has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

-(IBAction)filterSelect:(id)sender
{
	if([sender selectedSegmentIndex] == 0)
	{
		// Index 0 of the segment selects the lowpass filter
		[self changeFilter:[LowpassFilter class]];
	}
	else
	{
		// Index 1 of the segment selects the highpass filter
		[self changeFilter:[HighpassFilter class]];
	}

	// Inform accessibility clients that the filter has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

-(IBAction)adaptiveSelect:(id)sender
{
	// Index 1 is to use the adaptive filter, so if selected then set useAdaptive appropriately
	useAdaptive = [sender selectedSegmentIndex] == 1;
	// and update our filter and filterLabel
	filter.adaptive = useAdaptive;
	filterLabel.text = filter.name;
	
	// Inform accessibility clients that the adaptive selection has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

//-(IBAction)settingsButton:(id)sender
//{
//    NSLog(@"settings button pressed");
//
//    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController"bundle:nil];
//    settingsViewController.delegate=self;
//    [self.navigationController pushViewController:settingsViewController animated:YES];
//    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
//}

-(void)dealloc
{
	// clean up everything.
	[unfiltered release];
	[filtered release];
	[filterLabel release];
	[pause release];
//    [settingsButton release];
	[super dealloc];
}

@end

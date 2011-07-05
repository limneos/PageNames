#import <SpringBoard/SpringBoard.h>
#import <QuartzCore/CALayer.h>
#import <substrate.h>
#define DICTPATH @"/var/mobile/Library/Preferences/net.limneos.pagesnamessettings.plist"

extern "C" void UIKeyboardEnableAutomaticAppearance();
extern "C" void UIKeyboardDisableAutomaticAppearance();

static UITextField *aTextField=nil;

@interface PNTextFieldDelegate : NSObject <UITextFieldDelegate>
@end

@implementation PNTextFieldDelegate
static id _sharedPNDelegate=nil;
-(id)init{
	_sharedPNDelegate=[super init];
	return _sharedPNDelegate;
}
+(id)sharedPNDelegate{
	if (!_sharedPNDelegate)	
		_sharedPNDelegate=[[self alloc] init];
	return _sharedPNDelegate;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	if (textField.text.length>0){
		NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithContentsOfFile:DICTPATH];
		id pageControl=MSHookIvar<id>([objc_getClass("SBIconController") sharedInstance],"_pageControl");
		int currentPage=[pageControl currentPage];
		if (!dict){
			dict=[NSMutableDictionary dictionary];
		}
		[dict setValue:textField.text forKey:[NSString stringWithFormat:@"%d",currentPage]];
		[dict writeToFile:DICTPATH atomically:YES];
	}
	[textField resignFirstResponder];
	return YES;
}
@end

%hook SBIconListPageControl
-(void)_setDisplayedPage:(int)page{
	%orig;
	NSDictionary *dictionary=[NSDictionary dictionaryWithContentsOfFile:DICTPATH];
	NSString *pageName;
	if (dictionary && [dictionary objectForKey:[NSString stringWithFormat:@"%d",page]]){
		pageName=[dictionary objectForKey:[NSString stringWithFormat:@"%d",page]];
	}
	else{
		pageName=page==0?  @"SpotLight" : [NSString stringWithFormat:@"Page %d",page];
	}
	
	[[objc_getClass("SBIconController") sharedInstance] setIdleModeText:pageName];
	UILabel *idleTextView=MSHookIvar<UILabel *>([objc_getClass("SBIconController") sharedInstance],"_idleText");
	idleTextView.textColor=[UIColor whiteColor];
	idleTextView.shadowColor=[UIColor blackColor];
	if (aTextField)
		aTextField.text=pageName;
}
%end

%hook SBIconController
-(void)setIsEditing:(BOOL)editing{
	%orig;
	if (editing){
		UILabel *idleTextView=MSHookIvar<UILabel *>(self,"_idleText");
		CGRect frame=idleTextView.frame;
		frame.size.height=25;
		aTextField=[[[UITextField alloc] initWithFrame:frame] autorelease];
		aTextField.returnKeyType=UIReturnKeyDone;
		aTextField.textAlignment=UITextAlignmentCenter;
		aTextField.font=[UIFont boldSystemFontOfSize:13];
		aTextField.borderStyle=UITextBorderStyleRoundedRect;
		aTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
		aTextField.text=idleTextView.text;
		aTextField.delegate=[PNTextFieldDelegate sharedPNDelegate];
		[[self contentView] addSubview:aTextField];
		UIKeyboardEnableAutomaticAppearance();
	}
	else{
		if (aTextField){
			[aTextField removeFromSuperview];
			aTextField=nil;
			UIKeyboardDisableAutomaticAppearance();
		}
	}
}
%end
#import <Preferences/Preferences.h>

@interface ReactionListController: PSListController {
}
@end

#define kUrl_FollowOnTwitter @"https://twitter.com/iMokhles"
#define kUrl_VisitWebSite @"http://iMokhles.com"
#define kUrl_MakeDonation @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=F4ZGWKWBKT82Y"

#define kPreferencesPath @"/User/Library/Preferences/com.imokhles.Reaction.plist"
#define kPreferencesChanged "com.imokhles.Reaction-preferencesChanged"

@implementation ReactionListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Reaction" target:self] retain];
	}
	return _specifiers;
}

- (void)followOnTwitter:(PSSpecifier*)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_FollowOnTwitter]];
}

- (void)visitWebSite:(PSSpecifier*)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_VisitWebSite]];
}

- (void)Donate:(PSSpecifier *)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_MakeDonation]];
}
-(id) readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *TGAnyFilesSettings = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];
    if (!TGAnyFilesSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return TGAnyFilesSettings[specifier.properties[@"key"]];
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kPreferencesPath]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:kPreferencesPath atomically:YES];
    NSDictionary *TGAnyFilesSettings = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];
    CFStringRef imokhlesPost = (CFStringRef)specifier.properties[@"PostNotification"];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), imokhlesPost, NULL, NULL, YES);
}
@end

// vim:ft=objc

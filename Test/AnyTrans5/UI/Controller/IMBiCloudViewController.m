//
//  IMBiCloudViewController.m
//  AnyTrans
//
//  Created by LuoLei on 16-7-13.
//  Copyright (c) 2016年 imobie. All rights reserved.
//

#import "IMBiCloudViewController.h"
#import "IMBNotificationDefine.h"
#import "TempHelper.h"
#import "IMBiCloudClient.h"
#import "StringHelper.h"
#import "IMBSecureTextFieldCell.h"
#import "StringHelper.h"
#import "IMBPreferencesSettingWindowController.h"
//#import "iCloudClient.h"
#import <ServiceManager/ServiceManager.h>
#import "IMBiCloudMainPageViewController.h"
#import "IMBiCloudPopViewController.h"
#import "SystemHelper.h"
#import "IMBBackgroundBorderView.h"

@interface IMBiCloudViewController ()

@end

@implementation IMBiCloudViewController
//@synthesize iCloudDic = _iCloudDic;
@synthesize icloudLogView = _icloudLogView;
@synthesize isLoginIng = _isLoginIng;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        return self;
    }else {
#if !__has_feature(objc_arc)
        [self release];
#endif
        return nil;
    }
}

-(void)dealloc{
    if (_appleID != nil) {
        [_appleID release];
        _appleID = nil;
    }
    if (_password != nil) {
        [_password release];
        _password = nil;
    }
    if (_icloud != nil) {
        [_icloud release];
        _icloud = nil;
    }
    if (_iCloudManager != nil) {
        [_iCloudManager release];
        _iCloudManager  = nil;
    }
    [_backupViewController release],_backupViewController = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_ICLOUD_ENTER_SIGNIN object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:INSERT_TAB object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTITY_ICLOUD_EXIT_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_APPLE_ID_PROTECTED_TWO_STEP_AUTHENTICATION_FAILURE object:nil];
    [super dealloc];
}

-(void)doChangeLanguage:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = CustomLocalizedString(@"iCloudLogin_View_Tips1", nil);
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:str];
        [as addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue Light" size:30] range:NSMakeRange(0, as.length)];
        [as addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)] range:NSMakeRange(0, as.length)];
        [as setAlignment:NSCenterTextAlignment range:NSMakeRange(0, as.length)];
        [_signiCloudMainTitle setAttributedStringValue:as];
        [as release];
        as = nil;
        [_bommotTitle setTextColor:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)]];
        [_bommotTitle setStringValue:CustomLocalizedString(@"iCloud_id_1", nil)];
        [_bommotSubStr setTextColor:[StringHelper getColorFromString:CustomColor(@"text_explainColor", nil)]];
        [_bommotSubStr setStringValue:CustomLocalizedString(@"iCloud_id_2", nil)];
        NSMutableAttributedString *as5 = [[[NSMutableAttributedString alloc] initWithString:CustomLocalizedString(@"iCloudLogin_View_AppleID", nil)] autorelease];
        [as5 addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_explainColor", nil)] range:NSMakeRange(0, as5.string.length)];
        [as5 setAlignment:NSLeftTextAlignment range:NSMakeRange(0, as5.string.length)];
        [as5 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range:NSMakeRange(0, as5.string.length)];
        [_appleTextFiled.cell setPlaceholderAttributedString:as5];
        
        NSMutableAttributedString *as2 = [[[NSMutableAttributedString alloc] initWithString:CustomLocalizedString(@"iCloudLogin_View_Password", nil)] autorelease];
        [as2 addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_explainColor", nil)] range:NSMakeRange(0, as2.string.length)];
        [as2 setAlignment:NSLeftTextAlignment range:NSMakeRange(0, as2.string.length)];
        [as2 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range:NSMakeRange(0, as2.string.length)];
        [_passwordTextField.cell setPlaceholderAttributedString:as2];
//        [_passwordTextField.cell setPlaceholderString:CustomLocalizedString(@"iCloudLogin_View_Password", nil)];
        
        [_jumpCompleteBtn WithMouseExitedfillColor:[NSColor clearColor] WithMouseUpfillColor:[NSColor clearColor] WithMouseDownfillColor:[NSColor clearColor] withMouseEnteredfillColor:[NSColor clearColor]];
        [_jumpCompleteBtn WithMouseExitedLineColor:[NSColor clearColor] WithMouseUpLineColor:[NSColor clearColor] WithMouseDownLineColor:[NSColor clearColor] withMouseEnteredLineColor:[NSColor clearColor]];
        [_jumpCompleteBtn WithMouseExitedtextColor:[StringHelper getColorFromString:CustomColor(@"nodata_linkeTitle_color", nil)] WithMouseUptextColor:[StringHelper getColorFromString:CustomColor(@"nodata_linkeTitle_color", nil)] WithMouseDowntextColor:[StringHelper getColorFromString:CustomColor(@"text_click_downColor", nil)] withMouseEnteredtextColor:[StringHelper getColorFromString:CustomColor(@"text_click_enterColor", nil)]];

        [_jumpCompleteBtn setTitleName:CustomLocalizedString(@"iCloud_id_3", nil) WithDarwRoundRect:0 WithLineWidth:0 withFont:[NSFont fontWithName:@"Helvetica Neue" size:14]];
        NSRect rect = [StringHelper calcuTextBounds:CustomLocalizedString(@"iCloud_id_3", nil) fontSize:14];
        [_jumpCompleteBtn setFrame:NSMakeRect((_middleView.frame.size.width - rect.size.width )/2, _jumpCompleteBtn.frame.origin.y, rect.size.width, _jumpCompleteBtn.frame.size.height)];
        [_jumpCompleteBtn setNeedsDisplay:YES];
        
        NSString *mainStr = CustomLocalizedString(@"iCloud_Default_Title", nil);
        NSMutableAttributedString *mainAs = [[NSMutableAttributedString alloc]initWithString:mainStr];
        
        if ([[SystemHelper getSystemLastNumberString] isVersionMajorEqual:@"9"]) {
            [mainAs addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue thin" size:40] range:NSMakeRange(0, mainAs.length)];
        }else {
            [mainAs addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue Light" size:40] range:NSMakeRange(0, mainAs.length)];
        }
        [mainAs addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)] range:NSMakeRange(0, mainAs.length)];
        
        [mainAs setAlignment:NSCenterTextAlignment range:NSMakeRange(0, mainAs.length)];
        [_titleTextField setAttributedStringValue:mainAs];
        
        NSString *subStr = CustomLocalizedString(@"iCloud_Default_NoInstall_Describe", nil);
        NSMutableAttributedString *subAs = [[NSMutableAttributedString alloc]initWithString:subStr];
        [subAs addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:16] range:NSMakeRange(0, subAs.length)];
        [subAs setAlignment:NSCenterTextAlignment range:NSMakeRange(0, subAs.length)];
        [subAs addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_explainColor", nil)] range:NSMakeRange(0, subAs.length)];
        [_promptTextField setAttributedStringValue:subAs];
        
        [_loginBtn setIsLeftRightGridient:YES withLeftNormalBgColor:[StringHelper getColorFromString:CustomColor(@"download_normal_leftcolor", nil)] withRightNormalBgColor:[StringHelper getColorFromString:CustomColor(@"download_normal_rightcolor", nil)] withLeftEnterBgColor:[StringHelper getColorFromString:CustomColor(@"download_enter_leftcolor", nil)] withRightEnterBgColor:[StringHelper getColorFromString:CustomColor(@"download_enter_rightcolor", nil)] withLeftDownBgColor:[StringHelper getColorFromString:CustomColor(@"download_down_leftcolor", nil)] withRightDownBgColor:[StringHelper getColorFromString:CustomColor(@"download_down_rightcolor", nil)] withLeftForbiddenBgColor:[StringHelper getColorFromString:CustomColor(@"download_org_normal_leftColor", nil)] withRightForbiddenBgColor:[StringHelper getColorFromString:CustomColor(@"download_org_normal_rightColor", nil)]];
        [_loginBtn setButtonTitle:CustomLocalizedString(@"iCloud_Login", nil) withNormalTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withEnterTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withDownTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withForbiddenTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withTitleSize:18.0 WithLightAnimation:NO];
        [_loginBtn setHasBorder:NO];
        [_loginBtn setIsiCloudCompleteBtn:NO];
        
    });
    
}

- (void)addobserverNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signDown:) name:NOTIFY_ICLOUD_SIGNIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertTabKey:) name:INSERT_TAB object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudExitLogin:) name:NOTITY_ICLOUD_EXIT_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAppleIDProtectedTwoStepAuthenticationFailure:) name:NOTIFY_APPLE_ID_PROTECTED_TWO_STEP_AUTHENTICATION_FAILURE object:nil];
}

- (void)loadControl{
    [_icloudLogView setIsGradientColorNOCornerPart4:YES];
    [_appleTextFiled setTextColor:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)]];
    [_icloudImageView setImage:[StringHelper imageNamed:@"iCloud_icon"]];
    [((customTextFieldCell *)_appleTextFiled.cell) setCursorColor:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)]];
    
    NSString *str = CustomLocalizedString(@"iCloudLogin_View_Tips1", nil);
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:str];
    [as addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue Light" size:30] range:NSMakeRange(0, as.length)];
    [as addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)] range:NSMakeRange(0, as.length)];
    [as setAlignment:NSCenterTextAlignment range:NSMakeRange(0, as.length)];
    [_signiCloudMainTitle setAttributedStringValue:as];
    [as release];
    as = nil;
    [_bommotTitle setTextColor:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)]];
    [_bommotSubStr setTextColor:[StringHelper getColorFromString:CustomColor(@"text_explainColor", nil)]];
    [_bommotTitle setStringValue:CustomLocalizedString(@"iCloud_id_1", nil)];
    [_bommotSubStr setStringValue:CustomLocalizedString(@"iCloud_id_2", nil)];
    
    [_rootBox setContentView:_icloudLogView];
    [_jumpCompleteBtn setBackgroundColor:[NSColor clearColor]];
    [_jumpCompleteBtn WithMouseExitedfillColor:[NSColor clearColor] WithMouseUpfillColor:[NSColor clearColor] WithMouseDownfillColor:[NSColor clearColor] withMouseEnteredfillColor:[NSColor clearColor]];
    [_jumpCompleteBtn WithMouseExitedLineColor:[NSColor clearColor] WithMouseUpLineColor:[NSColor clearColor] WithMouseDownLineColor:[NSColor clearColor] withMouseEnteredLineColor:[NSColor clearColor]];
    [_jumpCompleteBtn WithMouseExitedtextColor:[StringHelper getColorFromString:CustomColor(@"nodata_linkeTitle_color", nil)] WithMouseUptextColor:[StringHelper getColorFromString:CustomColor(@"nodata_linkeTitle_color", nil)] WithMouseDowntextColor:[StringHelper getColorFromString:CustomColor(@"text_click_downColor", nil)] withMouseEnteredtextColor:[StringHelper getColorFromString:CustomColor(@"text_click_enterColor", nil)]];
    
    [_jumpCompleteBtn setTitleName:CustomLocalizedString(@"iCloud_id_3", nil) WithDarwRoundRect:0 WithLineWidth:0 withFont:[NSFont fontWithName:@"Helvetica Neue" size:14]];
    NSRect rect = [StringHelper calcuTextBounds:CustomLocalizedString(@"iCloud_id_3", nil) fontSize:14];
    [_jumpCompleteBtn setFrame:NSMakeRect((_middleView.frame.size.width - rect.size.width )/2, _jumpCompleteBtn.frame.origin.y, rect.size.width, _jumpCompleteBtn.frame.size.height)];
    [_lineView setBackgroundColor:[StringHelper getColorFromString:CustomColor(@"line_windowColor", nil)]];
    [self.view setWantsLayer:YES];
    [self.view.layer setMasksToBounds:YES];
    [self.view.layer setCornerRadius:5];
    [(IMBSecureTextFieldCell *)_passwordTextField.cell setDelegate:self];
    [((IMBSecureTextFieldCell *)_passwordTextField.cell) setCursorColor:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)]];
    
    //    [_appleTextFiled.cell setPlaceholderString:CustomLocalizedString(@"iCloudLogin_View_AppleID", nil)];
    //    [_passwordTextField.cell setPlaceholderString:CustomLocalizedString(@"iCloudLogin_View_Password", nil)];
    NSMutableAttributedString *as5 = [[[NSMutableAttributedString alloc] initWithString:CustomLocalizedString(@"iCloudLogin_View_AppleID", nil)] autorelease];
    [as5 addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_explainColor", nil)] range:NSMakeRange(0, as5.string.length)];
    [as5 setAlignment:NSLeftTextAlignment range:NSMakeRange(0, as5.string.length)];
    [as5 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range:NSMakeRange(0, as5.string.length)];
    [_appleTextFiled.cell setPlaceholderAttributedString:as5];
    
    NSMutableAttributedString *as2 = [[[NSMutableAttributedString alloc] initWithString:CustomLocalizedString(@"iCloudLogin_View_Password", nil)] autorelease];
    [as2 addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_explainColor", nil)] range:NSMakeRange(0, as2.string.length)];
    [as2 setAlignment:NSLeftTextAlignment range:NSMakeRange(0, as2.string.length)];
    [as2 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range:NSMakeRange(0, as2.string.length)];
    [_passwordTextField.cell setPlaceholderAttributedString:as2];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self addobserverNotification];
    [self loadControl];
    _connection = [IMBDeviceConnection singleton];
    
    NSString *str = CustomLocalizedString(@"iCloud_Default_Title", nil);
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc]initWithString:str];
    
    if ([[SystemHelper getSystemLastNumberString] isVersionMajorEqual:@"9"]) {
        [as addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue thin" size:40] range:NSMakeRange(0, as.length)];
    }else {
        [as addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue Light" size:40] range:NSMakeRange(0, as.length)];
    }
    [as addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)] range:NSMakeRange(0, as.length)];
    
    [as setAlignment:NSCenterTextAlignment range:NSMakeRange(0, as.length)];
    [_titleTextField setAttributedStringValue:as];
    
    NSString *str2 = CustomLocalizedString(@"iCloud_Default_NoInstall_Describe", nil);
    NSMutableAttributedString *as2 = [[NSMutableAttributedString alloc]initWithString:str2];
    [as2 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:16] range:NSMakeRange(0, as2.length)];
    [as2 setAlignment:NSCenterTextAlignment range:NSMakeRange(0, as2.length)];
    [as2 addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_explainColor", nil)] range:NSMakeRange(0, as2.length)];
    [_promptTextField setAttributedStringValue:as2];
    
    [_loginBtn setIsLeftRightGridient:YES withLeftNormalBgColor:[StringHelper getColorFromString:CustomColor(@"download_normal_leftcolor", nil)] withRightNormalBgColor:[StringHelper getColorFromString:CustomColor(@"download_normal_rightcolor", nil)] withLeftEnterBgColor:[StringHelper getColorFromString:CustomColor(@"download_enter_leftcolor", nil)] withRightEnterBgColor:[StringHelper getColorFromString:CustomColor(@"download_enter_rightcolor", nil)] withLeftDownBgColor:[StringHelper getColorFromString:CustomColor(@"download_down_leftcolor", nil)] withRightDownBgColor:[StringHelper getColorFromString:CustomColor(@"download_down_rightcolor", nil)] withLeftForbiddenBgColor:[StringHelper getColorFromString:CustomColor(@"download_org_normal_leftColor", nil)] withRightForbiddenBgColor:[StringHelper getColorFromString:CustomColor(@"download_org_normal_rightColor", nil)]];
    [_loginBtn setButtonTitle:CustomLocalizedString(@"iCloud_Login", nil) withNormalTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withEnterTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withDownTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withForbiddenTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withTitleSize:18.0 WithLightAnimation:NO];
//    [_loginBtn setHasLeftImage:YES];
//    [_loginBtn setLeftImage:[StringHelper imageNamed:@"toios_btngift_la"]];
    [_loginBtn setHasBorder:NO];
    [_loginBtn setIsiCloudCompleteBtn:NO];
    [_loginBtn setTarget:self];
    [_loginBtn setAction:@selector(enterTextView:)];
    [_loginBtn setNeedsDisplay:YES];
    
    [_nonectimageView setImage:[StringHelper imageNamed:@"noconnect_icloud"]];
}

- (void)changeSkin:(NSNotification *)notification
{
    [_icloudLogView setIsGradientColorNOCornerPart4:YES];
    [_icloudImageView setImage:[StringHelper imageNamed:@"iCloud_icon"]];
    [_appleTextFiled setTextColor:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)]];
    [((customTextFieldCell *)_appleTextFiled.cell) setCursorColor:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)]];
    [_drawTextFiledView setNeedsDisplay:YES];
    [_lineView setBackgroundColor:[StringHelper getColorFromString:CustomColor(@"line_windowColor", nil)]];
    [_icloudLogView setNeedsDisplay:YES];
    [_rootBox setNeedsDisplay:YES];
    [self doChangeLanguage:nil];
    [((IMBBackgroundBorderView *)self.view) setIsGradientWithCornerPart3:YES];
    [_nonectimageView setImage:[StringHelper imageNamed:@"noconnect_icloud"]];
}

- (IBAction)enterTextView:(id)sender {
    if (!_isLoginIng) {
        if (![StringHelper stringIsNilOrEmpty:_appleTextFiled.stringValue]) {
            _isLoginIng = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_ENTER_SIGNIN object:nil userInfo:nil];
            [self signDown:sender];
        }
    }
}

-(void)signDown:(id)sender{
    NSDictionary *dimensionDict = nil;
    @autoreleasepool {
        dimensionDict = [[TempHelper customDimension] copy];
    }
    [ATTracker event:iCloud_Content action:Login actionParams:@"iCloud Control Panel Login" label:LabelNone transferCount:0 screenView:@"iCloud Control Panel Login" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
    if (dimensionDict) {
        [dimensionDict release];
        dimensionDict = nil;
    }
    [_loginBtn setButtonTitle:CustomLocalizedString(@"iCloud_Logining", nil) withNormalTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withEnterTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withDownTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withForbiddenTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withTitleSize:18.0 WithLightAnimation:NO];
    [_loginBtn setNeedsDisplay:YES];
    if (_password != nil) {
        [_password release];
        _password = nil;
    }
    _isLoginIng = YES;
    [_jumpCompleteBtn setEnabled:NO];
     NSString *appleId = [_appleTextFiled.stringValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    _password = [_passwordTextField.stringValue retain];
    [_appleTextFiled.cell setEnabled:NO];
    [_passwordTextField.cell setEnabled:NO];
    NSMutableArray *loginAccount = [[[NSMutableArray alloc] init] autorelease];
    for (IMBBaseInfo *baseInfo in _connection.allDevice) {
        if ([baseInfo isicloudView]) {
            [loginAccount addObject:[baseInfo uniqueKey]];
        }
    }
    
    if ([appleId isEqualToString: @""]){
        _isLoginIng = NO;
        [_appleTextFiled.cell setEnabled:YES];
        [_passwordTextField.cell setEnabled:YES];
        [self showAlertText:CustomLocalizedString(@"iCloud_id_4", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_SIGNIN_FAIL object:nil userInfo:nil];
        [_loginBtn setButtonTitle:CustomLocalizedString(@"iCloud_Login", nil) withNormalTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withEnterTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withDownTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withForbiddenTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withTitleSize:18.0 WithLightAnimation:NO];
        [_loginBtn setNeedsDisplay:YES];
        return;
    }else if ([_password isEqualToString:@""]){
        _isLoginIng = NO;
        [_appleTextFiled.cell setEnabled:YES];
        [_passwordTextField.cell setEnabled:YES];
        [self showAlertText:CustomLocalizedString(@"iCloud_id_4", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_SIGNIN_FAIL object:nil userInfo:nil];
        [_loginBtn setButtonTitle:CustomLocalizedString(@"iCloud_Login", nil) withNormalTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withEnterTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withDownTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withForbiddenTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withTitleSize:18.0 WithLightAnimation:NO];
        [_loginBtn setNeedsDisplay:YES];
        return;
    }else if ([loginAccount containsObject:[appleId lowercaseString]]) {
        _isLoginIng = NO;
        [_appleTextFiled.cell setEnabled:YES];
        [_passwordTextField.cell setEnabled:YES];
        [self showAlertText:CustomLocalizedString(@"icloud_Repeat_login_tip", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_SIGNIN_FAIL object:nil userInfo:nil];
        
        [_loginBtn setButtonTitle:CustomLocalizedString(@"iCloud_Login", nil) withNormalTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withEnterTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withDownTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withForbiddenTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withTitleSize:18.0 WithLightAnimation:NO];
        [_loginBtn setNeedsDisplay:YES];
        return;

    }
    [self performSelectorOnMainThread:@selector(checkInternet:) withObject:appleId waitUntilDone:NO];
}

- (void)checkInternet:(NSString *)appleId {
    BOOL isauvilble = [TempHelper isInternetAvail];
    if (isauvilble) {
        [self loadiCloudLogin:appleId withPassword:_password];
    }else{
        NSDictionary *dimensionDict = nil;
        @autoreleasepool {
            dimensionDict = [[TempHelper customDimension] copy];
        }
        [ATTracker event:iCloud_Content action:ActionNone actionParams:@"iCloud Control Panel Login Failed" label:Click transferCount:0 screenView:@"iCloud Control Panel Login Failed" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        if (dimensionDict) {
            [dimensionDict release];
            dimensionDict = nil;
        }
        [_appleTextFiled.cell setEnabled:YES];
        [_passwordTextField.cell setEnabled:YES];
        [self showAlertText:CustomLocalizedString(@"iCloud_id_5", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_SIGNIN_FAIL object:nil userInfo:nil];
        
        _isLoginIng = NO;
        [_loginBtn setButtonTitle:CustomLocalizedString(@"iCloud_Login", nil) withNormalTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withEnterTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withDownTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withForbiddenTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withTitleSize:18.0 WithLightAnimation:NO];
        [_loginBtn setNeedsDisplay:YES];
    }
}

- (void)loginFail
{
    [_appleTextFiled.cell setEnabled:YES];
    [_passwordTextField.cell setEnabled:YES];
    if (!_isTwoValidation) {
        _isTwoValidation = NO;
        [self showAlertText:CustomLocalizedString(@"iCloud_id_4", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }
}

- (void)needReLogin{
    [self cleanTextField];
    [self setIsLoginIng:NO];
    [self showAlertText:CustomLocalizedString(@"icloud_login_fail", nil) OKButton:CustomLocalizedString(@"Button_Ok",nil)];
}

- (void)loadiCloudLogin:(NSString *)appledID withPassword:(NSString *)passMword {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (_iCloudManager != nil) {
            [_iCloudManager release];
            _iCloudManager  = nil;
        }
        _iCloudManager = [[IMBiCloudManager alloc] init];
        BOOL ret = [_iCloudManager loginiCloudAppleID:appledID WithPassword:passMword];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (ret && !_isTwoValidation) {
                NSDictionary *dimensionDict = nil;
                @autoreleasepool {
                    dimensionDict = [[TempHelper customDimension] copy];
                }
                [ATTracker event:iCloud_Content action:ActionNone actionParams:@"iCloud Control Panel Login Successfully" label:Click transferCount:0 screenView:@"iCloud Control Panel Login Successfully" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
                if (dimensionDict) {
                    [dimensionDict release];
                    dimensionDict = nil;
                }
                _isLoginIng = NO;
                if (_appleID != nil) {
                    [_appleID release];
                    _appleID = nil;
                }
                _appleID = [appledID retain];
                IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc] init];
                IMBiCloudMainPageViewController *icloudMainPage = [[IMBiCloudMainPageViewController alloc] initWithClient:_iCloudManager withDelegate:self];
                [_rootBox setContentView:icloudMainPage.view];
                [self setIsShowLineView:icloudMainPage.isShowLineView];
                [icloudMainPage.view setBounds:_rootBox.bounds];
                NSString *name = _iCloudManager.netClient.loginInfo.loginInfoEntity.fullName;
                [baseInfo setUniqueKey:_appleID];
                [baseInfo setConnectType:general_iCloud];
                [baseInfo setIsicloudView:YES];
                [[baseInfo accountiCloud] addObject:icloudMainPage];
                [[_connection iCloudDic] setObject:icloudMainPage forKey:_appleID];
                if (![StringHelper stringIsNilOrEmpty:name]) {
                    [baseInfo setDeviceName:name];
                    [_selectDeviceButton configButtonName:name WithTextColor:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)] WithTextSize:12 WithIsShowIcon:YES WithIsShowTrangle:YES WithIsDisable:NO withConnectType:baseInfo.connectType];
                }
                [[_connection allDevice] addObject:baseInfo];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                          baseInfo, @"DeviceInfo"
                                          , nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceBtnChangeNotification object:[NSNumber numberWithBool:YES] userInfo:userInfo];
                [baseInfo release];
                baseInfo = nil;
                
                [_appleTextFiled.cell setEnabled:YES];
                [_passwordTextField.cell setEnabled:YES];
                [icloudMainPage release];
                
                [_loginBtn setButtonTitle:CustomLocalizedString(@"iCloud_Login", nil) withNormalTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withEnterTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withDownTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withForbiddenTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withTitleSize:18.0 WithLightAnimation:NO];
                [_loginBtn setNeedsDisplay:YES];
            }else{
                _isLoginIng = NO;
                [self performSelectorOnMainThread:@selector(loginFail) withObject:nil waitUntilDone:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_SIGNIN_FAIL object:nil userInfo:nil];
                NSDictionary *dimensionDict = nil;
                @autoreleasepool {
                    dimensionDict = [[TempHelper customDimension] copy];
                }
                [ATTracker event:iCloud_Content action:ActionNone actionParams:@"iCloud Control Panel Login Failed" label:Click transferCount:0 screenView:@"iCloud Control Panel Login Failed" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
                if (dimensionDict) {
                    [dimensionDict release];
                    dimensionDict = nil;
                }
                
                [_loginBtn setButtonTitle:CustomLocalizedString(@"iCloud_Login", nil) withNormalTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withEnterTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withDownTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withForbiddenTitleColor:[StringHelper getColorFromString:CustomColor(@"generalBtn_exitColor", nil)] withTitleSize:18.0 WithLightAnimation:NO];
                [_loginBtn setNeedsDisplay:YES];
            }
            [_jumpCompleteBtn setEnabled:YES];
        });
    });
}

- (void)onItemClicked:(NSString *)account
{
    if (account != nil && [account isEqualToString:CustomLocalizedString(@"icloud_addAcount", nil)]) {
        [self cleanTextField];
        [devPopover close];
        [_rootBox setContentView:_icloudLogView];
        [self setIsShowLineView:NO];
        [self.view setBounds:_rootBox.bounds];
        [_selectDeviceButton configButtonName:CustomLocalizedString(@"MainWindow_id_9", nil) WithTextColor:[StringHelper getColorFromString:CustomColor(@"text_normalColor", nil)] WithTextSize:12 WithIsShowIcon:YES WithIsShowTrangle:YES WithIsDisable:NO withConnectType:7000];
        if (_appleID != nil) {
            [_appleID release];
            _appleID = nil;
        }
        return;
    }
}

- (void)setRootBoxContentView:(IMBiCloudMainPageViewController *)icloudMainPage {
    [_rootBox setContentView:icloudMainPage.view];
//    [self setIsShowLineView:icloudMainPage.isShowLineView];
}

-(void)cleanTextField{
    [_appleTextFiled setStringValue:@""];
    NSMutableAttributedString *as5 = [[[NSMutableAttributedString alloc] initWithString:CustomLocalizedString(@"iCloudLogin_View_AppleID", nil)] autorelease];
    [as5 addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_explainColor", nil)] range:NSMakeRange(0, as5.string.length)];
    [as5 setAlignment:NSLeftTextAlignment range:NSMakeRange(0, as5.string.length)];
    [as5 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range:NSMakeRange(0, as5.string.length)];
    [_appleTextFiled.cell setPlaceholderAttributedString:as5];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_SIGNIN_FAIL object:nil userInfo:nil];
    [_passwordTextField.cell setStringValue:@""];
    
    NSMutableAttributedString *as2 = [[[NSMutableAttributedString alloc] initWithString:CustomLocalizedString(@"iCloudLogin_View_Password", nil)] autorelease];
    [as2 addAttribute:NSForegroundColorAttributeName value:[StringHelper getColorFromString:CustomColor(@"text_explainColor", nil)] range:NSMakeRange(0, as2.string.length)];
    [as2 setAlignment:NSLeftTextAlignment range:NSMakeRange(0, as2.string.length)];
    [as2 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range:NSMakeRange(0, as2.string.length)];
    [_passwordTextField.cell setPlaceholderAttributedString:as2];
}

-(void)doSearchBtn:(NSString *)searchStr withSearchBtn:(IMBSearchView *)searchBtn{
    _searchFieldBtn = searchBtn;
    [_backupViewController doSearchBtn:searchStr withSearchBtn:searchBtn];
}

- (void)insertTabKey:(id)sender {
    [_passwordTextField becomeFirstResponder];
}

#pragma mark -- ios9 以后的两步验证代理
- (void)doAppleIDProtectedTwoStepAuthenticationFailure:(NSNotification *)notify {
    dispatch_sync(dispatch_get_main_queue(), ^{
        _isTwoValidation = YES;
        [self showAlertText:CustomLocalizedString(@"iCloud_DoubleCheck_Error", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    });
}

- (NSDictionary *)getiCloudDic {
    return [[_connection iCloudDic] copy];
}

@end
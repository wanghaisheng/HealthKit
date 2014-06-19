/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Displays age, height, and weight information retrieved from HealthKit.
            
*/
#define k0 0.0f
#define kBmiConstant 703.07f
///
#define kWeightUnder 18.5f
#define kWeightNormal 25.0f
#define kWeightObese 30.0f
//
#define kBmiUnknown 0.0f
#define kBmiUnder 0.25f
#define kBmiNormal 0.5f
#define kBmiOver 0.75f
#define kBmiObese 1.0f
///
#import "AAPLProfileViewController.h"
@import HealthKit;
///
@interface AAPLProfileViewController ()<UITextFieldDelegate>
///
// Note that the age of a person cannot be changed, so it has a label instead of a text field (in other words, the user can't edit their age but they can edit their height and weight).
@property (nonatomic, weak) IBOutlet UILabel *ageHeightValueLabel;

@property (nonatomic, weak) IBOutlet UITextField *heightValueTextField;
@property (nonatomic, weak) IBOutlet UILabel *heightUnitLabel;

@property (nonatomic, weak) IBOutlet UITextField *weightValueTextField;
@property (nonatomic, weak) IBOutlet UILabel *weightUnitLabel;

@property (nonatomic, weak) IBOutlet UIProgressView *bmiProgressView;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;

@end
///
@implementation AAPLProfileViewController
///
@synthesize usersHeight, usersWeight, bmiIndex, bmiProgressView;
///
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.heightValueTextField becomeFirstResponder];
    
    // Update the user interface based on the current user's health information.
//    [self updateUsersAge];
    [self updateUsersHeight];
    [self updateUsersWeight];
    
    [self updateBMI];
}
///
- (void)updateBMI
{
    static NSString *kStrUnder = @"Underweight";
    static NSString *kStrOver = @"Overweight";
    static NSString *kStrObese = @"Obese";
    static NSString *kStrNormal = @"Normal";
    static NSString *kStrUnknown = @"Unknown";
    
    CGFloat bmi = k0;
    self.bmiIndex = kBmiUnknown;
    UIColor *color = UIColor.blackColor;
    NSString *weightString;
    
    if (self.usersHeight > k0 && self.usersWeight > k0)
    {
        bmi = self.usersWeight / (self.usersHeight * self.usersHeight);
        bmi *= kBmiConstant;
        
        if (bmi < kWeightUnder)
        {
            self.bmiIndex = kBmiUnder;
            color = UIColor.lightGrayColor;
            weightString = kStrUnder;
        }
        else if (bmi > kWeightObese)
        {
            self.bmiIndex = kWeightObese;
            color = UIColor.redColor;
            weightString = kStrObese;
        }
        else if (bmi > kWeightNormal)
        {
            self.bmiIndex = kBmiOver;
            color = UIColor.orangeColor;
            weightString = kStrOver;
        }
        else
        {
            self.bmiIndex = kBmiNormal;
            color = UIColor.yellowColor;
            weightString = kStrNormal;
        }
    }
    else
    {
        weightString = kStrUnknown;
    }
    
    
    self.bmiProgressView.progress = self.bmiIndex;
    self.bmiProgressView.progressTintColor = color;
    self.progressLabel.textColor = color;
    self.progressLabel.text = weightString;

    NSString *bmiString = [NSNumberFormatter localizedStringFromNumber:@(bmi) numberStyle:NSNumberFormatterDecimalStyle];
    self.ageHeightValueLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@", nil), bmiString];
}
///
- (void)updateUsersHeight
{
    [self saveHeightIntoHealthStore];

    // Fetch user's default height unit in inches.
    NSLengthFormatter *lengthFormatter = [[NSLengthFormatter alloc] init];
    lengthFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    NSLengthFormatterUnit heightFormatterUnit = NSLengthFormatterUnitInch;
    self.heightUnitLabel.text = [lengthFormatter unitStringFromValue:10 unit:heightFormatterUnit];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    // Query to get the user's latest height, if it exists.
    [self fetchMostRecentDataOfQuantityType:heightType withCompletion:^(HKQuantity *mostRecentQuantity, NSError *error)
    {
        if (error) {
            NSLog(@"An error occured fetching the user's height information. In your app, try to handle this gracefully. The error was: %@.", error);
//            abort();
            NSAssert(NO, nil);
        }
        
        // Determine the height in the required unit.
        
        if (mostRecentQuantity)
        {
            HKUnit *heightUnit = [HKUnit inchUnit];
            usersHeight = [mostRecentQuantity doubleValueForUnit:heightUnit];
            
            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
                self.heightValueTextField.text = [NSNumberFormatter localizedStringFromNumber:@(usersHeight) numberStyle:NSNumberFormatterNoStyle];
            });
        }
    }];
}

- (void)updateUsersWeight
{
    [self saveWeightIntoHealthStore];

    // Fetch the user's default weight unit in pounds.
    NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
    massFormatter.unitStyle = NSFormattingUnitStyleLong;
    
    NSMassFormatterUnit weightFormatterUnit = NSMassFormatterUnitPound;
    self.weightUnitLabel.text = [massFormatter unitStringFromValue:10 unit:weightFormatterUnit];
    
    // Query to get the user's latest weight, if it exists.
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    [self fetchMostRecentDataOfQuantityType:weightType withCompletion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        if (error) {
            NSLog(@"An error occured fetching the user's weight information. In your app, try to handle this gracefully. The error was: %@.", error);
//            abort();
            NSAssert(NO, nil);
        }
        
        // Determine the weight in the required unit.
        
        if (mostRecentQuantity) {
            HKUnit *weightUnit = [HKUnit poundUnit];
            usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
            
            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
                self.weightValueTextField.text = [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle];
            });
        }
    }];
}

// Get the single most recent quantity sample from health store.
- (void)fetchMostRecentDataOfQuantityType:(HKQuantityType *)quantityType withCompletion:(void (^)(HKQuantity *mostRecentQuantity, NSError *error))completion {
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (completion && error) {
            completion(nil, error);
            return;
        }
        
        // If quantity isn't in the database, return nil in the completion block.
        HKQuantitySample *quantitySample = results.firstObject;
        HKQuantity *quantity = quantitySample.quantity;
        
        if (completion) completion(quantity, error);
    }];
    
    [self.healthStore executeQuery:query];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField == self.heightValueTextField) {
        [self saveHeightIntoHealthStore];
    } else if (textField == self.weightValueTextField) {
        [self saveWeightIntoHealthStore];
    }
    
    [self updateBMI];

    return YES;
}

- (void)saveHeightIntoHealthStore
{
    NSNumberFormatter *formatter = [self numberFormatter];
    NSNumber *height = [formatter numberFromString:self.heightValueTextField.text];
    
    if (!height && [self.heightValueTextField.text length]) {
        NSLog(@"The height entered is not numeric. In your app, try to handle this gracefully.");
//        abort();
        NSAssert(NO, nil);
    }
    
    if (height)
    {
        self.usersHeight = [height floatValue];
        
        // Save the user's height into HealthKit.
        HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
        HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:[HKUnit inchUnit] doubleValue:[height doubleValue]];
        HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:[NSDate date] endDate:[NSDate date]];
        
        [self.healthStore saveObject:heightSample withCompletion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", heightSample, error);
//                abort();
                NSAssert(NO, nil);
            }
            
        }];
    }
}

- (void)saveWeightIntoHealthStore
{
    NSNumberFormatter *formatter = [self numberFormatter];
    NSNumber *weight = [formatter numberFromString:self.weightValueTextField.text];
    
    if (!weight && [self.weightValueTextField.text length]) {
        NSLog(@"The weight entered is not numeric. In your app, try to handle this gracefully.");
//        abort();
        NSAssert(NO, nil);
    }
    
    if (weight)
    {
        self.usersWeight = [weight floatValue];

        // Save the user's weight into HealthKit.
        HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:[HKUnit poundUnit] doubleValue:[weight doubleValue]];
        HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:[NSDate date] endDate:[NSDate date]];
        
        [self.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"An error occured saving the weight sample %@. In your app, try to handle this gracefully. The error was: %@.", weightSample, error);
//                abort();
                NSAssert(NO, nil);
            }
            
        }];
    }
}


#pragma mark - Convenience

- (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *numberFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
    });
    
    return numberFormatter;
}
///
- (IBAction) infoAction:(UIBarButtonItem *) bbi
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://en.wikipedia.org/wiki/Body_mass_index"]];
}

@end


#if keep

- (void)updateUsersAge
{
    NSAssert(NO, nil); // keep for reference
    
    NSError *error;
    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
    
    NSLog(@"DOB: %@ updateUsersAge", [self formattedDate:dateOfBirth]);
    
    if (error) {
        NSLog(@"An error occured fetching the user's age information. In your app, try to handle this gracefully. The error was: %@.", error);
//        abort();
        NSAssert(NO, nil);
    }
    
    if (!dateOfBirth) {
        return;
    }
    
    // Compute the age of the user.
    NSDate *now = [NSDate date];
    
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:NSCalendarWrapComponents];
    
    NSUInteger usersAge = [ageComponents year];
    
    NSString *ageHeightValueString = [NSNumberFormatter localizedStringFromNumber:@(usersAge) numberStyle:NSNumberFormatterNoStyle];
    
    self.ageHeightValueLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ years", nil), ageHeightValueString];
}

///
- (NSString *) formattedDate:(NSDate *) date
{
    if (!date) return @"Missing";
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *str = [df stringFromDate:date];
    return str;
}
///

#endif
























































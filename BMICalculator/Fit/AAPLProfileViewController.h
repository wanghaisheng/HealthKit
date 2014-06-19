/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Displays age, height, and weight information retrieved from HealthKit.
            
*/

@import UIKit;
@import HealthKit;

@interface AAPLProfileViewController : UITableViewController

@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic, assign) double usersHeight;
@property (nonatomic, assign) double usersWeight;
@property (nonatomic, assign) double bmiIndex;

@end

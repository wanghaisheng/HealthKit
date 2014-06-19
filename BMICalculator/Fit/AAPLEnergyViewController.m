/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Displays energy-related information retrieved from HealthKit.
            
*/

#import "AAPLEnergyViewController.h"
@import HealthKit;

@interface AAPLEnergyViewController()

@property (nonatomic, weak) IBOutlet UILabel *simulatedBurntEnergyValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *consumedEnergyValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *netEnergyValueLabel;

@property (nonatomic) double simulatedBurntEnergy;
@property (nonatomic) double consumedEnergy;
@property (nonatomic) double netEnergy;

@end

@implementation AAPLEnergyViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.refreshControl addTarget:self action:@selector(refreshStatistics) forControlEvents:UIControlEventValueChanged];
    
    [self refreshStatistics];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatistics) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - HealthKit APIs

- (void)refreshStatistics {
    [self.refreshControl beginRefreshing];

    [self fetchTotalJoulesConsumedWithCompletionHandler:^(double totalJoulesConsumed, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Simulate a random burnt amount of energy provided by another device, etc.
            self.simulatedBurntEnergy = arc4random_uniform(300000);
            
            self.consumedEnergy = totalJoulesConsumed;
            
            self.netEnergy = self.consumedEnergy - self.simulatedBurntEnergy;

            [self.refreshControl endRefreshing];
        });
    }];
}

- (void)fetchTotalJoulesConsumedWithCompletionHandler:(void (^)(double, NSError *))completionHandler {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSDate *now = [NSDate date];

    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    
    NSDate *startDate = [calendar dateFromComponents:components];

    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];

    HKQuantityType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCalories];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:sampleType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        if (completionHandler && error) {
            completionHandler(0.0f, error);
            return;
        }
        
        double totalCalories = [result.sumQuantity doubleValueForUnit:[HKUnit jouleUnit]];
        if (completionHandler) {
            completionHandler(totalCalories, error);
        }
    }];
    
    [self.healthStore executeQuery:query];
}

#pragma mark - NSEnergyFormatter

- (NSEnergyFormatter *)energyFormatter {
    static NSEnergyFormatter *energyFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        energyFormatter = [[NSEnergyFormatter alloc] init];
        energyFormatter.unitStyle = NSFormattingUnitStyleLong;
        energyFormatter.forFoodEnergyUse = YES;
        energyFormatter.numberFormatter.maximumFractionDigits = 2;
    });
    
    return energyFormatter;
}

#pragma mark - Setter Overrides

- (void)setSimulatedBurntEnergy:(double)simulatedBurntEnergy {
    _simulatedBurntEnergy = simulatedBurntEnergy;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.simulatedBurntEnergyValueLabel.text = [energyFormatter stringFromJoules:simulatedBurntEnergy];
}

- (void)setConsumedEnergy:(double)consumedEnergy {
    _consumedEnergy = consumedEnergy;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.consumedEnergyValueLabel.text = [energyFormatter stringFromJoules:consumedEnergy];
}

- (void)setNetEnergy:(double)netEnergy {
    _netEnergy = netEnergy;
    
    NSEnergyFormatter *energyFormatter = [self energyFormatter];
    self.netEnergyValueLabel.text = [energyFormatter stringFromJoules:netEnergy];
}

@end
# Fit: HealthKit in Action

===========================================================================
- read from NSDefautls
-- Convert Food to date/measurement in CD
- journal history.
- calc BMI
-- add a progress bar
===========================================================================

Fit is a sample intended as a quick introduction to HealthKit. It teaches you everything from writing data into HealthKit to reading data from HealthKit. This information may have been entered into the store by some other app; e.g. a user's birthday may have been entered into Health, and a user's weight by some popular weight tracker app.

Fit shows examples of using queries to retrieve information from HealthKit using sample queries and statistics queries. Fit gives you a quick introduction into using the new Foundation classes NSLengthFormatter, NSMassFormatter, and NSEnergyFormatter.

===========================================================================
Using the Sample

Fit tries to emulate a fitness tracker app. The goal of this fitness app is to track the net energy burn for a given day. Energy burn is defined in this app as:

    Total Active Energy Burned - Total Energy Consumed.

AAPLProfileViewController shows how to retrieve a user's age, height, and weight information from HealthKit. This is an example of retrieving a characteristic data type. Height and weight are quantity types, and you will learn how to retrieve these quantities from an HKHealthStore object using a sample query. You’ll also notice code to save valid user entered height and weight information into a HKHealthStore object.

AAPLJournalViewController tracks the user’s food consumption details for the day. You will find code that lets a user save food items into HealthKit, stored as instances of quantity samples. You will also see how to update the journal from HealthKit using a sample query.

AAPLEnergyViewController shows an example of using the statistics query. This sample uses a statistics query to retrieve the cumulative sum of calories of all the food samples entered using the AAPLJournalViewController.

===========================================================================
Build/Runtime Requirements

This sample requires capabilities that are only available when run on an iOS device.

Building this sample requires Xcode 6.0 and iOS 8.0 SDK
Running the sample requires iOS 8.0 or later.

To run the sample on a device, please create a valid AppID with HealthKit enabled, and generate the corresponding Provisioning Profile from the Dev Portal. Download and link Fit with this Provisioning Profile. Don't forget to change the Bundle Identifier and entitlements.plist to match the new AppId.

===========================================================================
Copyright (C) 2008-2014 Apple Inc. All rights reserved.

//
//  HealthyApp.swift
//  Healthy
//
//  Created by Shreya Prasad on 24/01/25.
//

import SwiftUI
import HealthKit
@main
struct HealthyApp: App {
    private let healthStore : HKHealthStore // creating the instance of healthStore
    init() {
        guard HKHealthStore.isHealthDataAvailable()// checking for the availabilty of data
                
        else {
            fatalError("Health data unavailable")
        }
        healthStore = HKHealthStore()
        requestHealthkitPermission()
    }
    private func requestHealthkitPermission(){
        let samplesTypesToRead = Set([
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
                       HKObjectType.quantityType(forIdentifier: .stepCount)!]
        )
        
        healthStore.requestAuthorization(toShare: nil, read: samplesTypesToRead){ success , error in
            print("Request authorization",success ,"Error",error ?? "nil")
           
            
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(healthStore)
        }
    }
}
extension HKHealthStore:@retroactive ObservableObject {}

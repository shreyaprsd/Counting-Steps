//
//  ContentView.swift
//  Healthy
//
//  Created by Shreya Prasad on 24/01/25.
//

import SwiftUI
import HealthKit
import Charts

//
struct StepsData : Identifiable {
    let id = UUID()
    let date : Date
    let steps : Double
}
struct ContentView: View {
    @State private var stepData : [StepsData] = []
    @State private var stepCount : Double = 0.0 // to store the step count
    @EnvironmentObject var healthStore : HKHealthStore // to pass the custom instance of healthStore to the view heirarchy
    
    var body: some View {
        VStack {
            Text("Total Steps:\(Int(stepCount))")
                .font(.title)
               //
                .padding()
            Chart(stepData){ data in
                BarMark(x: .value("Time", data.date,unit: .hour),
                        y:.value("Steps", data.steps) )
                
                
            }
            .padding()
        }
        .frame(height: 250)
      
        .onAppear(perform: {
         
            readTotalStepCount()
        })
        .padding()
        
    }
    private func get24hPredicate() ->  NSPredicate{
        let today = Date()
        let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: today)
        let predicate = HKQuery.predicateForSamples(withStart: startDate,end: today,options: [])
        return predicate
    } // this function creates the predicate to fetch steps data for  the last 24 hours
    func readTotalStepCount(){
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)
        else{
            fatalError("unable to fetch data for steps")
        }
        //
        // query is created to read the data (step count)
        let query = HKStatisticsQuery.init(quantityType: stepCountType, quantitySamplePredicate: get24hPredicate(),options: [HKStatisticsOptions.cumulativeSum,HKStatisticsOptions.separateBySource]) { query, results, error in
            // putting the the step in main thread to  show the step count data in the view
            DispatchQueue.main.async {
                self.stepCount = results?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            }
            }
        //executing the query in healthstore
        healthStore.execute(query)
        //
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
       
        let hourlyQuery = HKStatisticsCollectionQuery(quantityType: stepCountType, quantitySamplePredicate: nil,options:.cumulativeSum , anchorDate: now, intervalComponents: DateComponents(hour : 1))// construction of query for the charts data in hourly fashion
            
        hourlyQuery.initialResultsHandler = { query ,results,error in
            guard let results = results else {
                return
            }
            var hourlySteps : [StepsData] = [] // to store the data for the array
            results.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in
                let steps = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                    hourlySteps.append(StepsData(date: statistics.startDate, steps: steps)) //  appending the results in the hourlySteps array
            }
            DispatchQueue.main.async {
                self.stepData = hourlySteps // store the data to the stepData so that it can be used for the charts data
            }
        }
        healthStore.execute(hourlyQuery)
        
        
   }
}
#Preview {
    ContentView()
}

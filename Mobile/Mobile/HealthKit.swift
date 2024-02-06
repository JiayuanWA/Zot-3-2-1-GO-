import Foundation
import HealthKit


extension Date{
    
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}
class HealthKit: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var activities: [String : ActivityData] = [:]
    
    init() {
        let types: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .bloodType)!,
            HKObjectType.characteristicType(forIdentifier: .fitzpatrickSkinType)!,
            HKObjectType.characteristicType(forIdentifier: .wheelchairUse)!,
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
        
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: types)
            } catch {
                print("Error: HealthKit authorization")
            }
        }
    }
    
    func fetchSteps(){
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate){_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
            print("error fetching todays step")
            return
        }
            let stepCount = quantity.doubleValue(for: .count())
            let activity = ActivityData(id: 0, title: "Steps", subtitle: "Goal: 10,000", image: "figure.walk", amount: "\(stepCount)")
           
            self.activities["today Steps"] = activity
            print(stepCount)
        }
        
        healthStore.execute(query)
    }
    
    func fetchWalkingRunningDistance() {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error fetching walking+running distance")
                return
            }
            
            // Convert distance from meters to miles
            let distanceInMeters = quantity.doubleValue(for: .meter())
            let distanceInMiles = distanceInMeters / 1609.34  // 1 mile = 1609.34 meters
    

            let activity = ActivityData(id: 1, title: "Distance", subtitle: "Today's distance", image:"figure.walk.motion", amount: String(format: "%.2f", distanceInMiles) + " miles")
            self.activities["today Distance"] = activity
            print(distanceInMiles)
        }
        
        healthStore.execute(query)
    }

    //if exist
    func fetchSleepData() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let sleepSamples = results as? [HKCategorySample], error == nil else {
                print("Error fetching sleep data")
                return
            }
            
            let totalTimeInBed = sleepSamples.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            
            // Check if there is actual sleep data before updating the ActivityData
            if totalTimeInBed > 0 {
                let hours = totalTimeInBed / 3600
                let activity = ActivityData(id: 2, title: "Sleep", subtitle: "Total time in bed", image: "bed.double.circle", amount: String(format: "%.2f", hours) + " hours")
                self.activities["today Sleep"] = activity
                print(hours)
            }
        }
        
        healthStore.execute(query)
    }

    
    func fetchYesterdaySleepData() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        // Calculate the start and end dates for yesterday
        let yesterdayStart = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterdayEnd = Calendar.current.startOfDay(for: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: yesterdayStart, end: yesterdayEnd, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let sleepSamples = results as? [HKCategorySample], error == nil else {
                print("Error fetching yesterday's sleep data")
                return
            }
            
            let totalTimeInBed = sleepSamples.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            
            // Check if there is actual sleep data before updating the ActivityData
            if totalTimeInBed > 0 {
                let hours = totalTimeInBed / 3600
                let activity = ActivityData(id: 2, title: "Sleep", subtitle: "Total time in bed (Yesterday)", image: "bed.double.circle", amount: String(format: "%.2f", hours) + " hours")
                self.activities["yesterday Sleep"] = activity
                print(hours)
            }
        }
        
        healthStore.execute(query)
    }

}


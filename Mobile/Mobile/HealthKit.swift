import Foundation
import HealthKit


extension Date{
    
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents ([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 1
        return calendar.date(from: components)!
    }
        
        
}
class HealthKit: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var activities: [String : ActivityData] = [:]
    
    
    init() {
        let types: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
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
    
//    func fetchSteps(completion: @escaping (Double) -> Void) {
//        let steps = HKQuantityType(.stepCount)
//        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
//        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
//            guard let quantity = result?.sumQuantity(), error == nil else {
//                print("Error fetching today's step count")
//                completion(0.0) // Return 0 in case of an error
//                return
//            }
//            let stepCount = quantity.doubleValue(for: .count())
//            completion(stepCount)
//        }
//
//        healthStore.execute(query)
//    }

//    func fetchSteps(){
//            let steps = HKQuantityType(.stepCount)
//            let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
//            let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate){_, result, error in
//                guard let quantity = result?.sumQuantity(), error == nil else {
//                print("error fetching todays step")
//                return
//            }
//                let stepCount = quantity.doubleValue(for: .count())
//                let activity = ActivityData(id: 0, title: "Steps", subtitle: "Daily Step Count", image: "figure.walk", amount: "\(stepCount)")
//               
//                self.activities["today Steps"] = activity
//                print(stepCount)
//            }
//            
//            healthStore.execute(query)
//        }
    
    func fetchSteps(startDate: Date, endDate: Date) {
        let steps = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            if let error = error {
                print("Error fetching step count: \(error)")
                let activity = ActivityData(id: 0, title: "Steps", subtitle: "Daily Step Count", image: "figure.walk", amount: "0")
                self.activities["today Steps"] = activity
                return
            }

            guard let quantity = result?.sumQuantity() else {
                print("Error fetching step count. Result is nil.")
                return
            }

            let stepCount = quantity.doubleValue(for: .count())
            let activity = ActivityData(id: 0, title: "Steps", subtitle: "Daily Step Count", image: "figure.walk", amount: "\(stepCount)")

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
                let activity = ActivityData(id: 3, title: "Sleep", subtitle: "Total time in bed (Yesterday)", image: "bed.double.circle", amount: String(format: "%.2f", hours) + " hours")
                self.activities["yesterday Sleep"] = activity
                print(hours)
            }
        }
        
        healthStore.execute(query)
    }
    

    
    func fetchHeight() {
        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let predicate = HKQuery.predicateForSamples(withStart: .distantPast, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: heightType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, error in
            guard let heightSample = results?.first as? HKQuantitySample, error == nil else {
                print("Error fetching height")
                return
            }
            
            let heightValue = heightSample.quantity.doubleValue(for: HKUnit.meter())
            let activity = ActivityData(id: 4, title: "Height", subtitle: "Height Value", image: "ruler", amount: String(format: "%.2f", heightValue) + " meters")
            self.activities["height"] = activity
            print(heightValue)
        }
        
        healthStore.execute(query)
    }

    func fetchWeight() {
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let predicate = HKQuery.predicateForSamples(withStart: .distantPast, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: weightType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, error in
            guard let weightSample = results?.first as? HKQuantitySample, error == nil else {
                print("Error fetching weight")
                return
            }

            let weightValue = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            let activity = ActivityData(id: 5, title: "Weight", subtitle: "Weight Value", image: "scale.3d", amount: String(format: "%.2f", weightValue) + " kg")
            self.activities["weight"] = activity
            print(weightValue)
        }
        
        healthStore.execute(query)
    }
    
    func fetchWeeklyRunning() {
        let workout = HKSampleType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, workoutPredicate])
 
        let query = HKSampleQuery(sampleType: workout, predicate: predicate, limit: 25, sortDescriptors: nil) { _, sample, error in
            guard let workouts = sample as? [HKWorkout], error == nil else {
                print("error fetching week running data")
                return
            }
            var count: Int = 0
            for workout in workouts {
                let duration = Int(workout.duration)/60
                count += duration
            }
            let activity = ActivityData(id: 6, title: "Running", subtitle: "This week", image: "figure.walk",
                                    amount: "\(count) minutes")
            
            self.activities["RunTime"] = activity
            
        }
        healthStore.execute (query)
            
        }





}


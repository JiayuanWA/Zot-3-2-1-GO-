import Foundation
import HealthKit

class HealthKit: ObservableObject {
    
    let healthStore = HKHealthStore()
    
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
}

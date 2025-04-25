//
//  HealthManager.swift
//  StepQuestSwift
//
//  Created by Shirley Mazariegos on 4/7/25.
//

import Foundation
import HealthKit

@MainActor //tells xcode that class on runs on main thread
class HealthManager: ObservableObject {
    @Published var stepCount: Double = 0.0
    let healthStore = HKHealthStore()
    
    init () {
        let steps = HKQuantityType(.stepCount)
        let healthTypes: Set = [steps]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchStepCount()
            } catch {
                print("error fetching health data")
            }
        }
    }
    
    func fetchStepCount() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: startOfDay)!
        //need predicate to know what steps from which day it needs to fetch
        let predicate = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: now)

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let self = self else {
                print("HealthManager: self is nil.")
                return
            }

            if let error = error {
                print("HealthKit query error: \(error.localizedDescription)")
                return
            }

            guard let result = result, let sum = result.sumQuantity() else {
                print("HealthKit query returned no results.")
                return
            }

            // Explicitly hop to main actor
            Task { @MainActor in
                let steps = sum.doubleValue(for: .count())
                self.stepCount = steps
                print("Step count retrieved from HealthKit: \(steps)")

                // Attempt to update Firestore and confirm execution
                let userDataManager = UserDataManager()
                userDataManager.updateUserData(weeklyStepCount: Int(steps))
                print("Attempted to update user data in Firestore with step count: \(Int(steps))")
            }
        }
        
        healthStore.execute(query)
    }
}

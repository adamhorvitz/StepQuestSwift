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
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let self = self,
                  let result = result,
                  let sum = result.sumQuantity() else {
                print("Failed to fetch steps: \(error?.localizedDescription ?? "N/A")")
                return
            }

            // explicitly hop to main actor
            Task { @MainActor in
                self.stepCount = sum.doubleValue(for: .count())
            }
        }
        
        healthStore.execute(query)
    }
}

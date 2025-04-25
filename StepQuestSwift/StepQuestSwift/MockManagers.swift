//
//  MockManagers.swift
//  StepQuestSwift
//
//  Created by Cory White on 4/23/25.
//
import Foundation

class MockAuthManager: AuthManager {
    override init() {
        super.init()
        // No Firebase calls
    }
}

class MockHealthManager: HealthManager {
    override init() {
        super.init()
        self.stepCount = 12345
    }
}

class MockUserDataManager: UserDataManager {
    override init() {
        super.init()
        self.name = "TestUser"
        self.tier = "Gold"
        self.streak = 7
        self.weeklyGoal = 50000
    }
}

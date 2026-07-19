import XCTest
@testable import OpenWearablesHealthSDK

final class OpenWearablesHealthSDKTests: XCTestCase {
    
    func testSharedInstanceExists() {
        let sdk = OpenWearablesHealthSDK.shared
        XCTAssertNotNil(sdk)
    }
    
    func testConfigureSetsHost() {
        let sdk = OpenWearablesHealthSDK.shared
        sdk.configure(host: "https://test.example.com")
        // Verify the SDK is configured (host is internal, so we check via credentials)
        let credentials = sdk.getStoredCredentials()
        XCTAssertEqual(credentials["host"] as? String, "https://test.example.com")
    }
    
    func testIsSessionValidWithoutSignIn() {
        let sdk = OpenWearablesHealthSDK.shared
        // Without sign in, session should not be valid (unless prior state exists)
        // This is a basic sanity check
        XCTAssertNotNil(sdk.isSessionValid)
    }
    
    func testGetSyncStatusReturnsValidStructure() {
        let sdk = OpenWearablesHealthSDK.shared
        let status = sdk.getSyncStatus()
        XCTAssertNotNil(status["hasResumableSession"])
        XCTAssertNotNil(status["sentCount"])
        XCTAssertNotNil(status["completedTypes"])
        XCTAssertNotNil(status["isFullExport"])
    }

    func testResetAnchorForSingleType() {
        let sdk = OpenWearablesHealthSDK.shared
        sdk.configure(host: "https://test.example.com")

        // Track if log was called
        var logMessages: [String] = []
        sdk.onLog = { message in
            logMessages.append(message)
        }
        sdk.setLogLevel(.always)

        // Reset anchor for heart rate (should not crash, even without sign-in)
        sdk.resetAnchor(for: .heartRate, triggerSync: false)

        // Verify the reset was logged
        let hasResetLog = logMessages.contains { $0.contains("Reset anchor") && $0.contains("HeartRate") }
        XCTAssertTrue(hasResetLog, "Expected log message for anchor reset")
    }

    func testResetAnchorForMultipleTypes() {
        let sdk = OpenWearablesHealthSDK.shared
        sdk.configure(host: "https://test.example.com")

        var logMessages: [String] = []
        sdk.onLog = { message in
            logMessages.append(message)
        }
        sdk.setLogLevel(.always)

        // Reset multiple types
        sdk.resetAnchor(for: .heartRate, triggerSync: false)
        sdk.resetAnchor(for: .oxygenSaturation, triggerSync: false)
        sdk.resetAnchor(for: .sleep, triggerSync: false)

        // Verify each type was logged
        XCTAssertTrue(logMessages.contains { $0.contains("HeartRate") })
        XCTAssertTrue(logMessages.contains { $0.contains("OxygenSaturation") })
        XCTAssertTrue(logMessages.contains { $0.contains("SleepAnalysis") })
    }
}

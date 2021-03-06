//
//  RoverTests.swift
//  Rover
//
//  Created by Sean Rucker on 2016-12-05.
//  Copyright © 2016 Sean Rucker. All rights reserved.
//

import XCTest
@testable import Rover

class RoverTests: XCTestCase {
    
    func identifyAsMarie() {
        let traits = Traits()
        traits.set(identifier: "marieavgeropoulos")
        traits.set(firstName: "Marie")
        traits.set(lastName: "Avgeropoulos")
        traits.set(email: "marie.avgeropoulos@example.com")
        traits.set(gender: .female)
        traits.set(age: 30)
        traits.set(phoneNumber: "555-555-5555")
        traits.set(tags: ["actress", "model"])
        
        Rover.identify(traits: traits)
    }
    
    func testIdentify() {
        let customer = Rover.customer

        // Can't test for nil because its impossible to reset NSUserDefaults with the
        // current implementation.
        // http://stackoverflow.com/questions/19084633/shouldnt-nsuserdefault-be-clean-slate-for-unit-tests
        
//        XCTAssertNil(customer.identifier)
//        XCTAssertNil(customer.firstName)
//        XCTAssertNil(customer.lastName)
//        XCTAssertNil(customer.email)
//        XCTAssertNil(customer.gender)
//        XCTAssertNil(customer.age)
//        XCTAssertNil(customer.phone)
//        XCTAssertNil(customer.tags)
        
        identifyAsMarie()
        
        XCTAssertEqual(customer.identifier, "marieavgeropoulos")
        XCTAssertEqual(customer.firstName, "Marie")
        XCTAssertEqual(customer.lastName, "Avgeropoulos")
        XCTAssertEqual(customer.gender, Traits.Gender.female.rawValue)
        XCTAssertEqual(customer.age, 30)
        XCTAssertEqual(customer.email, "marie.avgeropoulos@example.com")
        XCTAssertEqual(customer.phone, "555-555-5555")
        XCTAssertEqual(customer.tags!, ["actress", "model"])

        var traits = Traits()
        traits.add(tag: "musician")
        traits.remove(tag: "actress")
        
        Rover.identify(traits: traits)
        XCTAssertEqual(customer.tags!, ["model", "musician"])
        
        traits = Traits()
        traits.set(customValue: "bar", forKey: "foo")
        
        Rover.identify(traits: traits)
        XCTAssertEqual(customer.traits["foo"] as? String, "bar")
    }
    
    func testClearCustomer() {
        identifyAsMarie()
        
        Rover.clearCustomer()
        
        let customer = Rover.customer
        
        XCTAssertNil(customer.identifier)
        XCTAssertNil(customer.firstName)
        XCTAssertNil(customer.lastName)
        XCTAssertNil(customer.email)
        XCTAssertNil(customer.gender)
        XCTAssertNil(customer.age)
        XCTAssertNil(customer.phone)
        XCTAssertNil(customer.tags)
    }
    
    func testContinueUserActivity() {
        let validActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        validActivity.webpageURL = URL(string: "https://inbox.rvr.co/foo")
        XCTAssert(Rover.continueUserActivity(validActivity), "Failed to continue valid user activity")
        
        let wrongActivityType = NSUserActivity(activityType: "io.rover.invalid")
        XCTAssert(!Rover.continueUserActivity(wrongActivityType), "Continued user activity of invalid activityType")
        
        let invalidURL = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        invalidURL.webpageURL = URL(string: "http://www.example.com/foo")!
        XCTAssert(!Rover.continueUserActivity(invalidURL), "Continued user activity with invalid webpageURL")
    }
    
    func testOpenURL() {
        let valid: [URL] = [
            URL(string: "https://inbox.rvr.co/foo")!,
            URL(string: "https://inbox.rover.io/foo?version=current")!,
            URL(string: "http://mlse.rvr.co/foo")!,
            URL(string: "https://carrot-rewards.rover.io/foo/bar")!,
            URL(string: "https://CarrotRewards.rvr.co/foo/bar")!
        ]
        
        let invalid: [URL] = [
            URL(string: "https://rvr.co/foo")!,
            URL(string: "https://inbox.rover.io/")!,
            URL(string: "https://inbox.rover.io")!,
            URL(string: "https://inbox.rover.com/foo")!
        ]
        
        for url in valid {
            let didOpenURL = Rover.open(url: url)
            XCTAssert(didOpenURL, "Failed to open valid URL: \(url)")
        }
        
        for url in invalid {
            let didOpenURL = Rover.open(url: url)
            XCTAssert(!didOpenURL, "Opened invalid URL: \(url)")
        }
    }
}

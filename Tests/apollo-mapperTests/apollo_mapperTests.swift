import XCTest
@testable import apollo_mapper

class MyStorage: MapperStorage {
    var count = 0
    func save(object: Mappable) throws {
        if count != 0 {
            throw MappingError.customTransformationError
        }
        count += 1
    }
}

class apollo_mapperTests: XCTestCase {
    
    var jsonData: [[String : Any?]] = [
        [
            "id": "1",
            "car_name": "Car 1",
            "number": "FG356",
            "model": ["name": "M3"],
            "users": [["name": "John"]],
            "last_use": "10-10-2017"
        ],[
            "id": "2",
            "car_name": "Car 2",
            "number": "FF335",
            "model": ["name": "M5"],
            "users": [],
            "last_use": nil
        ],[
            "id": "3",
            "car_name": "Car 3",
            "number": "DF832",
            "model": ["name": nil],
            "users": [["name": "George"]],
            "last_use": "01-01-2018"
        ],[
            "id": "3",
            "car_name": "Car 3",
            "number": "DF832",
            "model": ["name": "M6"],
            "users": [["name": "George"]],
            "last_use": 10
        ]
    ]
    
    func testUseExemple()  {
        let data : [String : Any?] = [
            "id": "1",
            "car_name": "Car 1",
            "number": "FG356",
            "model": ["name": "M3"],
            "users": [["name": "John"]],
            "last_use": "10-10-2017"
        ]
        let car = try! Car(snapshot: data)
        print(car.id, car.name, car.number, car.model, car.user, car.lastUse)
        // 1 Optional("Car 1") Optional("FG356") M3 Optional("John") Optional(2017-10-09 21:00:00 +0000)
        
        do {
            let data = jsonData[0]
            let car = try Car(snapshot: data)
            let result = car.id == 1 && car.name == "Car 1" && car.number == "FG356" && car.model == "M3" && car.user == "John" && car.lastUse != nil
            XCTAssert(result, "testUseExemple mapping error")
        } catch let error {
            XCTFail("testUseExemple mapping error - \(error)")
        }
        
        do {
            let data = jsonData[1]
            let car = try Car(snapshot: data)
            let result = car.id == 2 && car.name == "Car 2" && car.number == "FF335" && car.model == "M5" && car.user == nil && car.lastUse == nil
            XCTAssert(result, "testUseExemple mapping error")
        } catch let error {
            XCTFail("testUseExemple mapping error - \(error)")
        }
    }
    
    func testTransformTypes() {
        XCTAssert(try! TransformTypes.stringToInt("10") == 10, "TransformTypes 1 error")
        do {
            _ = try TransformTypes.stringToInt(10)
            XCTFail("TransformTypes 2 error")
        } catch {
            XCTAssert(true)
        }
        do {
            _ = try TransformTypes.stringToInt("a")
            XCTFail("TransformTypes 3 error")
        } catch {
            XCTAssert(true)
        }
    }
    
    func testMapperValue() {
        let mapper = Mapper(snapshot: self.jsonData[0])
        let mapper1 = Mapper(snapshot: self.jsonData[1])
        let mapper2 = Mapper(snapshot: self.jsonData[2])

        let number: String = try! mapper.value(key: "number")
        XCTAssert(number == "FG356", "testMapperValue 1 error")
        
        let modelName: String? = try! mapper2.value(key: "model.name")
        XCTAssert(modelName == nil, "testMapperValue 2 error")
        
        do {
            let noKey: String = try mapper1.value(key: "")
            XCTFail("testMapperValue 3 error \(noKey)")
        } catch {
            XCTAssert(true)
        }

        let noKeyOptional: String? = try? mapper1.value(key: "")
        XCTAssert(noKeyOptional == nil, "testMapperValue 4 error")
        
        let user: String? = try? mapper.value(key: "users.0.name")
        XCTAssert(user == "John", "testMapperValue 5 error")
        
        do {
            let user: [String : String] = try mapper.value(key: "users.0")
            XCTAssert(user == ["name": "John"], "testMapperValue 6 error")
        } catch {
            XCTFail("testMapperValue 7 error")
        }
        
        do {
            let mapper = Mapper(snapshot: ["some" : [[["some"]]]])
            let some: String = try mapper.value(key: "some.0.0.0")
            XCTAssert(some == "some", "testMapperValue 8 error")
        } catch {
            XCTFail("testMapperValue 9 error")
        }
        
        do {
            let last_use: String = try mapper1.value(key: "last_use")
            XCTFail("testMapperValue 10 error \(last_use)")
        } catch {
            XCTAssert(true)
        }
        
        do {
            let last_use: Int = try mapper.value(key: "last_use")
            XCTFail("testMapperValue 11 error \(last_use)")
        } catch {
            XCTAssert(true)
        }
        
        do {
            let last_use: Int? = try mapper.value(key: "last_use")
            XCTFail("testMapperValue 12 error \(last_use ?? 0)")
        } catch {
            XCTAssert(true)
        }
        
        do {
            let last_use: Int? = try mapper.value(key: "last_use", transformType: { (value) -> Int in
                return 10
            })
            XCTAssert(last_use == 10, "testMapperValue 13 error")
        } catch {
            XCTFail("testMapperValue 13 error")
        }
        
        do {
            let last_use: Int? = try mapper.value(key: "last_use", transformType: { (value) -> Int? in
                return 10
            })
            XCTAssert(last_use == 10, "testMapperValue 14 error")
        } catch {
            XCTFail("testMapperValue 14 error")
        }
        
        do {
            let mapper = Mapper(snapshot: ["some" : [[["some"]]]])
            let some: String = try mapper.value(key: "some.0.some.0")
            XCTFail("testMapperValue 15 error \(some)")
        } catch {
            XCTAssert(true)
        }
        
        do {
            let last_use: Int? = try mapper.value(key: "last_use", transformOptionalType: { (value) -> Int in
                return 10
            })
            XCTAssert(last_use == 10, "testMapperValue 16 error")
        } catch {
            XCTFail("testMapperValue 16 error")
        }
        
        do {
            let last_use: Int? = try mapper.value(key: "last_use", transformOptionalType: { (value) -> Int? in
                return 10
            })
            XCTAssert(last_use == 10, "testMapperValue 16 error")
        } catch {
            XCTFail("testMapperValue 16 error")
        }
        
        do {
            let last_use: Int = try mapper1.value(key: "last_use", transformType: { (value) -> Int in
                return 10
            })
            XCTFail("testMapperValue 17 error \(last_use)")
        } catch {
            XCTAssert(true)
        }

        do {
            let last_use: Int? = try mapper1.value(key: "last_use", transformType: { (value) -> Int? in
                return 10
            })
            XCTFail("testMapperValue 17 error \(last_use ?? 0)")
        } catch {
            XCTAssert(true)
        }
        
        do {
            _ = try Mapper.valueFor(ArraySlice([]), array: [])
            XCTFail("testMapperValue 18 error")
        } catch {
            XCTAssert(true)
        }
        
        do {
            _ = try Mapper.valueFor(ArraySlice([]), dictionary: [:])
            XCTFail("testMapperValue 19 error")
        } catch {
            XCTAssert(true)
        }
    }
    
    func testCarsMapping() {
        do {
            _ = try Car(snapshot: self.jsonData[0])
            _ = try Car(snapshot: self.jsonData[1])
            XCTAssert(true)
        } catch {
            XCTFail("testCarsMapping 1 error")
        }
        
        do {
            _ = try Car(snapshot: self.jsonData[2])
            XCTFail("testCarsMapping 2 error")
        } catch {
            XCTAssert(true)
        }
        
        XCTAssert(Car.map([self.jsonData[3]]).count == 0, "testCarsMapping 3 error")
        
        let count = Car.map(self.jsonData, store: MyStorage(), exeption: { (_, _) in
            
        }) { (_) in
            
        }.count
        
        XCTAssert(count == 1, "testCarsMapping 4 error")
        
        var errorCount = 0
        Mapper.mapToStorage(Car.self, snapshots: self.jsonData, store: MyStorage()) { (_, _) in
            errorCount += 1
        }
        
        XCTAssert(errorCount == 3, "testCarsMapping 4 error")
        
        let count1 = BrokenCar.map([self.jsonData[0]], store: MyStorage(), exeption: { (_, _) in }) { (_) in }.count
        XCTAssert(count1 == 0, "testCarsMapping 5 error")
        
        var errorCount2 = 0
        Mapper.mapToStorage(BrokenCar.self, snapshots: self.jsonData, store: MyStorage()) { (_, _) in
            errorCount2 += 1
        }
        
        XCTAssert(errorCount2 == 4, "testCarsMapping 6 error")
    }
    
    static var allTests = [
        ("testTransformTypes", testTransformTypes),
        ("testMapperValue", testMapperValue),
        ("testCarsMapping", testCarsMapping),
        ("testUseExemple", testUseExemple)
    ]
}

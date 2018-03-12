# apollo-mapper
Library for mapping swift apollo snapshots to your own class, also you can use it for another different mappings

| | **State** |
| :---: | :---: |
| **Tests** | [![Build Status](https://travis-ci.org/Lumyk/apollo-mapper.svg?branch=master)](https://travis-ci.org/Lumyk/apollo-mapper) |
| **Coverage** | [![codecov](https://codecov.io/gh/Lumyk/apollo-mapper/branch/master/graph/badge.svg)](https://codecov.io/gh/Lumyk/apollo-mapper) |

## Exemple

#### GraphQL
```
query cars {
    cars: getCars {
        id
        number
        car_name
        model {
            name
        }
        users {
            name
        }
    }
}
```
#### Class

```
class Car: Mappable {

    var id: Int
    var name: String?
    var number: String?
    var model: String
    var user: String?
    var lastUse: Date?

    required init(mapper: Mapper) throws {
        self.id = try mapper.value(key: "id", transformType: TransformTypes.stringToInt)
        self.name = try mapper.value(key: "car_name")
        self.number = try mapper.value(key: "number")
        self.model = try mapper.value(key: "model.name")
        self.user = try? mapper.value(key: "users.0.name")
        self.lastUse = try mapper.value(key: "last_use", transformOptionalType: { (value) -> Date? in
            guard let value = value else {
                return nil
            }
            if let value = value as? String {
                let df = DateFormatter()
                df.dateFormat = "dd-MM-yyyy"
                return df.date(from: value)
            } else {
                throw MappingError.customTransformationError
            }
        })
    }
}
```

### Using
```
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
```

## Installation

### CocoaPods
```
pod 'apollo-mapper', :git => 'https://github.com/lumyk/apollo-mapper.git'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Alamofire does support its use on supported platforms.

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

#### Swift 3

```swift
dependencies: [
    .Package(url: "https://github.com/lumyk/apollo-mapper.git", majorVersion: 0)
]
```

#### Swift 4

```swift
dependencies: [
    .package(url: "https://github.com/lumyk/apollo-mapper.git", from: "0.0.1")
]
```

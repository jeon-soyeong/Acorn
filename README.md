# Acorn  <img width="30" alt="앱아이콘" src="https://user-images.githubusercontent.com/61855905/190849761-e50c7785-3b92-48f0-9072-cff618def3ae.png"> 

![Language](https://img.shields.io/badge/swift-5.0-orange)
![Platform](https://img.shields.io/badge/platform-ios-lightgray)
![Lisence](https://img.shields.io/badge/license-MIT-green)
<br/><br/>
Acorn helps to download and cache Image.<br/>

## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 13.0+

## Installation
Acorn is available through CocoaPods. To install it, simply add the following line to your Podfile:
```Ruby
Pod 'Acorn'
```

## Usage
```Swift
imageView.setImage(with: url)
```
<br/>

- Placeholder
```Swift
imageView.setImage(with: url, placeholder: UIImage(named: "placeholderImage")
```
<br/>

- Configuration<br/> 
  - maximumMemoryBytes
  - maximumDiskBytes
  - expiration: seconds, days, date
```Swift
AcornManager.shared.configureCache(maximumMemoryBytes: 10485760, maximumDiskBytes: 10485760, expiration: .days(7))
```

## Author
So Yeong Jeon,  jsu3417@gmail.com

## License
Acorn is available under the MIT license. See the LICENSE file for more info.

import PackageDescription

let package = Package(
    name: "SPARQLclient",
    dependencies: [
//      .Package(url: "https://github.com/Zewo/JSON.git", majorVersion: 0, minor: 6),
      .Package(url: "https://github.com/Zewo/HTTPClient.git", majorVersion: 0, minor: 14),
//      .Package(url: "https://github.com/crossroadlabs/Regex.git", majorVersion: 0)
    ]
)

// Generated automatically by Perfect Assistant Application
// Date: 2017-12-24 06:06:22 +0000
import PackageDescription
let package = Package(
    name: "demo_server",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 3),
        .Package(url: "https://github.com/SwiftORM/Postgres-StORM.git", majorVersion: 3),
        .Package(url:"https://github.com/PerfectlySoft/Perfect-Notifications.git", majorVersion: 3)
        ]
)


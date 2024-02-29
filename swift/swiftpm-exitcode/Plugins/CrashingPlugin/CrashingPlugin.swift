import PackagePlugin

// To return error, run with:
// swift package crash
// To return zero exit code, run with some arugment:
// swift package crash xxx

@main struct CrashingPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        if arguments.count == 0 {
            throw MyError.pluginCrashed
        }
    }

    enum MyError: Int32, Error {
        case successs = 0
        case pluginCrashed = 555
    }
}


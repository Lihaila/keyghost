import AppKit
import Carbon
import Foundation

let appVersion = "0.2.0"
let defaultConfigPath = ("~/.config/keyghost/config.json" as NSString).expandingTildeInPath

struct Config: Codable {
    var targetInputSource: String?
    var excludedApps: [String]?
    var switchOnWake: Bool?
}

struct Options {
    var targetInputSourceOverride: String?
    var configPath: String = defaultConfigPath
    var verbose: Bool = false
    var listOnly: Bool = false
    var showHelp: Bool = false
    var showVersion: Bool = false
}

func parseArgs(_ args: [String]) -> Options {
    var opts = Options()
    var i = 1
    while i < args.count {
        switch args[i] {
        case "-l", "--list":
            opts.listOnly = true
        case "-v", "--verbose":
            opts.verbose = true
        case "-h", "--help":
            opts.showHelp = true
        case "--version":
            opts.showVersion = true
        case "-i", "--input-source":
            if i + 1 < args.count {
                opts.targetInputSourceOverride = args[i + 1]
                i += 1
            }
        case "-c", "--config":
            if i + 1 < args.count {
                opts.configPath = (args[i + 1] as NSString).expandingTildeInPath
                i += 1
            }
        default:
            fputs("Unknown argument: \(args[i])\n", stderr)
            opts.showHelp = true
        }
        i += 1
    }
    return opts
}

func printHelp() {
    print("""
    KeyGhost \(appVersion)
    Invisible macOS background ghost that switches your input source back to English whenever you switch apps.

    USAGE:
      keyghost [OPTIONS]

    OPTIONS:
      -l, --list                 List all enabled keyboard input source IDs and exit
      -i, --input-source <ID>    Target input source ID (default: auto-detect ABC or U.S.)
      -c, --config <PATH>        Path to JSON config file (default: ~/.config/keyghost/config.json)
      -v, --verbose              Print logs when switching apps/input sources
          --version              Show version
      -h, --help                 Show this help message
    """)
}

func getEnabledKeyboardSources() -> [(id: String, name: String)] {
    let filter = [
        kTISPropertyInputSourceCategory as String: kTISCategoryKeyboardInputSource as String,
        kTISPropertyInputSourceIsSelectCapable as String: true
    ] as CFDictionary

    guard let list = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource] else {
        return []
    }

    var result: [(String, String)] = []
    for src in list {
        guard let rawID = TISGetInputSourceProperty(src, kTISPropertyInputSourceID) else { continue }
        let id = Unmanaged<CFString>.fromOpaque(rawID).takeUnretainedValue() as String
        var name = id
        if let rawName = TISGetInputSourceProperty(src, kTISPropertyLocalizedName) {
            name = Unmanaged<CFString>.fromOpaque(rawName).takeUnretainedValue() as String
        }
        result.append((id, name))
    }
    return result
}

func resolveDefaultTargetInputSource() -> String {
    let enabled = Set(getEnabledKeyboardSources().map { $0.id })
    let preferred = [
        "com.apple.keylayout.ABC",
        "com.apple.keylayout.US",
        "com.apple.keylayout.British"
    ]
    for candidate in preferred where enabled.contains(candidate) {
        return candidate
    }
    return "com.apple.keylayout.ABC"
}

func currentInputSourceID() -> String? {
    guard let current = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
          let rawID = TISGetInputSourceProperty(current, kTISPropertyInputSourceID) else {
        return nil
    }
    return Unmanaged<CFString>.fromOpaque(rawID).takeUnretainedValue() as String
}

func selectInputSource(id: String) -> Bool {
    if currentInputSourceID() == id {
        return false
    }
    let filter = [kTISPropertyInputSourceID as String: id] as CFDictionary
    guard let list = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource],
          let target = list.first else {
        return false
    }
    return TISSelectInputSource(target) == noErr
}

final class AppSwitchDaemon: NSObject {
    private let options: Options
    private let fallbackTarget: String
    private var config: Config = Config()
    private var lastConfigMTime: Date?

    init(options: Options) {
        self.options = options
        self.fallbackTarget = resolveDefaultTargetInputSource()
        super.init()
        reloadConfigIfNeeded(force: true)
    }

    private func reloadConfigIfNeeded(force: Bool = false) {
        let fm = FileManager.default
        guard fm.fileExists(atPath: options.configPath) else {
            if lastConfigMTime != nil {
                config = Config()
                lastConfigMTime = nil
            }
            return
        }

        let attrs = try? fm.attributesOfItem(atPath: options.configPath)
        let mtime = attrs?[.modificationDate] as? Date
        if !force, let mtime = mtime, mtime == lastConfigMTime {
            return
        }

        if let data = fm.contents(atPath: options.configPath),
           let decoded = try? JSONDecoder().decode(Config.self, from: data) {
            config = decoded
            lastConfigMTime = mtime
            if options.verbose {
                print("[keyghost] Loaded config from \(options.configPath)")
            }
        }
    }

    private var effectiveTargetID: String {
        options.targetInputSourceOverride ?? config.targetInputSource ?? fallbackTarget
    }

    private var excludedBundleIDs: Set<String> {
        Set(config.excludedApps ?? [])
    }

    private var shouldSwitchOnWake: Bool {
        config.switchOnWake ?? true
    }

    func switchNow(reason: String) {
        reloadConfigIfNeeded()
        let target = effectiveTargetID
        let switched = selectInputSource(id: target)
        if options.verbose && switched {
            print("[keyghost] Switched to \(target) (\(reason))")
        }
    }

    @objc func handleActivate(_ notification: Notification) {
        reloadConfigIfNeeded()
        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           let bundleID = app.bundleIdentifier {
            if excludedBundleIDs.contains(bundleID) {
                if options.verbose {
                    print("[keyghost] Skipped excluded app: \(bundleID)")
                }
                return
            }
            switchNow(reason: "activated \(bundleID)")
        } else {
            switchNow(reason: "activated app")
        }
    }

    @objc func handleWake(_ notification: Notification) {
        reloadConfigIfNeeded()
        if shouldSwitchOnWake {
            switchNow(reason: "system wake")
        }
    }
}

let options = parseArgs(CommandLine.arguments)

if options.showVersion {
    print("KeyGhost \(appVersion)")
    exit(0)
}

if options.showHelp {
    printHelp()
    exit(0)
}

if options.listOnly {
    let sources = getEnabledKeyboardSources()
    let current = currentInputSourceID()
    for src in sources {
        let marker = (src.id == current) ? "*" : " "
        print("\(marker) \(src.id)  (\(src.name))")
    }
    exit(0)
}

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)

let daemon = AppSwitchDaemon(options: options)
let nc = NSWorkspace.shared.notificationCenter
nc.addObserver(
    daemon,
    selector: #selector(AppSwitchDaemon.handleActivate(_:)),
    name: NSWorkspace.didActivateApplicationNotification,
    object: nil
)
nc.addObserver(
    daemon,
    selector: #selector(AppSwitchDaemon.handleWake(_:)),
    name: NSWorkspace.didWakeNotification,
    object: nil
)

daemon.switchNow(reason: "startup")
app.run()

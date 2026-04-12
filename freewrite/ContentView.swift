// Swift 5.0
//
//  ContentView.swift
//  freewrite
//
//  Created by thorfinn on 2/14/25.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import PDFKit

enum EntryType {
    case text
    case video
}

struct HumanEntry: Identifiable {
    let id: UUID
    let date: String
    let filename: String
    var previewText: String
    var entryType: EntryType
    var videoFilename: String?

    static func createNew() -> HumanEntry {
        let id = UUID()
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = dateFormatter.string(from: now)

        // For display
        dateFormatter.dateFormat = "MMM d"
        let displayDate = dateFormatter.string(from: now)

        return HumanEntry(
            id: id,
            date: displayDate,
            filename: "[\(id)]-[\(dateString)].md",
            previewText: "",
            entryType: .text,
            videoFilename: nil
        )
    }

    static func createVideoEntry() -> HumanEntry {
        let id = UUID()
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = dateFormatter.string(from: now)

        // For display
        dateFormatter.dateFormat = "MMM d"
        let displayDate = dateFormatter.string(from: now)

        let videoFilename = "[\(id)]-[\(dateString)].mov"

        return HumanEntry(
            id: id,
            date: displayDate,
            filename: "[\(id)]-[\(dateString)].md",
            previewText: "Video Entry",
            entryType: .video,
            videoFilename: videoFilename
        )
    }
}

struct HeartEmoji: Identifiable {
    let id = UUID()
    var position: CGPoint
    var offset: CGFloat = 0
}

private struct AppThemeDefinition: Decodable {
    let name: String
    let isDarkTheme: Bool
    let background: String
    let backgroundFade: String
    let typeMain: String
    let typeSubtle: String
    let typeSubtlePlus: String
    let typeHighlight: String
    let typeLight: String
    let typeSuperlight: String
    let typeHyperLight: String
    let typeReverse: String
    let accent1Main: String
    let accent1Secondary: String
    let accent1Tertiary: String
    let accent2Main: String
    let accent2Secondary: String
    let accent3Main: String
    let accent3Secondary: String
    let accent4Main: String
    let accent4Secondary: String
    let accent5Main: String
    let accent5Secondary: String
    let gridSuperlight: String
    let gridClear: String
    let gridBold: String
}

struct AppTheme: Equatable, Identifiable {
    let id: String
    let name: String
    let isDarkTheme: Bool
    let background: Color
    let backgroundFade: Color
    let typeMain: Color
    let typeSubtle: Color
    let typeSubtlePlus: Color
    let typeHighlight: Color
    let typeLight: Color
    let typeSuperlight: Color
    let typeHyperLight: Color
    let typeReverse: Color
    let accent1Main: Color
    let accent1Secondary: Color
    let accent1Tertiary: Color
    let accent2Main: Color
    let accent2Secondary: Color
    let accent3Main: Color
    let accent3Secondary: Color
    let accent4Main: Color
    let accent4Secondary: Color
    let accent5Main: Color
    let accent5Secondary: Color
    let gridSuperlight: Color
    let gridClear: Color
    let gridBold: Color

    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool { lhs.id == rhs.id }

    private static func c(_ hex: String) -> Color {
        var s = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        if s.count == 6 { s += "FF" }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        return Color(
            red:     Double((v & 0xFF000000) >> 24) / 255.0,
            green:   Double((v & 0x00FF0000) >> 16) / 255.0,
            blue:    Double((v & 0x0000FF00) >> 8)  / 255.0,
            opacity: Double(v & 0x000000FF)          / 255.0
        )
    }

    private static let preferredOrder = [
        "vancouver", "a24", "agrabah", "demogorgon", "gundam-wing", "knight", "mononoke", "muaddib",
        "nord", "piccolo", "sanrio", "shadow-moses", "tartan", "tokyo-drift", "totoro", "vendetta"
    ]

    private static let fallbackTheme = AppTheme(
        id: "vancouver",
        name: "Vancouver",
        isDarkTheme: false,
        background: c("#FFFFFF"),
        backgroundFade: c("#ECECEC"),
        typeMain: c("#473F37"),
        typeSubtle: c("#1F4F79"),
        typeSubtlePlus: c("#085EA3"),
        typeHighlight: c("#FFEBCF"),
        typeLight: c("#B2B2B2"),
        typeSuperlight: c("#DAD9D7"),
        typeHyperLight: c("#F2F2F2"),
        typeReverse: c("#FFFFFF"),
        accent1Main: c("#0B486B"),
        accent1Secondary: c("#0F8C8C"),
        accent1Tertiary: c("#417863"),
        accent2Main: c("#C14DFB"),
        accent2Secondary: c("#C14DFB80"),
        accent3Main: c("#4DA425"),
        accent3Secondary: c("#3C7F1C"),
        accent4Main: c("#FF9E3C"),
        accent4Secondary: c("#CE741A"),
        accent5Main: c("#FF3B30"),
        accent5Secondary: c("#AC2E27"),
        gridSuperlight: c("#D9EEFACC"),
        gridClear: c("#CBE1EDCC"),
        gridBold: c("#ABCBDDCC")
    )

    static let all: [AppTheme] = loadAll()

    private static func makeTheme(id: String, definition: AppThemeDefinition) -> AppTheme {
        AppTheme(
            id: id,
            name: definition.name,
            isDarkTheme: definition.isDarkTheme,
            background: c(definition.background),
            backgroundFade: c(definition.backgroundFade),
            typeMain: c(definition.typeMain),
            typeSubtle: c(definition.typeSubtle),
            typeSubtlePlus: c(definition.typeSubtlePlus),
            typeHighlight: c(definition.typeHighlight),
            typeLight: c(definition.typeLight),
            typeSuperlight: c(definition.typeSuperlight),
            typeHyperLight: c(definition.typeHyperLight),
            typeReverse: c(definition.typeReverse),
            accent1Main: c(definition.accent1Main),
            accent1Secondary: c(definition.accent1Secondary),
            accent1Tertiary: c(definition.accent1Tertiary),
            accent2Main: c(definition.accent2Main),
            accent2Secondary: c(definition.accent2Secondary),
            accent3Main: c(definition.accent3Main),
            accent3Secondary: c(definition.accent3Secondary),
            accent4Main: c(definition.accent4Main),
            accent4Secondary: c(definition.accent4Secondary),
            accent5Main: c(definition.accent5Main),
            accent5Secondary: c(definition.accent5Secondary),
            gridSuperlight: c(definition.gridSuperlight),
            gridClear: c(definition.gridClear),
            gridBold: c(definition.gridBold)
        )
    }

    private static func loadAll() -> [AppTheme] {
        guard let resourceRoot = Bundle.main.resourceURL else {
            return [fallbackTheme]
        }

        let fileManager = FileManager.default
        let decoder = JSONDecoder()
        var themesByID: [String: AppTheme] = [:]

        if let enumerator = fileManager.enumerator(at: resourceRoot, includingPropertiesForKeys: nil) {
            for case let url as URL in enumerator where url.pathExtension == "json" {
                guard let data = try? Data(contentsOf: url),
                      let definition = try? decoder.decode(AppThemeDefinition.self, from: data) else {
                    continue
                }

                let id = url.deletingPathExtension().lastPathComponent
                themesByID[id] = makeTheme(id: id, definition: definition)
            }
        }

        if themesByID.isEmpty {
            return [fallbackTheme]
        }

        return themesByID.values.sorted { lhs, rhs in
            let lhsIndex = preferredOrder.firstIndex(of: lhs.id) ?? Int.max
            let rhsIndex = preferredOrder.firstIndex(of: rhs.id) ?? Int.max

            if lhsIndex == rhsIndex {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }

            return lhsIndex < rhsIndex
        }
    }

    static func find(id: String) -> AppTheme {
        all.first { $0.id == id } ?? all[0]
    }
}

struct ThemePickerRow: View {
    let theme: AppTheme
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.background)
                .frame(width: 26, height: 26)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(theme.gridClear.opacity(0.9), lineWidth: 1)
                )
                .overlay(
                    HStack(spacing: 3) {
                        Circle()
                            .fill(theme.typeSubtle)
                            .frame(width: 5, height: 5)

                        Circle()
                            .fill(theme.typeHighlight)
                            .frame(width: 5, height: 5)
                    }
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(theme.name)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.typeMain)

                Text(theme.isDarkTheme ? "Dark" : "Light")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(theme.typeLight)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(theme.typeSubtle)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(theme.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isSelected ? theme.typeSubtle.opacity(0.85) : theme.gridClear.opacity(0.35), lineWidth: isSelected ? 1.5 : 1)
        )
    }
}

struct ThemePickerView: View {
    @Binding var currentTheme: AppTheme
    @Binding var showingThemePicker: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Themes")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color(NSColor.labelColor))

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(AppTheme.all) { theme in
                        Button(action: {
                            currentTheme = theme
                            UserDefaults.standard.set(theme.id, forKey: "themeId")
                            showingThemePicker = false
                        }) {
                            ThemePickerRow(theme: theme, isSelected: theme == currentTheme)
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.never)
        }
        .padding(12)
        .frame(width: 250, height: 330)
    }
}

struct TextEditorThemeConfigurator: NSViewRepresentable {
    let theme: AppTheme

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            applyTheme(from: view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            applyTheme(from: nsView)
        }
    }

    private func applyTheme(from nsView: NSView) {
        guard let textView = nsView.superview?.findSubview(ofType: NSTextView.self)
            ?? nsView.window?.contentView?.findSubview(ofType: NSTextView.self) else {
            return
        }

        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.textColor = NSColor(theme.typeMain)
        textView.insertionPointColor = NSColor(theme.typeSubtle)
        textView.selectedTextAttributes = [
            .backgroundColor: NSColor(theme.typeHighlight),
            .foregroundColor: NSColor(theme.typeMain)
        ]

        // Walk every ancestor up to (but not including) the window content view,
        // clearing backgrounds and configuring the scroll view when found.
        var ancestor: NSView? = textView.superview
        while let v = ancestor, v !== nsView.window?.contentView {
            v.wantsLayer = true
            v.layer?.backgroundColor = CGColor.clear
            if let sv = v as? NSScrollView {
                sv.drawsBackground = false
                sv.backgroundColor = .clear
                sv.contentView.drawsBackground = false
                sv.contentView.backgroundColor = .clear
                sv.automaticallyAdjustsContentInsets = false
                // Provide visual top/bottom breathing room inside the scroll view
                // so the TextEditor can fill edge-to-edge without SwiftUI padding gaps.
                sv.contentInsets = NSEdgeInsets(top: 40, left: 0, bottom: 64, right: 0)
                sv.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            ancestor = v.superview
        }
    }
}

struct ContentView: View {
    private struct VideoPermissionPopoverItem: Identifiable {
        let id = UUID()
        let message: String
        let buttonLabel: String
        let settingsPane: String
    }

    @State private var entries: [HumanEntry] = []
    @State private var text: String = ""  // Remove initial welcome text since we'll handle it in createNewEntry
    
    @State private var isFullscreen = false
    @State private var currentTheme: AppTheme = AppTheme.all[0]
    @State private var showingThemePicker = false
    @State private var isHoveringThemePicker = false
    @State private var fontSize: CGFloat = 18
    @State private var timeRemaining: Int = 900  // Changed to 900 seconds (15 minutes)
    @State private var timerIsRunning = false
    @State private var isHoveringTimer = false
    @State private var isHoveringFullscreen = false
    @State private var blinkCount = 0
    @State private var isBlinking = false
    @State private var opacity: Double = 1.0
    @State private var lastClickTime: Date? = nil
    @State private var isHoveringBottomNav = false
    @State private var isHoveringFooterZone = false
    @State private var footerHoverLatch: Bool = false
    @State private var footerHideTask: DispatchWorkItem?
    @State private var selectedEntryIndex: Int = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedEntryId: UUID? = nil
    @State private var hoveredEntryId: UUID? = nil
    @State private var isHoveringChat = false  // Add this state variable
    @State private var showingChatMenu = false
    @State private var showingSidebar = false
    @State private var hoveredTrashId: UUID? = nil
    @State private var hoveredExportId: UUID? = nil
    @State private var placeholderText: String = ""  // Add this line
    @State private var isHoveringNewEntry = false
    @State private var isHoveringClock = false
    @State private var isHoveringHistory = false
    @State private var isHoveringCopyTranscript = false
    @State private var didCopyPrompt: Bool = false // Add state for copy prompt feedback
    @State private var didCopyTranscript: Bool = false
    @State private var selectedVideoHasTranscript = false
    @State private var backspaceDisabled = false // Add state for backspace toggle
    @State private var isHoveringBackspaceToggle = false // Add state for backspace toggle hover
    @State private var showingVideoRecording = false // Add state for video recording view
    @State private var isHoveringVideoButton = false // Add state for video button hover
    @State private var currentVideoURL: URL? = nil // Add state for current video being viewed
    @State private var isPreparingVideoRecording = false
    @State private var preparedCameraManager: CameraManager? = nil
    @State private var videoRecordingPreparationID: UUID? = nil
    @State private var showingVideoPermissionPopover = false
    @State private var videoPermissionPopoverItems: [VideoPermissionPopoverItem] = []
    @State private var videoPermissionPopoverFallbackMessage: String? = nil
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let entryHeight: CGFloat = 40
    
    let fontSizes: [CGFloat] = [16, 18, 20, 22, 24, 26]
    let placeholderOptions = [
        "Begin writing",
        "Pick a thought and go",
        "Start typing",
        "What's on your mind",
        "Just start",
        "Type your first thought",
        "Start with one sentence",
        "Just say it"
    ]
    
    private let fileManager = FileManager.default
    
    // Add cached documents directory
    private let documentsDirectory: URL = {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Freewrite")
        
        // Create Freewrite directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                print("Successfully created Freewrite directory")
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        
        return directory
    }()

    private let videosDirectory: URL = {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Freewrite")
            .appendingPathComponent("Videos")

        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                print("Successfully created Freewrite/Videos directory")
            } catch {
                print("Error creating videos directory: \(error)")
            }
        }

        return directory
    }()

    private let thumbnailMemoryCache: NSCache<NSString, NSImage> = {
        let cache = NSCache<NSString, NSImage>()
        cache.countLimit = 512
        return cache
    }()
    
    // Add shared prompt constant
    private let aiChatPrompt = """
    below is my journal entry. wyt? talk through it with me like a friend. don't therpaize me and give me a whole breakdown, don't repeat my thoughts with headings. really take all of this, and tell me back stuff truly as if you're an old homie.
    
    Keep it casual, dont say yo, help me make new connections i don't see, comfort, validate, challenge, all of it. dont be afraid to say a lot. format with markdown headings if needed.

    do not just go through every single thing i say, and say it back to me. you need to proccess everythikng is say, make connections i don't see it, and deliver it all back to me as a story that makes me feel what you think i wanna feel. thats what the best therapists do.

    ideally, you're style/tone should sound like the user themselves. it's as if the user is hearing their own tone but it should still feel different, because you have different things to say and don't just repeat back they say.

    else, start by saying, "hey, thanks for showing me this. my thoughts:"
        
    my entry:
    """
    
    private let claudePrompt = """
    Take a look at my journal entry below. I'd like you to analyze it and respond with deep insight that feels personal, not clinical.
    Imagine you're not just a friend, but a mentor who truly gets both my tech background and my psychological patterns. I want you to uncover the deeper meaning and emotional undercurrents behind my scattered thoughts.
    Keep it casual, dont say yo, help me make new connections i don't see, comfort, validate, challenge, all of it. dont be afraid to say a lot. format with markdown headings if needed.
    Use vivid metaphors and powerful imagery to help me see what I'm really building. Organize your thoughts with meaningful headings that create a narrative journey through my ideas.
    Don't just validate my thoughts - reframe them in a way that shows me what I'm really seeking beneath the surface. Go beyond the product concepts to the emotional core of what I'm trying to solve.
    Be willing to be profound and philosophical without sounding like you're giving therapy. I want someone who can see the patterns I can't see myself and articulate them in a way that feels like an epiphany.
    Start with 'hey, thanks for showing me this. my thoughts:' and then use markdown headings to structure your response.

    Here's my journal entry:
    """
    
    // Derived color scheme from theme
    var colorScheme: ColorScheme { currentTheme.isDarkTheme ? .dark : .light }
    // Fixed writing font matching Antinote's aesthetic
    var selectedFont: String { "Menlo" }

    init() {
        let savedThemeId = UserDefaults.standard.string(forKey: "themeId") ?? "vancouver"
        _currentTheme = State(initialValue: AppTheme.find(id: savedThemeId))
    }
    
    // Modify getDocumentsDirectory to use cached value
    private func getDocumentsDirectory() -> URL {
        return documentsDirectory
    }

    private func getVideosDirectory() -> URL {
        return videosDirectory
    }

    private func getVideoEntryDirectory(for videoFilename: String) -> URL {
        let baseName = (videoFilename as NSString).deletingPathExtension
        return getVideosDirectory().appendingPathComponent(baseName, isDirectory: true)
    }

    private func getManagedVideoURL(for filename: String) -> URL {
        getVideoEntryDirectory(for: filename).appendingPathComponent(filename)
    }

    private func getVideoThumbnailURL(for filename: String) -> URL {
        getVideoEntryDirectory(for: filename).appendingPathComponent("thumbnail.jpg")
    }

    private func getVideoTranscriptURL(for filename: String) -> URL {
        getVideoEntryDirectory(for: filename).appendingPathComponent("transcript.md")
    }

    @discardableResult
    private func ensureVideoEntryDirectoryExists(for videoFilename: String) throws -> URL {
        let directory = getVideoEntryDirectory(for: videoFilename)
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private func getVideoURL(for filename: String) -> URL {
        // Current production layout: Videos/[entry-base]/[entry-filename].mov
        let managedVideoURL = getManagedVideoURL(for: filename)
        if fileManager.fileExists(atPath: managedVideoURL.path) {
            return managedVideoURL
        }

        // Backward compatibility: older builds stored videos flat under Videos/
        let flatVideosURL = getVideosDirectory().appendingPathComponent(filename)
        if fileManager.fileExists(atPath: flatVideosURL.path) {
            return flatVideosURL
        }

        // Backward compatibility: oldest builds stored videos in root Freewrite folder
        let rootVideosURL = getDocumentsDirectory().appendingPathComponent(filename)
        if fileManager.fileExists(atPath: rootVideosURL.path) {
            return rootVideosURL
        }

        // Default to managed path for newly created entries.
        return managedVideoURL
    }

    private func hasVideoAsset(for filename: String) -> Bool {
        let managedVideoURL = getManagedVideoURL(for: filename)
        if fileManager.fileExists(atPath: managedVideoURL.path) {
            return true
        }

        let flatVideosURL = getVideosDirectory().appendingPathComponent(filename)
        if fileManager.fileExists(atPath: flatVideosURL.path) {
            return true
        }

        let rootVideosURL = getDocumentsDirectory().appendingPathComponent(filename)
        return fileManager.fileExists(atPath: rootVideosURL.path)
    }

    private let historyDebugEnabled = true

    private func historyDebug(_ message: String) {
        guard historyDebugEnabled else { return }
        print("[HistoryDebug] \(message)")
    }

    private func debugEntrySummary(_ entry: HumanEntry) -> String {
        let shortID = String(entry.id.uuidString.prefix(8))
        let type = entry.entryType == .video ? "video" : "text"
        let videoFilename = resolvedVideoFilename(for: entry) ?? "-"
        return "id=\(shortID) type=\(type) file=\(entry.filename) video=\(videoFilename)"
    }

    private func logEntriesOrder(_ reason: String, limit: Int = 20) {
        guard historyDebugEnabled else { return }
        historyDebug("ORDER SNAPSHOT (\(reason)) total=\(entries.count) selected=\(selectedEntryId?.uuidString ?? "nil")")
        for (index, entry) in entries.prefix(limit).enumerated() {
            historyDebug("#\(index + 1) \(debugEntrySummary(entry))")
        }
    }

    private func resolvedVideoFilename(for entry: HumanEntry) -> String? {
        guard entry.entryType == .video else {
            return nil
        }
        if let videoFilename = entry.videoFilename, !videoFilename.isEmpty {
            return videoFilename
        }
        return entry.filename.replacingOccurrences(of: ".md", with: ".mov")
    }

    private func persistThumbnail(_ image: NSImage, for videoFilename: String) {
        do {
            let directory = try ensureVideoEntryDirectoryExists(for: videoFilename)
            let thumbnailURL = directory.appendingPathComponent("thumbnail.jpg")
            guard let tiff = image.tiffRepresentation,
                  let bitmapRep = NSBitmapImageRep(data: tiff),
                  let imageData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.82]) else {
                print("Could not convert thumbnail image to JPEG data")
                return
            }
            try imageData.write(to: thumbnailURL, options: .atomic)
        } catch {
            print("Error saving thumbnail: \(error)")
        }
    }

    private func loadThumbnailImage(for videoFilename: String) -> NSImage? {
        let cacheKey = videoFilename as NSString
        if let cachedImage = thumbnailMemoryCache.object(forKey: cacheKey) {
            return cachedImage
        }

        let thumbnailURL = getVideoThumbnailURL(for: videoFilename)
        if fileManager.fileExists(atPath: thumbnailURL.path),
           let image = NSImage(contentsOf: thumbnailURL) {
            thumbnailMemoryCache.setObject(image, forKey: cacheKey)
            return image
        }

        // Backward compatibility: generate once for old video entries, then persist.
        let videoURL = getVideoURL(for: videoFilename)
        guard fileManager.fileExists(atPath: videoURL.path),
              let generated = generateVideoThumbnail(from: videoURL) else {
            historyDebug("THUMBNAIL MISS video=\(videoFilename) thumbnailPath=\(thumbnailURL.path) videoPath=\(videoURL.path)")
            return nil
        }
        persistThumbnail(generated, for: videoFilename)
        thumbnailMemoryCache.setObject(generated, forKey: cacheKey)
        historyDebug("THUMBNAIL GENERATED video=\(videoFilename) thumbnailPath=\(thumbnailURL.path)")
        return generated
    }

    private func deleteVideoAssets(for videoFilename: String) {
        thumbnailMemoryCache.removeObject(forKey: videoFilename as NSString)

        let managedDirectory = getVideoEntryDirectory(for: videoFilename)
        let managedVideoURL = managedDirectory.appendingPathComponent(videoFilename)
        let managedThumbnailURL = managedDirectory.appendingPathComponent("thumbnail.jpg")
        let managedTranscriptURL = managedDirectory.appendingPathComponent("transcript.md")
        let flatVideosURL = getVideosDirectory().appendingPathComponent(videoFilename)
        let rootVideosURL = getDocumentsDirectory().appendingPathComponent(videoFilename)

        let candidateURLs = [managedVideoURL, managedThumbnailURL, managedTranscriptURL, flatVideosURL, rootVideosURL]
        for url in candidateURLs where fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Error deleting video asset \(url.lastPathComponent): \(error)")
            }
        }

        if fileManager.fileExists(atPath: managedDirectory.path) {
            do {
                try fileManager.removeItem(at: managedDirectory)
            } catch {
                print("Error deleting video entry directory: \(error)")
            }
        }
    }

    private func loadTranscriptText(for videoFilename: String) -> String? {
        let transcriptURL = getVideoTranscriptURL(for: videoFilename)
        guard fileManager.fileExists(atPath: transcriptURL.path),
              let content = try? String(contentsOf: transcriptURL, encoding: .utf8) else {
            return nil
        }
        let cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }

    private func previewTextFromTranscript(_ transcript: String?) -> String {
        guard let transcript else {
            return "Video Entry"
        }

        let normalized = transcript
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else {
            return "Video Entry"
        }

        var preview = String(normalized.prefix(10))

        while let last = preview.last, (!last.isLetter && !last.isNumber) {
            preview.removeLast()
        }

        if preview.isEmpty {
            return "Video Entry"
        }

        return preview + "..."
    }

    private func videoPreviewText(for videoFilename: String) -> String {
        previewTextFromTranscript(loadTranscriptText(for: videoFilename))
    }

    private func copyTranscriptForSelectedVideoEntry() {
        guard let selectedEntryId,
              let selectedEntry = entries.first(where: { $0.id == selectedEntryId }),
              let videoFilename = resolvedVideoFilename(for: selectedEntry),
              let transcript = loadTranscriptText(for: videoFilename) else {
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(transcript, forType: .string)
        didCopyTranscript = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            didCopyTranscript = false
        }
    }
    
    private func parseCanonicalEntryFilename(_ filename: String) -> (uuid: UUID, timestamp: Date)? {
        guard filename.hasPrefix("["),
              filename.hasSuffix("].md"),
              let divider = filename.range(of: "]-[") else {
            return nil
        }

        let uuidStart = filename.index(after: filename.startIndex)
        let uuidString = String(filename[uuidStart..<divider.lowerBound])
        guard let uuid = UUID(uuidString: uuidString) else {
            return nil
        }

        let timestampStart = divider.upperBound
        let timestampEnd = filename.index(filename.endIndex, offsetBy: -4) // before ".md"
        let timestampString = String(filename[timestampStart..<timestampEnd])
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        guard let timestamp = formatter.date(from: timestampString) else {
            return nil
        }

        return (uuid: uuid, timestamp: timestamp)
    }
    
    private func isEntryNewer(_ lhs: HumanEntry, than rhs: HumanEntry) -> Bool {
        let lhsTimestamp = parseCanonicalEntryFilename(lhs.filename)?.timestamp ?? .distantPast
        let rhsTimestamp = parseCanonicalEntryFilename(rhs.filename)?.timestamp ?? .distantPast
        if lhsTimestamp == rhsTimestamp {
            return lhs.filename > rhs.filename
        }
        return lhsTimestamp > rhsTimestamp
    }
    
    private func isEntryFromToday(_ entry: HumanEntry, calendar: Calendar = .current, today: Date = Date()) -> Bool {
        guard let timestamp = parseCanonicalEntryFilename(entry.filename)?.timestamp else {
            return false
        }
        return calendar.isDate(timestamp, inSameDayAs: today)
    }
    
    // Add function to load existing entries
    private func loadExistingEntries() {
        let documentsDirectory = getDocumentsDirectory()
        print("Looking for entries in: \(documentsDirectory.path)")
        print("Looking for videos in: \(getVideosDirectory().path)")
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            let mdFiles = fileURLs.filter { $0.pathExtension == "md" }

            print("Found \(mdFiles.count) .md files")

            // Process each file
            let entriesWithDates = mdFiles.compactMap { fileURL -> (entry: HumanEntry, date: Date, content: String)? in
                let filename = fileURL.lastPathComponent
                print("Processing: \(filename)")

                // Only accept canonical entry filenames: [UUID]-[yyyy-MM-dd-HH-mm-ss].md
                guard let parsed = parseCanonicalEntryFilename(filename) else {
                    print("Skipping non-canonical entry filename: \(filename)")
                    return nil
                }
                let uuid = parsed.uuid
                let fileDate = parsed.timestamp

                // Check if there's a corresponding video file
                let videoFilename = filename.replacingOccurrences(of: ".md", with: ".mov")
                let hasVideo = hasVideoAsset(for: videoFilename)

                // Read file contents for preview
                do {
                    let content = try String(contentsOf: fileURL, encoding: .utf8)
                    let preview = content
                        .replacingOccurrences(of: "\n", with: " ")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let truncated = preview.isEmpty ? "" : (preview.count > 30 ? String(preview.prefix(30)) + "..." : preview)

                    // Format display date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d"
                    let displayDate = dateFormatter.string(from: fileDate)

                    return (
                        entry: HumanEntry(
                            id: uuid,
                            date: displayDate,
                            filename: filename,
                            previewText: hasVideo ? videoPreviewText(for: videoFilename) : truncated,
                            entryType: hasVideo ? .video : .text,
                            videoFilename: hasVideo ? videoFilename : nil
                        ),
                        date: fileDate,
                        content: content  // Store the full content to check for welcome message
                    )
                } catch {
                    print("Error reading file: \(error)")
                    return nil
                }
            }
            
            // Sort and extract entries - store in temporary variable
            let loadedEntries = entriesWithDates
                .sorted {
                    if $0.date == $1.date {
                        return $0.entry.filename > $1.entry.filename
                    }
                    return $0.date > $1.date
                }
                .map { $0.entry }

            print("Successfully loaded and sorted \(loadedEntries.count) entries")

            // Check if we need to create a new entry
            let calendar = Calendar.current
            let today = Date()
            let hasEntryToday = loadedEntries.contains { isEntryFromToday($0, calendar: calendar, today: today) }
            let hasEmptyTextEntryToday = loadedEntries.contains {
                isEntryFromToday($0, calendar: calendar, today: today) &&
                $0.entryType == .text &&
                $0.previewText.isEmpty
            }

            // Check if we have only one entry and it's the welcome message
            let hasOnlyWelcomeEntry = loadedEntries.count == 1 && entriesWithDates.first?.content.contains("Welcome to Freewrite.") == true

            // Now assign to the state variable
            entries = loadedEntries
            logEntriesOrder("loadExistingEntries")

            // Never open directly into video on startup; create a fresh text entry instead.
            if let latestEntry = entries.first, latestEntry.entryType == .video {
                print("Latest entry is video, creating new text entry for startup")
                createNewEntry()
                return
            }

            if entries.isEmpty {
                // First time user - create entry with welcome message
                print("First time user, creating welcome entry")
                createNewEntry()
            } else if !hasEntryToday && !hasOnlyWelcomeEntry {
                // No entries at all for today - create a new text entry
                print("No entry for today, creating new entry")
                createNewEntry()
            } else {
                // Prefer an empty text entry from today for writing continuity; otherwise pick latest entry.
                if hasEmptyTextEntryToday,
                   let todayEntry = entries.first(where: {
                       isEntryFromToday($0, calendar: calendar, today: today) &&
                       $0.entryType == .text &&
                       $0.previewText.isEmpty
                   }) {
                    selectedEntryId = todayEntry.id
                    loadEntry(entry: todayEntry)
                } else if hasOnlyWelcomeEntry {
                    // If we only have the welcome entry, select it
                    selectedEntryId = entries[0].id
                    loadEntry(entry: entries[0])
                } else if let latestEntry = entries.first {
                    selectedEntryId = latestEntry.id
                    loadEntry(entry: latestEntry)
                }
            }
            
        } catch {
            print("Error loading directory contents: \(error)")
            print("Creating default entry after error")
            createNewEntry()
        }
    }
    
    private func startVideoRecordingPreflight() {
        guard !isPreparingVideoRecording, !showingVideoRecording else {
            return
        }

        showingVideoPermissionPopover = false
        videoPermissionPopoverItems = []
        videoPermissionPopoverFallbackMessage = nil

        let preparationID = UUID()
        let manager = CameraManager()

        videoRecordingPreparationID = preparationID
        preparedCameraManager = manager

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isPreparingVideoRecording = true
        }

        manager.onReadyToRecord = { [weak manager] in
            guard let manager else { return }
            DispatchQueue.main.async {
                finishVideoRecordingPreflight(
                    preparationID: preparationID,
                    manager: manager,
                    presentationDelay: 0.5
                )
            }
        }

        manager.onCannotRecord = { [weak manager] in
            guard let manager else { return }
            DispatchQueue.main.async {
                guard self.videoRecordingPreparationID == preparationID else {
                    return
                }
                let payload = self.videoPermissionPopoverPayload(
                    cameraGranted: manager.permissionGranted,
                    microphoneGranted: manager.microphonePermissionGranted,
                    speechGranted: manager.speechPermissionGranted
                )
                self.videoPermissionPopoverItems = payload.items
                self.videoPermissionPopoverFallbackMessage = payload.fallbackMessage
                self.showingVideoPermissionPopover = true
                self.clearVideoRecordingPreparationState()
            }
        }

        manager.checkPermissions()
    }

    private func finishVideoRecordingPreflight(
        preparationID: UUID,
        manager: CameraManager,
        presentationDelay: TimeInterval = 0
    ) {
        let presentRecorder = {
            guard videoRecordingPreparationID == preparationID else {
                return
            }

            videoRecordingPreparationID = nil
            manager.onReadyToRecord = nil
            manager.onCannotRecord = nil
            preparedCameraManager = manager

            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                isPreparingVideoRecording = false
                showingVideoRecording = true
            }
        }

        if presentationDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + presentationDelay) {
                presentRecorder()
            }
        } else {
            presentRecorder()
        }
    }

    private func clearVideoRecordingPreparationState() {
        preparedCameraManager?.onReadyToRecord = nil
        preparedCameraManager?.onCannotRecord = nil
        videoRecordingPreparationID = nil
        isPreparingVideoRecording = false
        preparedCameraManager = nil
    }

    private func videoPermissionPopoverPayload(
        cameraGranted: Bool,
        microphoneGranted: Bool,
        speechGranted: Bool
    ) -> (items: [VideoPermissionPopoverItem], fallbackMessage: String?) {
        var items: [VideoPermissionPopoverItem] = []
        if !cameraGranted {
            items.append(
                VideoPermissionPopoverItem(
                    message: "Hey, we need camera permission.",
                    buttonLabel: "Open Camera Settings",
                    settingsPane: "Privacy_Camera"
                )
            )
        }
        if !microphoneGranted {
            items.append(
                VideoPermissionPopoverItem(
                    message: "Hey, we need microphone permission.",
                    buttonLabel: "Open Microphone Settings",
                    settingsPane: "Privacy_Microphone"
                )
            )
        }
        if !speechGranted {
            items.append(
                VideoPermissionPopoverItem(
                    message: "Hey, we need speech recognition permission.",
                    buttonLabel: "Open Speech Settings",
                    settingsPane: "Privacy_SpeechRecognition"
                )
            )
        }

        if items.isEmpty {
            return (
                items: [],
                fallbackMessage: "Could not prepare camera right now. Please try again."
            )
        }

        return (
            items: items,
            fallbackMessage: nil
        )
    }

    private func openVideoPermissionSettings(_ settingsPane: String) {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?\(settingsPane)") {
            NSWorkspace.shared.open(url)
        }
    }

    var timerButtonTitle: String {
        if !timerIsRunning && timeRemaining == 900 {
            return "15:00"
        }
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var timerColor: Color {
        return isHoveringTimer ? currentTheme.typeMain : currentTheme.typeLight
    }
    
    var lineHeight: CGFloat {
        let font = NSFont(name: selectedFont, size: fontSize) ?? .systemFont(ofSize: fontSize)
        let defaultLineHeight = getLineHeight(font: font)
        return (fontSize * 1.5) - defaultLineHeight
    }
    
    var fontSizeButtonTitle: String {
        return "\(Int(fontSize))px"
    }
    
    var popoverBackgroundColor: Color {
        return currentTheme.isDarkTheme ? currentTheme.backgroundFade : currentTheme.typeReverse
    }

    var popoverTextColor: Color {
        return currentTheme.typeMain
    }

    var isFooterTriggered: Bool {
        isHoveringBottomNav || isHoveringFooterZone || showingThemePicker || showingChatMenu || showingVideoPermissionPopover
    }

    var footerOpacity: Double {
        if showingVideoRecording { return 0 }
        return footerHoverLatch ? 1.0 : 0.0
    }

    var footerPanelFillColor: Color {
        currentTheme.typeReverse.opacity(currentTheme.isDarkTheme ? 0.04 : 0.16)
    }

    var footerPanelStrokeColor: Color {
        currentTheme.gridClear.opacity(currentTheme.isDarkTheme ? 0.28 : 0.55)
    }

    var footerButtonHoverFill: Color {
        currentTheme.isDarkTheme ? currentTheme.typeReverse.opacity(0.08) : currentTheme.typeReverse.opacity(0.42)
    }

    var footerButtonActiveFill: Color {
        currentTheme.isDarkTheme ? currentTheme.typeSubtlePlus.opacity(0.22) : currentTheme.typeHighlight.opacity(0.55)
    }

    var footerDividerColor: Color {
        currentTheme.typeLight.opacity(currentTheme.isDarkTheme ? 0.28 : 0.4)
    }

    var footerDivider: some View {
        Rectangle()
            .fill(footerDividerColor)
            .frame(width: 1, height: 14)
    }

    var textColor: Color { currentTheme.typeLight }
    var textHoverColor: Color { currentTheme.typeMain }
    var isViewingVideoEntry: Bool { currentVideoURL != nil }


    var body: some View {
        let navHeight: CGFloat = 64

        HStack(spacing: 0) {
            // Main content
            ZStack {
                currentTheme.background
                    .ignoresSafeArea()

                // Show video player if a video entry is selected
                if let videoURL = currentVideoURL {
                    VideoPlayerView(
                        videoURL: videoURL,
                        isPlaybackSuspended: isPreparingVideoRecording || showingVideoRecording
                    )
                        .id(videoURL.path)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(edges: .top)
                } else {
                    // Show text editor for text entries
                    TextEditor(text: $text)
                    .background(TextEditorThemeConfigurator(theme: currentTheme))
                    .font(.custom(selectedFont, size: fontSize))
                    .foregroundColor(currentTheme.typeMain)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.never)
                    .lineSpacing(lineHeight)
                    .frame(maxWidth: 650, maxHeight: .infinity)
                    .id("\(selectedFont)-\(fontSize)-\(colorScheme)")
                    .colorScheme(colorScheme)
                    .onAppear {
                        placeholderText = placeholderOptions.randomElement() ?? "Begin writing"
                        // Removed findSubview code which was causing errors

                        // Add keyboard monitor for backspace/delete keys
                        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                            // Check if backspace is disabled and the key is delete/backspace
                            if backspaceDisabled && (event.keyCode == 51 || event.keyCode == 117) {
                                // Block the backspace/delete key
                                return nil
                            }
                            return event
                        }
                    }
                    .overlay(
                        ZStack(alignment: .topLeading) {
                            if text.isEmpty {
                                Text(placeholderText)
                                    .font(.custom(selectedFont, size: fontSize))
                                    .foregroundColor(currentTheme.typeLight.opacity(0.72))
                                    .allowsHitTesting(false)
                                    .offset(x: 5, y: 40)
                            }
                        }, alignment: .topLeading
                    )
                }

                VStack(spacing: 0) {
                    Spacer()
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 26)
                            .contentShape(Rectangle())
                            .onHover { hovering in
                                withAnimation(hovering ? .easeOut(duration: 0.18) : .easeIn(duration: 0.35)) {
                                    isHoveringFooterZone = hovering
                                }
                            }

                        HStack(alignment: .bottom, spacing: 12) {
                            leftFooterGroup
                            Spacer()
                            rightFooterGroup
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 10)
                        .opacity(footerOpacity)
                        .allowsHitTesting(footerOpacity > 0.01)
                        .animation(.easeOut(duration: 0.18), value: footerOpacity)
                        .onChange(of: isFooterTriggered) { _, triggered in
                            footerHideTask?.cancel()
                            if triggered {
                                footerHoverLatch = true
                            } else {
                                let task = DispatchWorkItem {
                                    footerHoverLatch = false
                                }
                                footerHideTask = task
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: task)
                            }
                        }
                    }
                }
            }
            
            // Right sidebar
            if showingSidebar {
                Divider()
                
                VStack(spacing: 0) {
                    // Header
                    Button(action: {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: getDocumentsDirectory().path)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 4) {
                                    Text("History")
                                        .font(.system(size: 13))
                                        .foregroundColor(isHoveringHistory ? textHoverColor : textColor)
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10))
                                        .foregroundColor(isHoveringHistory ? textHoverColor : textColor)
                                }
                                Text(getDocumentsDirectory().path)
                                    .font(.system(size: 10))
                                    .foregroundColor(currentTheme.typeLight)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .onHover { hovering in
                        isHoveringHistory = hovering
                    }
                    
                    Divider()
                    
                    // Entries List
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(entries) { entry in
                                Button(action: {
                                    if selectedEntryId != entry.id {
                                        historyDebug("ROW TAP \(debugEntrySummary(entry))")
                                        // Save current entry before switching
                                        if let currentId = selectedEntryId,
                                           let currentEntry = entries.first(where: { $0.id == currentId }),
                                           currentEntry.entryType == .text {
                                            saveEntry(entry: currentEntry)
                                        }

                                        // Re-resolve from source of truth after any state mutations.
                                        guard let targetEntry = entries.first(where: { $0.id == entry.id }) else {
                                            historyDebug("ROW TAP target missing id=\(entry.id.uuidString)")
                                            return
                                        }
                                        selectedEntryId = targetEntry.id
                                        historyDebug("ROW TAP resolved target \(debugEntrySummary(targetEntry))")
                                        loadEntry(entry: targetEntry)
                                    }
                                }) {
                                    HStack(alignment: .top) {
                                        // Show video thumbnail for video entries
                                        if let videoFilename = resolvedVideoFilename(for: entry) {
                                            if let thumbnail = loadThumbnailImage(for: videoFilename) {
                                                Image(nsImage: thumbnail)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 40, height: 40)
                                                    .cornerRadius(4)
                                                    .overlay(
                                                        Image(systemName: "play.circle.fill")
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 16))
                                                    )
                                            } else {
                                                // Fallback if thumbnail generation fails
                                                ZStack {
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.3))
                                                        .frame(width: 40, height: 40)
                                                        .cornerRadius(4)
                                                    Image(systemName: "video.fill")
                                                        .foregroundColor(.gray)
                                                        .font(.system(size: 16))
                                                }
                                            }
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(entry.previewText)
                                                    .font(.system(size: 13))
                                                    .lineLimit(1)
                                                    .foregroundColor(currentTheme.typeMain)

                                                Spacer()
                                                
                                                // Export/Trash icons that appear on hover
                                                if hoveredEntryId == entry.id {
                                                    HStack(spacing: 8) {
                                                        // Export PDF button
                                                        Button(action: {
                                                            exportEntryAsPDF(entry: entry)
                                                        }) {
                                                            Image(systemName: "arrow.down.circle")
                                                                .font(.system(size: 11))
                                                                .foregroundColor(hoveredExportId == entry.id ? currentTheme.typeMain : currentTheme.typeLight)
                                                        }
                                                        .buttonStyle(.plain)
                                                        .help("Export entry as PDF")
                                                        .onHover { hovering in
                                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                                hoveredExportId = hovering ? entry.id : nil
                                                            }
                                                            if hovering {
                                                                NSCursor.pointingHand.push()
                                                            } else {
                                                                NSCursor.pop()
                                                            }
                                                        }
                                                        
                                                        // Trash icon
                                                        Button(action: {
                                                            deleteEntry(entry: entry)
                                                        }) {
                                                            Image(systemName: "trash")
                                                                .font(.system(size: 11))
                                                                .foregroundColor(hoveredTrashId == entry.id ? .red : .gray)
                                                        }
                                                        .buttonStyle(.plain)
                                                        .onHover { hovering in
                                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                                hoveredTrashId = hovering ? entry.id : nil
                                                            }
                                                            if hovering {
                                                                NSCursor.pointingHand.push()
                                                            } else {
                                                                NSCursor.pop()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            Text(entry.date)
                                                .font(.system(size: 12))
                                                .foregroundColor(currentTheme.typeLight)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(backgroundColor(for: entry))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(Rectangle())
                                .onHover { hovering in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        hoveredEntryId = hovering ? entry.id : nil
                                    }
                                }
                                .onAppear {
                                    NSCursor.pop()  // Reset cursor when button appears
                                }
                                .help("Click to select this entry")  // Add tooltip
                                
                                if entry.id != entries.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .scrollIndicators(.never)
                }
                .frame(width: 200)
                .background(
                    LinearGradient(
                        colors: [currentTheme.backgroundFade.opacity(0.98), currentTheme.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .overlay {
            if showingVideoRecording {
                VideoRecordingView(
                    isPresented: $showingVideoRecording,
                    cameraManager: preparedCameraManager
                ) { videoURL, transcript in
                    // Save the video and create entry
                    saveVideoEntry(from: videoURL, transcript: transcript)
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        showingVideoRecording = false
                    }
                }
                .zIndex(10)
            }
        }
        .frame(minWidth: 1100, minHeight: 600)
        .animation(.easeInOut(duration: 0.2), value: showingSidebar)
        .preferredColorScheme(currentTheme.isDarkTheme ? .dark : .light)
        .onAppear {
            showingSidebar = false  // Hide sidebar by default
            loadExistingEntries()
        }
        .onChange(of: showingVideoRecording) { _, isShowing in
            if !isShowing {
                clearVideoRecordingPreparationState()
            }
        }
        .onChange(of: text) { _, _ in
            // Save current entry when text changes
            if let currentId = selectedEntryId,
               let currentEntry = entries.first(where: { $0.id == currentId }),
               currentEntry.entryType == .text {
                saveEntry(entry: currentEntry)
            }
        }
        .onReceive(timer) { _ in
            if timerIsRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                timerIsRunning = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willEnterFullScreenNotification)) { _ in
            isFullscreen = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification)) { _ in
            isFullscreen = false
        }
    }

    // MARK: - Footer Views

    @ViewBuilder
    private var leftFooterGroup: some View {
        if isViewingVideoEntry {
            if selectedVideoHasTranscript {
                HStack(spacing: 8) {
                    Button(action: copyTranscriptForSelectedVideoEntry) {
                        Text(didCopyTranscript ? "Copied Transcript" : "Copy Transcript")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(isHoveringCopyTranscript ? textHoverColor : textColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(footerButtonChrome(isHovered: isHoveringCopyTranscript, isActive: didCopyTranscript))
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        isHoveringCopyTranscript = hovering
                        isHoveringBottomNav = hovering
                        if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                    }
                }
                .padding(6)
                .background(footerGroupChrome())
                .onHover { isHoveringBottomNav = $0 }
            }
        } else {
            HStack(spacing: 8) {
                Button(action: { showingThemePicker.toggle() }) {
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [currentTheme.backgroundFade, currentTheme.background],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 18, height: 18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(currentTheme.gridClear.opacity(0.8), lineWidth: 1)
                            )
                        Text(currentTheme.name)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.up")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(textColor)
                    }
                    .foregroundColor(isHoveringThemePicker ? textHoverColor : textColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(footerButtonChrome(isHovered: isHoveringThemePicker, isActive: showingThemePicker))
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    isHoveringThemePicker = hovering
                    isHoveringBottomNav = hovering
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
                .popover(isPresented: $showingThemePicker, attachmentAnchor: .point(UnitPoint(x: 0.5, y: 0.0)), arrowEdge: .top) {
                    ThemePickerView(currentTheme: $currentTheme, showingThemePicker: $showingThemePicker)
                        .preferredColorScheme(currentTheme.isDarkTheme ? .dark : .light)
                }
            }
            .padding(6)
            .background(footerGroupChrome())
            .onHover { isHoveringBottomNav = $0 }
        }
    }

    @ViewBuilder
    private var rightFooterGroup: some View {
        HStack(spacing: 6) {
            Button(timerButtonTitle) {
                let now = Date()
                if let lastClick = lastClickTime, now.timeIntervalSince(lastClick) < 0.3 {
                    timeRemaining = 900
                    timerIsRunning = false
                    lastClickTime = nil
                } else {
                    timerIsRunning.toggle()
                    lastClickTime = now
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(timerColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(footerButtonChrome(isHovered: isHoveringTimer, isActive: timerIsRunning))
            .onHover { hovering in
                isHoveringTimer = hovering
                isHoveringBottomNav = hovering
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                    if isHoveringTimer {
                        let scrollBuffer = event.deltaY * 0.25
                        if abs(scrollBuffer) >= 0.1 {
                            let currentMinutes = timeRemaining / 60
                            NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
                            let direction = -scrollBuffer > 0 ? 5 : -5
                            let newMinutes = currentMinutes + direction
                            let roundedMinutes = (newMinutes / 5) * 5
                            timeRemaining = min(max(roundedMinutes * 60, 0), 2700)
                        }
                    }
                    return event
                }
            }

            footerDivider

            Button(action: {
                guard !isPreparingVideoRecording else { return }
                startVideoRecordingPreflight()
            }) {
                Group {
                    if isPreparingVideoRecording {
                        ProgressView()
                            .controlSize(.small)
                            .tint(isHoveringVideoButton ? textHoverColor : textColor)
                    } else {
                        Image(systemName: "video.fill")
                            .foregroundColor(isHoveringVideoButton ? textHoverColor : textColor)
                    }
                }
                .frame(width: 14, height: 14)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(footerButtonChrome(isHovered: isHoveringVideoButton, isActive: isPreparingVideoRecording))
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHoveringVideoButton = hovering
                isHoveringBottomNav = hovering
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
            .popover(
                isPresented: $showingVideoPermissionPopover,
                attachmentAnchor: .point(UnitPoint(x: 0.5, y: 0.0)),
                arrowEdge: .top
            ) {
                videoPermissionPopoverContent
            }

            footerDivider

            Button("Chat") {
                showingChatMenu = true
                didCopyPrompt = false
            }
            .buttonStyle(.plain)
            .foregroundColor(isHoveringChat ? textHoverColor : textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(footerButtonChrome(isHovered: isHoveringChat, isActive: showingChatMenu))
            .onHover { hovering in
                isHoveringChat = hovering
                isHoveringBottomNav = hovering
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
            .popover(isPresented: $showingChatMenu, attachmentAnchor: .point(UnitPoint(x: 0.5, y: 0)), arrowEdge: .top) {
                chatMenuContent
            }

            footerDivider

            if !isViewingVideoEntry {
                Button(action: { backspaceDisabled.toggle() }) {
                    Text(backspaceDisabled ? "Backspace is Off" : "Backspace is On")
                        .foregroundColor(isHoveringBackspaceToggle ? textHoverColor : textColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(footerButtonChrome(isHovered: isHoveringBackspaceToggle, isActive: backspaceDisabled))
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    isHoveringBackspaceToggle = hovering
                    isHoveringBottomNav = hovering
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }

                footerDivider
            }

            Button(isFullscreen ? "Minimize" : "Fullscreen") {
                NSApplication.shared.windows.first?.toggleFullScreen(nil)
            }
            .buttonStyle(.plain)
            .foregroundColor(isHoveringFullscreen ? textHoverColor : textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(footerButtonChrome(isHovered: isHoveringFullscreen, isActive: isFullscreen))
            .onHover { hovering in
                isHoveringFullscreen = hovering
                isHoveringBottomNav = hovering
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }

            footerDivider

            Button(action: createNewEntry) {
                Text("New Entry").font(.system(size: 13))
            }
            .buttonStyle(.plain)
            .foregroundColor(isHoveringNewEntry ? textHoverColor : textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(footerButtonChrome(isHovered: isHoveringNewEntry))
            .onHover { hovering in
                isHoveringNewEntry = hovering
                isHoveringBottomNav = hovering
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }

            footerDivider

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { showingSidebar.toggle() }
            }) {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(isHoveringClock ? textHoverColor : textColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(footerButtonChrome(isHovered: isHoveringClock, isActive: showingSidebar))
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHoveringClock = hovering
                isHoveringBottomNav = hovering
                if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
        }
        .padding(4)
        .background(footerGroupChrome())
        .onHover { isHoveringBottomNav = $0 }
    }

    @ViewBuilder
    private var videoPermissionPopoverContent: some View {
        VStack(spacing: 0) {
            if let fallbackMessage = videoPermissionPopoverFallbackMessage {
                Text(fallbackMessage)
                    .font(.system(size: 14))
                    .foregroundColor(popoverTextColor)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            ForEach(videoPermissionPopoverItems) { item in
                if item.id != videoPermissionPopoverItems.first?.id || videoPermissionPopoverFallbackMessage != nil {
                    Divider()
                }
                Button(action: {
                    showingVideoPermissionPopover = false
                    openVideoPermissionSettings(item.settingsPane)
                }) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.message)
                            .font(.system(size: 14))
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(item.buttonLabel)
                            .font(.system(size: 12))
                            .opacity(0.85)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .foregroundColor(popoverTextColor)
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
            }
        }
        .frame(minWidth: 300, idealWidth: 320, maxWidth: 360)
        .background(popoverBackgroundColor)
    }

    @ViewBuilder
    private var chatMenuContent: some View {
        let chatSourceText = currentChatSourceText()
        let gptFullText = aiChatPrompt + "\n\n" + chatSourceText
        let claudeFullText = claudePrompt + "\n\n" + chatSourceText
        let encodedGptText = gptFullText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedClaudeText = claudeFullText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let isUrlTooLong = ("https://chat.openai.com/?m=".count + encodedGptText.count) > 6000
            || ("https://claude.ai/new?q=".count + encodedClaudeText.count) > 6000

        VStack(spacing: 0) {
            if isUrlTooLong {
                Text("Hey, your entry is quite long. You'll need to manually copy the prompt by clicking 'Copy Prompt' below and then paste it into AI of your choice (ex. ChatGPT). The prompt includes your entry as well. So just copy paste and go! See what the AI says.")
                    .font(.system(size: 14))
                    .foregroundColor(popoverTextColor)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .frame(width: 200, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                Divider()
                Button(action: { copyPromptToClipboard(); didCopyPrompt = true }) {
                    Text(didCopyPrompt ? "Copied!" : "Copy Prompt")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .foregroundColor(popoverTextColor)
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
            } else if !isViewingVideoEntry && text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("hi. my name is farza.") {
                Text("Yo. Sorry, you can't chat with the guide lol. Please write your own entry.")
                    .font(.system(size: 14))
                    .foregroundColor(popoverTextColor)
                    .frame(width: 250)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            } else if !isViewingVideoEntry && text.count < 350 {
                Text("Please free write for at minimum 5 minutes first. Then click this. Trust.")
                    .font(.system(size: 14))
                    .foregroundColor(popoverTextColor)
                    .frame(width: 250)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            } else {
                Button(action: { showingChatMenu = false; openChatGPT() }) {
                    Text("ChatGPT")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .foregroundColor(popoverTextColor)
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
                Divider()
                Button(action: { showingChatMenu = false; openClaude() }) {
                    Text("Claude")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .foregroundColor(popoverTextColor)
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
                Divider()
                Button(action: { copyPromptToClipboard(); didCopyPrompt = true }) {
                    Text(didCopyPrompt ? "Copied!" : "Copy Prompt")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .foregroundColor(popoverTextColor)
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
            }
        }
        .frame(minWidth: 120, maxWidth: 250)
        .background(popoverBackgroundColor)
        .onChange(of: showingChatMenu) { _, isShowing in
            if !isShowing { didCopyPrompt = false }
        }
    }

    private func footerGroupChrome() -> some View {
        Color.clear
    }

    private func footerButtonChrome(isHovered: Bool, isActive: Bool = false) -> some View {
        Group {
            if #available(macOS 26.0, *), isHovered || isActive {
                Color.clear
                    .glassEffect(
                        isActive
                            ? .regular.tint(currentTheme.isDarkTheme ? currentTheme.typeSubtlePlus : currentTheme.typeHighlight).interactive()
                            : .regular.interactive(),
                        in: RoundedRectangle(cornerRadius: 11, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .stroke(
                                isActive
                                    ? currentTheme.typeSubtle.opacity(currentTheme.isDarkTheme ? 0.55 : 0.45)
                                    : footerPanelStrokeColor.opacity(0.7),
                                lineWidth: 1
                            )
                    )
            } else {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(isActive ? footerButtonActiveFill : (isHovered ? footerButtonHoverFill : Color.clear))
                    .overlay(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .stroke(
                                isActive
                                    ? currentTheme.typeSubtle.opacity(currentTheme.isDarkTheme ? 0.5 : 0.4)
                                    : footerPanelStrokeColor.opacity(isHovered ? 1.0 : 0.0),
                                lineWidth: 1
                            )
                    )
            }
        }
    }
    
    private func backgroundColor(for entry: HumanEntry) -> Color {
        if entry.id == selectedEntryId {
            return currentTheme.isDarkTheme
                ? currentTheme.typeSubtlePlus.opacity(0.24)
                : currentTheme.typeHighlight.opacity(0.88)
        } else if entry.id == hoveredEntryId {
            return currentTheme.isDarkTheme
                ? currentTheme.typeSuperlight.opacity(0.22)
                : currentTheme.typeHyperLight.opacity(0.95)
        } else {
            return Color.clear
        }
    }
    
    private func updatePreviewText(for entry: HumanEntry) {
        if entry.entryType == .video {
            if let index = entries.firstIndex(where: { $0.id == entry.id }),
               let videoFilename = resolvedVideoFilename(for: entry) {
                entries[index].previewText = videoPreviewText(for: videoFilename)
            }
            return
        }

        let documentsDirectory = getDocumentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent(entry.filename)
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let preview = content
                .replacingOccurrences(of: "\n", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let truncated = preview.isEmpty ? "" : (preview.count > 30 ? String(preview.prefix(30)) + "..." : preview)
            
            // Find and update the entry in the entries array
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[index].previewText = truncated
            }
        } catch {
            print("Error updating preview text: \(error)")
        }
    }
    
    private func saveEntry(entry: HumanEntry) {
        guard entry.entryType == .text else {
            return
        }

        let documentsDirectory = getDocumentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent(entry.filename)
        
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Successfully saved entry: \(entry.filename)")
            updatePreviewText(for: entry)  // Update preview after saving
        } catch {
            print("Error saving entry: \(error)")
        }
    }
    
    private func loadEntry(entry: HumanEntry) {
        if let videoFilename = resolvedVideoFilename(for: entry) {
            // Load video entry
            let videoURL = getVideoURL(for: videoFilename)
            let thumbnailURL = getVideoThumbnailURL(for: videoFilename)
            let transcriptURL = getVideoTranscriptURL(for: videoFilename)
            historyDebug("LOAD VIDEO \(debugEntrySummary(entry)) resolvedVideoPath=\(videoURL.path) videoExists=\(fileManager.fileExists(atPath: videoURL.path)) thumbnailPath=\(thumbnailURL.path) thumbnailExists=\(fileManager.fileExists(atPath: thumbnailURL.path))")
            text = ""
            didCopyTranscript = false
            selectedVideoHasTranscript = fileManager.fileExists(atPath: transcriptURL.path)
            if fileManager.fileExists(atPath: videoURL.path) {
                currentVideoURL = videoURL
                print("Successfully loaded video entry: \(videoFilename)")
            } else {
                print("Video file missing for entry: \(videoFilename)")
            }
        } else {
            // Load text entry
            historyDebug("LOAD TEXT \(debugEntrySummary(entry))")
            currentVideoURL = nil
            selectedVideoHasTranscript = false
            didCopyTranscript = false
            let documentsDirectory = getDocumentsDirectory()
            let fileURL = documentsDirectory.appendingPathComponent(entry.filename)

            do {
                if fileManager.fileExists(atPath: fileURL.path) {
                    let rawText = try String(contentsOf: fileURL, encoding: .utf8)
                    // Strip legacy leading newlines from older entries
                    text = String(rawText.drop(while: { $0 == "\n" }))
                    print("Successfully loaded entry: \(entry.filename)")
                }
            } catch {
                print("Error loading entry: \(error)")
            }
        }
    }
    
    private func createNewEntry() {
        let newEntry = HumanEntry.createNew()
        entries.insert(newEntry, at: 0) // Add to the beginning
        selectedEntryId = newEntry.id
        currentVideoURL = nil
        selectedVideoHasTranscript = false
        didCopyTranscript = false
        historyDebug("NEW ENTRY created \(debugEntrySummary(newEntry))")
        logEntriesOrder("createNewEntry")

        // If this is the first entry (entries was empty before adding this one)
        if entries.count == 1 {
            // Read welcome message from default.md
            if let defaultMessageURL = Bundle.main.url(forResource: "default", withExtension: "md"),
               let defaultMessage = try? String(contentsOf: defaultMessageURL, encoding: .utf8) {
                text = defaultMessage
            }
            // Save the welcome message immediately
            saveEntry(entry: newEntry)
            // Update the preview text
            updatePreviewText(for: newEntry)
        } else {
            text = ""
            // Randomize placeholder text for new entry
            placeholderText = placeholderOptions.randomElement() ?? "Begin writing"
            // Save the empty entry
            saveEntry(entry: newEntry)
        }
    }
    
    private func openChatGPT() {
        let fullText = aiChatPrompt + "\n\n" + currentChatSourceText()
        
        if let encodedText = fullText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://chat.openai.com/?prompt=" + encodedText) {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openClaude() {
        let fullText = claudePrompt + "\n\n" + currentChatSourceText()
        
        if let encodedText = fullText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://claude.ai/new?q=" + encodedText) {
            NSWorkspace.shared.open(url)
        }
    }

    private func copyPromptToClipboard() {
        let fullText = aiChatPrompt + "\n\n" + currentChatSourceText()

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(fullText, forType: .string)
        print("Prompt copied to clipboard")
    }

    private func currentChatSourceText() -> String {
        if currentVideoURL != nil,
           let selectedEntryId,
           let selectedEntry = entries.first(where: { $0.id == selectedEntryId }),
           let videoFilename = resolvedVideoFilename(for: selectedEntry),
           let transcript = loadTranscriptText(for: videoFilename) {
            return transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveVideoEntry(from tempURL: URL, transcript: String?) {
        let replacementEntry = selectedEntryId
            .flatMap { id in entries.first(where: { $0.id == id }) }
            .flatMap { entry -> HumanEntry? in
                guard entry.entryType == .text else { return nil }
                guard text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
                return entry
            }

        let videoEntry: HumanEntry
        if let replacementEntry {
            let videoFilename = replacementEntry.filename.replacingOccurrences(of: ".md", with: ".mov")
            videoEntry = HumanEntry(
                id: replacementEntry.id,
                date: replacementEntry.date,
                filename: replacementEntry.filename,
                previewText: previewTextFromTranscript(transcript),
                entryType: .video,
                videoFilename: videoFilename
            )
        } else {
            let newEntry = HumanEntry.createVideoEntry()
            videoEntry = HumanEntry(
                id: newEntry.id,
                date: newEntry.date,
                filename: newEntry.filename,
                previewText: previewTextFromTranscript(transcript),
                entryType: .video,
                videoFilename: newEntry.videoFilename
            )
        }

        // Get the documents directory
        let documentsDirectory = getDocumentsDirectory()

        // Save the video file
        if let videoFilename = videoEntry.videoFilename {
            do {
                let videoEntryDirectory = try ensureVideoEntryDirectoryExists(for: videoFilename)
                let videoDestURL = videoEntryDirectory.appendingPathComponent(videoFilename)
                let transcriptURL = videoEntryDirectory.appendingPathComponent("transcript.md")
                let cleanedTranscript = transcript?.trimmingCharacters(in: .whitespacesAndNewlines)

                // Copy the video file from temp location to documents directory
                if fileManager.fileExists(atPath: videoDestURL.path) {
                    try fileManager.removeItem(at: videoDestURL)
                }
                try fileManager.copyItem(at: tempURL, to: videoDestURL)
                print("Successfully saved video: \(videoFilename)")

                if let thumbnailImage = generateVideoThumbnail(from: videoDestURL) {
                    persistThumbnail(thumbnailImage, for: videoFilename)
                    print("Successfully saved thumbnail for video: \(videoFilename)")
                } else {
                    print("Could not generate thumbnail for video: \(videoFilename)")
                }

                // Create the metadata file
                let metadataURL = documentsDirectory.appendingPathComponent(videoEntry.filename)
                let metadataContent = "Video Entry"
                try metadataContent.write(to: metadataURL, atomically: true, encoding: .utf8)

                if let cleanedTranscript, !cleanedTranscript.isEmpty {
                    try cleanedTranscript.write(to: transcriptURL, atomically: true, encoding: .utf8)
                    print("Successfully saved transcript for video: \(videoFilename)")
                } else if fileManager.fileExists(atPath: transcriptURL.path) {
                    try fileManager.removeItem(at: transcriptURL)
                }

                let selectNewVideoEntry = {
                    if let existingIndex = self.entries.firstIndex(where: { $0.id == videoEntry.id }) {
                        self.entries[existingIndex] = videoEntry
                    } else {
                        self.entries.insert(videoEntry, at: 0)
                    }
                    self.entries.sort { self.isEntryNewer($0, than: $1) }
                    guard let insertedEntry = self.entries.first(where: { $0.id == videoEntry.id }) else {
                        print("Could not find saved video entry in entries array")
                        return
                    }
                    self.selectedEntryId = insertedEntry.id
                    self.currentVideoURL = videoDestURL
                    self.text = ""
                    self.didCopyTranscript = false
                    self.selectedVideoHasTranscript = (cleanedTranscript?.isEmpty == false)
                    print("Successfully loaded new video entry: \(videoFilename)")
                    self.historyDebug("VIDEO SAVE selected \(self.debugEntrySummary(insertedEntry)) videoPath=\(videoDestURL.path)")
                    self.logEntriesOrder("saveVideoEntry")
                }
                
                if Thread.isMainThread {
                    selectNewVideoEntry()
                } else {
                    DispatchQueue.main.async {
                        selectNewVideoEntry()
                    }
                }

                if replacementEntry != nil {
                    print("Successfully replaced empty text entry with video entry")
                } else {
                    print("Successfully created video entry")
                }
            } catch {
                print("Error saving video entry: \(error)")
            }
        }
    }

    private func deleteEntry(entry: HumanEntry) {
        // Delete the file from the filesystem
        let documentsDirectory = getDocumentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent(entry.filename)

        do {
            try fileManager.removeItem(at: fileURL)
            print("Successfully deleted file: \(entry.filename)")

            // If this is a video entry, also delete the video file
            if let videoFilename = resolvedVideoFilename(for: entry) {
                deleteVideoAssets(for: videoFilename)
                print("Successfully deleted video assets: \(videoFilename)")
            }

            // Remove the entry from the entries array
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries.remove(at: index)
                historyDebug("DELETE ENTRY removed \(debugEntrySummary(entry))")
                logEntriesOrder("deleteEntry")

                // If the deleted entry was selected, select the first entry or create a new one
                if selectedEntryId == entry.id {
                    if let firstEntry = entries.first {
                        selectedEntryId = firstEntry.id
                        loadEntry(entry: firstEntry)
                    } else {
                        createNewEntry()
                    }
                }
            }
        } catch {
            print("Error deleting file: \(error)")
        }
    }
    
    // Extract a title from entry content for PDF export
    private func extractTitleFromContent(_ content: String, date: String) -> String {
        // Clean up content by removing leading/trailing whitespace and newlines
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If content is empty, just use the date
        if trimmedContent.isEmpty {
            return "Entry \(date)"
        }
        
        // Split content into words, ignoring newlines and removing punctuation
        let words = trimmedContent
            .replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .map { word in
                word.trimmingCharacters(in: CharacterSet(charactersIn: ".,!?;:\"'()[]{}<>"))
                    .lowercased()
            }
            .filter { !$0.isEmpty }
        
        // If we have at least 4 words, use them
        if words.count >= 4 {
            return "\(words[0])-\(words[1])-\(words[2])-\(words[3])"
        }
        
        // If we have fewer than 4 words, use what we have
        if !words.isEmpty {
            return words.joined(separator: "-")
        }
        
        // Fallback to date if no words found
        return "Entry \(date)"
    }
    
    private func exportEntryAsPDF(entry: HumanEntry) {
        // First make sure the current entry is saved
        if selectedEntryId == entry.id {
            saveEntry(entry: entry)
        }
        
        // Get entry content
        let documentsDirectory = getDocumentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent(entry.filename)
        
        do {
            // Read the content of the entry
            let entryContent = try String(contentsOf: fileURL, encoding: .utf8)
            
            // Extract a title from the entry content and add .pdf extension
            let suggestedFilename = extractTitleFromContent(entryContent, date: entry.date) + ".pdf"
            
            // Create save panel
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [UTType.pdf]
            savePanel.nameFieldStringValue = suggestedFilename
            savePanel.isExtensionHidden = false  // Make sure extension is visible
            
            // Show save dialog
            if savePanel.runModal() == .OK, let url = savePanel.url {
                // Create PDF data
                if let pdfData = createPDFFromText(text: entryContent) {
                    try pdfData.write(to: url)
                    print("Successfully exported PDF to: \(url.path)")
                }
            }
        } catch {
            print("Error in PDF export: \(error)")
        }
    }
    
    private func createPDFFromText(text: String) -> Data? {
        // Letter size page dimensions
        let pageWidth: CGFloat = 612.0  // 8.5 x 72
        let pageHeight: CGFloat = 792.0 // 11 x 72
        let margin: CGFloat = 72.0      // 1-inch margins
        
        // Calculate content area
        let contentRect = CGRect(
            x: margin,
            y: margin,
            width: pageWidth - (margin * 2),
            height: pageHeight - (margin * 2)
        )
        
        // Create PDF data container
        let pdfData = NSMutableData()
        
        // Configure text formatting attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight
        
        let font = NSFont(name: selectedFont, size: fontSize) ?? .systemFont(ofSize: fontSize)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.0),
            .paragraphStyle: paragraphStyle
        ]
        
        // Trim the initial newlines before creating the PDF
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Create the attributed string with formatting
        let attributedString = NSAttributedString(string: trimmedText, attributes: textAttributes)
        
        // Create a Core Text framesetter for text layout
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        
        // Create a PDF context with the data consumer
        guard let pdfContext = CGContext(consumer: CGDataConsumer(data: pdfData as CFMutableData)!, mediaBox: nil, nil) else {
            print("Failed to create PDF context")
            return nil
        }
        
        // Track position within text
        var currentRange = CFRange(location: 0, length: 0)
        var pageIndex = 0
        
        // Create a path for the text frame
        let framePath = CGMutablePath()
        framePath.addRect(contentRect)
        
        // Continue creating pages until all text is processed
        while currentRange.location < attributedString.length {
            // Begin a new PDF page
            pdfContext.beginPage(mediaBox: nil)
            
            // Fill the page with white background
            pdfContext.setFillColor(NSColor.white.cgColor)
            pdfContext.fill(CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
            
            // Create a frame for this page's text
            let frame = CTFramesetterCreateFrame(
                framesetter, 
                currentRange, 
                framePath, 
                nil
            )
            
            // Draw the text frame
            
            // Get the range of text that was actually displayed in this frame
            let visibleRange = CTFrameGetVisibleStringRange(frame)
            
            // Move to the next block of text for the next page
            currentRange.location += visibleRange.length
            
            // Finish the page
            pdfContext.endPage()
            pageIndex += 1
            
            // Safety check - don't allow infinite loops
            if pageIndex > 1000 {
                print("Safety limit reached - stopping PDF generation")
                break
            }
        }
        
        // Finalize the PDF document
        pdfContext.closePDF()
        
        return pdfData as Data
    }
}

// Helper function to calculate line height
func getLineHeight(font: NSFont) -> CGFloat {
    return font.ascender - font.descender + font.leading
}

// Add helper extension to find NSTextView
extension NSView {
    func findTextView() -> NSView? {
        if self is NSTextView {
            return self
        }
        for subview in subviews {
            if let textView = subview.findTextView() {
                return textView
            }
        }
        return nil
    }
}

// Add helper extension for finding subviews of a specific type
extension NSView {
    func findSubview<T: NSView>(ofType type: T.Type) -> T? {
        if let typedSelf = self as? T {
            return typedSelf
        }
        for subview in subviews {
            if let found = subview.findSubview(ofType: type) {
                return found
            }
        }
        return nil
    }
}

#Preview {
    ContentView()
}

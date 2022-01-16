//
//  NowPlaying.swift
//  NowPlaying
//
//  Created by Angelo Chaves on 2022-01-03.
//

import WidgetKit
import SwiftUI
import Intents

struct SongProvider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SongEntry {
        SongEntry(date: Date(), configuration: ConfigurationIntent(), name: "Preview Song", artist: "Preview Artist", isPreview: true)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SongEntry) -> Void) {
        NowPlayingHelper.shared.getSong { artist, title, album, _ in
            let date = Date()
            let entry: SongEntry
            
            entry = SongEntry(date: date, configuration: configuration, name: title, artist: artist)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        NowPlayingHelper.shared.getSong { artist, title, album, artwork in
            let date = Date()
            let entry = SongEntry(date: date, configuration: configuration, name: title, artist: artist, artwork: artwork)
            
            // Create a date that's 5 minutes in the future.
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: date)!

            // Create the timeline with the entry and a reload policy with the date
            // for the next update.
            let timeline = Timeline(
                entries: [entry],
                policy: .after(nextUpdateDate)
            )

            // Call the completion to pass the timeline to WidgetKit.
            completion(timeline)
        }
    }
}

struct SongEntry: TimelineEntry {
    var date: Date
    let configuration: ConfigurationIntent
    
    let name: String
    let artist: String
    let artwork: Data?
    let isPreview: Bool
    
    init(date:Date, configuration: ConfigurationIntent, name: String, artist: String, artwork: Data?) {
        self.date = date
        self.configuration = configuration
        self.name = name
        self.artist = artist
        self.isPreview = false
        self.artwork = artwork
    }
    
    init(date:Date, configuration: ConfigurationIntent, name: String, artist: String) {
        self.date = date
        self.configuration = configuration
        self.name = name
        self.artist = artist
        self.isPreview = false
        self.artwork = nil
    }
    
    init(date:Date, configuration: ConfigurationIntent, name: String, artist: String, isPreview: Bool) {
        self.date = date
        self.configuration = configuration
        self.name = name
        self.artist = artist
        self.isPreview = isPreview
        self.artwork = nil
    }
}

struct NowPlayingEntryView : View {
    var entry: SongProvider.Entry

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.red,Color.pink], startPoint: .top, endPoint: .bottom)
            HStack {
                ZStack {
                    if let artwork = entry.artwork, let nsImage = NSImage(data: artwork) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.white)
                            .opacity(NowPlayingHelper.shared.playingState == .playing ? 1 : 0.4)
                            .clipShape(ContainerRelativeShape())
                    } else {
                        ContainerRelativeShape()
                            .scaledToFit()
                            .opacity(0.2)
                        Image(systemName: "music.note")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.white)
                            .padding(16)
                            .opacity(NowPlayingHelper.shared.playingState == .playing ? 1 : 0.2)
                    }
                    if NowPlayingHelper.shared.playingState != .playing {
                        Image(systemName: NowPlayingHelper.shared.playingState.rawValue)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.white)
                            .padding()
                    }
                }
                .frame(maxWidth: 114, maxHeight: 114, alignment: .center)
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    Text(entry.name)
                        .font(.title)
                        .bold()
                        .minimumScaleFactor(0.7)
                    Text(entry.artist)
                        .font(.title)
                        .minimumScaleFactor(0.7)
                }
                .foregroundColor(Color.white)
                .padding()
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

@main
struct NowPlaying: Widget {
    let kind: String = "link.anco.ShowMeTheMusic.NowPlaying"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: SongProvider()) { entry in
            NowPlayingEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium,.systemLarge])
        .configurationDisplayName("Now Playing")
        .description("Shows what's currently playing.")
    }
}

struct NowPlaying_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingEntryView(entry: SongEntry(date: Date(), configuration: ConfigurationIntent(), name: "Currently Playing Song", artist: "Artist Name", isPreview: false))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

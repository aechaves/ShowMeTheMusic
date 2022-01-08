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
        SongEntry(date: Date(), configuration: ConfigurationIntent(), name: "Preview Song", isPreview: true)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SongEntry) -> Void) {
        NowPlayingHelper.shared.getSong { artist, title, album in
            let date = Date()
            let entry: SongEntry
            
            entry = SongEntry(date: date, configuration: configuration, name: title)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        NowPlayingHelper.shared.getSong { artist, title, album in
            let date = Date()
            let entry = SongEntry(date: date, configuration: configuration, name: title)
            
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
    let artwork: Image?
    let isPreview: Bool
    
    init(date:Date, configuration: ConfigurationIntent, name: String) {
        self.date = date
        self.configuration = configuration
        self.name = name
        self.isPreview = false
        self.artwork = nil
    }
    
    init(date:Date, configuration: ConfigurationIntent, name: String, isPreview: Bool) {
        self.date = date
        self.configuration = configuration
        self.name = name
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
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.white)
                    .frame(maxWidth: 114, maxHeight: 114, alignment: .center)
                Spacer()
                VStack {
                    Text(entry.name)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: 180, maxHeight: 90, alignment: .leading)
                    Text("Artist Nameeeeeee")
                        .truncationMode(.tail)
                        .font(.title)
                        .frame(maxWidth: 180, maxHeight: 20, alignment: .leading)
                }
                .foregroundColor(Color.white)
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
        NowPlayingEntryView(entry: SongEntry(date: Date(), configuration: ConfigurationIntent(), name: "Currently Playing Songggggggggggggggggggggggg", isPreview: false))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
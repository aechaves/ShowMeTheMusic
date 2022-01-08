//
//  NowPlayingHelper.swift
//  ShowMeTheMusic
//
//  Created by Angelo Chaves on 2022-01-03.
//  Built with the help of: https://stackoverflow.com/questions/61003379/how-to-get-currently-playing-song-on-mac-swift

import Foundation

typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void

struct Song {
    let artist: String
    let title: String
    let album: String
    let duration: String
    let artwork: Data
}

struct NowPlayingHelper {
    static var shared = NowPlayingHelper()
    
    var bundle: CFBundle?
    var MRMediaRemoteGetNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoFunction?
    var currentSong: Song?
    
    init() {
        // Load framework
        bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))

        // Get a Swift function for MRMediaRemoteGetNowPlayingInfo
        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return }
        MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
    }
    
    func getSong(callback: @escaping (String, String, String) -> ()) {
        MRMediaRemoteGetNowPlayingInfo!(DispatchQueue.main, { (information) in
            //print(information["kMRMediaRemoteNowPlayingInfoDuration"] as! String) // not a string
            //let artwork = NSImage(data: information["kMRMediaRemoteNowPlayingInfoArtworkData"] as! Data)
            
            callback(
                information["kMRMediaRemoteNowPlayingInfoArtist"] as! String,
                information["kMRMediaRemoteNowPlayingInfoTitle"] as! String,
                information["kMRMediaRemoteNowPlayingInfoAlbum"] as! String
            )
        })
    }
}

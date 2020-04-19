//
//  PlayerView.swift
//  Recordings
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI

struct PlayerView: View {
    let recording: Recording
    @State private var name: String = ""
    @State private var position: TimeInterval = 0
    @ObservedObject private var player: Lazy<Player>
    
    init?(recording: Recording) {
        self.recording = recording
        self._name = State(initialValue: recording.name)
        guard let u = recording.fileURL else { return nil }
        self.player = Lazy { Player(url: u)! } // todo
    }
    
    var playButtonTitle: String {
        if player.isPlaying { return "Pause" }
        else if player.isPaused { return "Resume" }
        else { return "Play" }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Name")
                TextField("Name", text: $name, onEditingChanged: { _ in
                    self.recording.setName(self.name)
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Text(timeString(0))
                Spacer()
                Text(timeString(player.duration))
            }
            Slider(value: $player.time, in: 0...player.duration)
            Button(playButtonTitle) { self.player.value.togglePlay() }
                .buttonStyle(PrimaryButtonStyle())
            Spacer()
        }
        .padding()
    }
}

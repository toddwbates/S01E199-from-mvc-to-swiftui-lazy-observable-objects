//
//  RecordingView.swift
//  Recordings
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI

struct RecordingView: View {
  let folder: Folder
  @Binding var isPresented: Bool
  
  private let recording = Recording(name: "", uuid: UUID())
  @State private var recorder: Recorder? = nil
  @State private var time: TimeInterval = 0
  @State private var isSaving: Bool = false
  
  func save(name: String?) {
    if let n = name {
      recording.setName(n)
      folder.add(recording)
    } else {
      recording.deleted()
    }
    isPresented = false
  }
  
  var body: some View {
    VStack(spacing: 20) {
      Text("Recording")
      Text(timeString(time))
        .font(.title)
      Button("Stop") {
        self.recorder?.stop()
        self.isSaving = true
      }
      .buttonStyle(PrimaryButtonStyle())
    }
    .padding()
    .onAppear {
      guard let s = self.folder.store, let url = s.fileURL(for: self.recording) else { return }
      self.recorder = Recorder(url: url) { time in
        self.time = time ?? 0
      }
    }
    .onDisappear {
      // TODO stop and delete
    }
    .textAlert(isPresented: $isSaving, title: "Save Recording", placeholder: "Name", callback: { self.save(name: $0) })
  }
}


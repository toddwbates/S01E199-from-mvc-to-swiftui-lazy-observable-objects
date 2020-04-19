//
//  PlayerView.swift
//  Recordings
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI

let playerViewReducer = Reducer<PlayerView.State, PlayerView.Action, ()> {_,_,_ in
  return []
}

struct PlayerView: View {
  
  struct State : Equatable{
    var name: String
    
    var duration: TimeInterval
    var position: TimeInterval = 0
    
    public enum PlayState {
      case atBegining
      case playing
      case paused
    }
    
    var playState : PlayState
  }
  
  enum Action {
    case setName(String)
    case setPostion(TimeInterval)
    case togglePlay
  }
  
  @ObservedObject private var store: ViewStore<State, Action>
  
  public init(store: ViewStore<State, Action>) {
    self.store = store
  }
  
  var playButtonTitle: String {
    switch store.value.playState {
    case .atBegining:
      return "Play"
    case .playing:
      return "Pause"
    case .paused:
      return "Resume"
    }
  }
  
  var body: some View {
    VStack(spacing: 20) {
      HStack {
        Text("Name")
        TextField("Name",
                  text: Binding(get: { self.store.value.name } , set: { self.store.send(.setName($0)) }))
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }
      HStack {
        Text(timeString(0))
        Spacer()
        Text(timeString(store.value.duration))
      }
      Slider(value: Binding(get: { self.store.value.position } , set: { self.store.send(.setPostion($0)) }),
             in: 0...store.value.duration)
      Button(playButtonTitle) { self.store.send(.togglePlay) }
        .buttonStyle(PrimaryButtonStyle())
      Spacer()
    }
    .padding()
  }
}

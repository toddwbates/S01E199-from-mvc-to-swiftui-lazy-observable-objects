//
//  PlayerView.swift
//  Recordings
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI
import CasePaths

let playerViewReducer = Reducer<PlayerView.State, PlayerView.Action, ()> { state, action, env in
  switch action {
  case let .setName(name):
    state.name = name
  case let .setPostion(position):
    state.position = position
  case .togglePlay:
    state.playState = .pause
  }
  return []
}

struct PlayerView: View {
  
  struct State : Equatable{
    var name: String
    
    var duration: TimeInterval
    var position: TimeInterval = 0
    
    public enum PlayState {
      case start
      case pause
      case resume
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
    case .start:
      return "Play"
    case .pause:
      return "Pause"
    case .resume:
      return "Resume"
    }
  }
  
  var body: some View {
    VStack(spacing: 20) {
      HStack {
        Text("Name")
        TextField("Name",
                  text: self.store.bind(\State.name , /Action.setName))
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }
      HStack {
        Text(timeString(0))
        Spacer()
        Text(timeString(store.value.duration))
      }
      Slider(value: self.store.bind(\State.position , /Action.setPostion),
             in: 0...store.value.duration)
      Button(playButtonTitle, action: self.store.curry(.togglePlay))
        .buttonStyle(PrimaryButtonStyle())
      Spacer()
    }
    .padding()
  }
}

//
//  PlayerView.swift
//  Recordings
//
//  Created by Todd Bates on 4/19/20.
//  Copyright © 2020 objc.io. All rights reserved.
//

import SwiftUI
import CasePaths
import Combine

enum PlayerEnvAction {
  case load
  case position(TimeInterval)
  case toggle
}

enum PlayerEnvResult {
  case length(TimeInterval)
  case playing(position: TimeInterval)
  case stopped(position: TimeInterval)
}

typealias PlayerEnv = (PlayerEnvAction)->Effect<PlayerView.Action>

let playerViewReducer = Reducer<PlayerView.State, PlayerView.Action, PlayerEnv> { state, action, env in
  switch action {
  case .load:
    return [env(.load)]
  case let .setName(name):
    state.name = name
  case let .setPostion(position):
    state.position = position
  case .togglePlay:
    return [env(.toggle)]
  case let .effectResult(effectResult):
    switch effectResult {
    case let .length(length):
      state.duration = length
    case let .playing(position: position):
      state.position = position
      state.buttonState = .pause
    case let .stopped(position: position):
      state.position = position
      state.buttonState = (position == 0) ? .start : .resume
    }
  }
  return []
}

struct PlayerView: View {
  
  struct State : Equatable{
    var name: String
    
    var duration: TimeInterval
    var position: TimeInterval = 0
    
    public enum PlayButtonState : String {
      case start = "Play"
      case pause  = "Pause"
      case resume  = "Resume"
      
      var title: String { self.rawValue }
    }
    
    var buttonState : PlayButtonState
  }
  
  enum Action {
    case load
    case setName(String)
    case setPostion(TimeInterval)
    case togglePlay
    case effectResult(PlayerEnvResult)
  }
  
  @ObservedObject private var store: ViewStore<State, Action>
  
  public init(store: ViewStore<State, Action>) {
    self.store = store
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
      Button(self.store.value.buttonState.title, action: self.store.curry(.togglePlay))
        .buttonStyle(PrimaryButtonStyle())
      Spacer()
    }
    .padding()
    .onAppear( perform: self.store.curry(.load) )
  }
}

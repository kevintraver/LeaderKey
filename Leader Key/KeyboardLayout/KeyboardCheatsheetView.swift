import SwiftUI

struct KeyboardCheatsheetView: View {
  @EnvironmentObject var userState: UserState

  var scale: CGFloat {
    userState.cheatsheetCentered ? KeyboardLayout.centeredScale : 1.0
  }

  var bindings: [String: ActionOrGroup] {
    var result: [String: ActionOrGroup] = [:]

    let actions =
      (userState.currentGroup != nil)
      ? userState.currentGroup!.actions
      : userState.userConfig.root.actions

    for item in actions {
      switch item {
      case .action(let action):
        if let key = action.key {
          result[key] = item
        }
      case .group(let group):
        if let key = group.key {
          result[key] = item
        }
      }
    }

    return result
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8 * scale) {
      // Fixed height header area - always present to maintain layout
      HStack {
        if let group = userState.currentGroup {
          Text(group.displayName)
            .font(.system(size: 12 * scale, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8 * scale)
            .padding(.vertical, 4 * scale)
            .background(Color.accentColor.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 6 * scale, style: .continuous))
        }
        Spacer()
      }
      .frame(height: 28 * scale)

      // Keyboard layout
      KeyboardLayoutView(
        bindings: bindings,
        isEditable: false,
        shiftHeld: userState.shiftHeld,
        scale: scale
      )
    }
    .padding(16 * scale)
    .background(
      VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
    )
  }
}

#Preview {
  let config = UserConfig()
  let state = UserState(userConfig: config)

  return KeyboardCheatsheetView()
    .environmentObject(state)
    .frame(width: 700, height: 350)
}

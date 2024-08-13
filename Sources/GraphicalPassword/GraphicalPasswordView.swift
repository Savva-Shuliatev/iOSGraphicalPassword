//
//  GraphicalPasswordView.swift
//
//  Created by Savva Shuliatev.
//

import SwiftUI

public enum GraphicalPasswordState: Sendable {
  case initial
  case drawing
  case drawn
  case success
  case error
}

@MainActor
public struct GraphicalPasswordView: View {
  public static let spaceName = "GraphicalPasswordView.spaceName"

  @Binding private var state: GraphicalPasswordState

  @State var onDrawEndedActions: [(String) -> Void] = []

  @State private var gestureLocation: CGPoint?
  @State private var points: [CGPoint] = Array(repeating: .zero, count: 9)
  @State private var scalePoints: [Int] = []
  @State private var selectedPoints: [Int] = []

  internal var pointColor: Color = .black
  internal var lineColor: Color = .blue
  internal var selectedPointColor: Color = .blue
  internal var successPointColor: Color = .green
  internal var successLineColor: Color = .green
  internal var errorPointColor: Color = .red
  internal var errorLineColor: Color = .red
  internal var pointRadius: CGFloat = 12
  internal var lineWidth: CGFloat = 1
  internal var scaleEffectForSelectedPoint: CGFloat = 2

  private let values = [[0, 1, 2], [3, 4, 5], [6, 7, 8]]

  public var body: some View {
    ZStack {
      circles
      path
    }
    .coordinateSpace(name: Self.spaceName)
    .gesture(
      DragGesture(coordinateSpace: .named(Self.spaceName))
        .onChanged { value in
          state = .drawing
          self.gestureLocation = value.location

          for (index, rect) in self.points.enumerated() {
            if isGestureLocationInsidePoint(
              center: rect,
              radius: pointRadius,
              point: value.location
            ), !selectedPoints.contains(index) {
              selectedPoints.append(index)

              withAnimation(.linear(duration: 0.2)) {
                scalePoints.append(index)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                  withAnimation(.linear(duration: 0.2)) {
                    scalePoints.removeAll { $0 == index }
                  }
                }
              }
            }
          }
        }
        .onEnded { _ in
          state = .drawn
          gestureLocation = nil

          if selectedPoints.first != nil {
            let password = selectedPoints.map { "\($0)" }.reduce("", +)
            onDrawEndedActions.forEach { action in
              action(password)
            }
          }
        }
    )
    .onChange(of: state) { state in
      switch state {
      case .initial:
        gestureLocation = nil
        selectedPoints = []

      case .drawing:
        break

      case .drawn:
        break

      case .success:
        break

      case .error:
        break
      }
    }
  }

  @ViewBuilder
  private var circles: some View {
    GeometryReader { geometryProxy in
      VStack(spacing: 0) {
        Spacer()
        ForEach(0..<3) { row in
          HStack(spacing: 0) {
            ForEach(0..<3) { column in
              Rectangle()
                .fill(Color.clear)
                .overlay(point(row: row, column: column))
                .frame(
                  width: geometryProxy.size.width / 3,
                  height: geometryProxy.size.width / 3
                )
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  private var path: some View {
    Path { path in
      guard self.selectedPoints.first != nil else { return }
      path.move(to: self.points[self.selectedPoints[0]])

      self.selectedPoints.forEach { selectedPoint in
        path.addLine(to: self.points[selectedPoint])
      }

      if let gestureLocation {
        path.addLine(to: gestureLocation)
      }

    }
    .stroke(
      strokeColor(),
      style: StrokeStyle(
        lineWidth: lineWidth,
        lineCap: .round,
        lineJoin: .round
      )
    )
  }

  public init(
    state: Binding<GraphicalPasswordState>
  ) {
    self._state = state
  }

  private func pointColor(_ point: Int) -> Color {
    switch state {
    case .initial, .drawing, .drawn:
      if selectedPoints.contains(point) {
        return selectedPointColor
      } else {
        return pointColor
      }

    case .success:
      return successPointColor

    case .error:
      return errorPointColor
    }
  }

  private func strokeColor() -> Color {
    switch state {
    case .initial, .drawing, .drawn:
      return lineColor

    case .success:
      return successLineColor

    case .error:
      return errorLineColor
    }
  }

  @ViewBuilder
  private func point(row: Int, column: Int) -> some View {
    GeometryReader { geometryProxy in
      Circle()
        .fill(pointColor(values[row][column]))
        .onAppear {
          let frame = geometryProxy.frame(in: .named(Self.spaceName))
          points[values[row][column]] = frame.center
        }
        .onChange(
          of: geometryProxy.frame(in: .named(Self.spaceName))
        ) { frame in
          points[values[row][column]] = frame.center
        }
    }
    .frame(width: pointRadius, height: pointRadius)
    .scaleEffect(scalePoints.contains(values[row][column]) ? scaleEffectForSelectedPoint : 1)
  }

  private func isGestureLocationInsidePoint(center: CGPoint, radius: CGFloat, point: CGPoint) -> Bool {
    let distance = sqrt(pow(point.x - center.x, 2) + pow(point.y - center.y, 2))
    return distance <= radius
  }
}

#Preview {
  TestView()
}

struct TestView: View {

  @State private var graphicalPasswordState: GraphicalPasswordState = .initial

  var body: some View {
    NavigationView {
      GeometryReader { reader in
        GraphicalPasswordView(state: $graphicalPasswordState)
          .onDrawEnded { password in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
              if password == "123654789" {
                graphicalPasswordState = .success
              } else {
                graphicalPasswordState = .error
              }
            }
          }
          .padding(.horizontal, 32)
          .padding(.bottom, 32 - reader.safeAreaInsets.bottom)
          .navigationTitle("Graphical password")
          .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}

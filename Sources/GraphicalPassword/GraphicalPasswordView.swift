//
//  GraphicalPasswordView.swift
//
//  Created by Savva Shuliatev.
//

import SwiftUI

@MainActor
public enum GraphicalPasswordState {
  case def
  case drawing
  case drawn
  case success
  case error
}

@MainActor
public struct GraphicalPasswordView: View {

  @Binding var state: GraphicalPasswordState

  @State private var gestureLocation: CGPoint?

  public var body: some View {
    ZStack {
      circles

      Path { path in
        guard self.selectedPoints.first != nil else { return }
        path.move(to: self.points[self.selectedPoints[0]].center)

        self.selectedPoints.forEach { selectedPoint in
          path.addLine(to: self.points[selectedPoint].center)
        }

        if let gestureLocation {
          path.addLine(to: gestureLocation)
        }

      }
      .stroke(
        self.color(for: 0, isLine: true),
        style: StrokeStyle(
          lineWidth: 1,
          lineCap: .round,
          lineJoin: .round
        )
      )
    }
    .coordinateSpace(name: Self.spaceName)
    .gesture(
      DragGesture(coordinateSpace: .named(Self.spaceName))
        .onChanged { value in
          //guard self.success == nil else { return }
          self.gestureLocation = value.location

          for (index, rect) in self.points.enumerated() {
            let bindArea: CGRect

            if self.selectedPoints.first == nil {
              bindArea = CGRect(
                x: rect.minX - 35,
                y: rect.minY - 35,
                width: rect.width + 70,
                height: rect.height + 70
              )

            } else {
              bindArea = CGRect(
                x: rect.minX - 22,
                y: rect.minY - 22,
                width: rect.width + 44,
                height: rect.height + 44
              )
            }

            if bindArea.contains(value.location) {
              if !selectedPoints.contains(index) {
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
        }
        .onEnded { _ in
          if selectedPoints.first != nil {}
          gestureLocation = nil
        }
    )
  }

  @State private var points: [CGRect] = Array(repeating: .zero, count: 9)
  @State private var scalePoints: [Int] = []
  private let values = [[0, 1, 2], [3, 4, 5], [6, 7, 8]]
  @State private var selectedPoints: [Int] = []

  
  private func color(for point: Int, isLine: Bool = false) -> Color {
    if true {
      return true ? Color.green : Color.red
    }

    if self.selectedPoints.contains(point) || isLine {
      return Color.blue
    }

    return Color.gray
  }

  @ViewBuilder
  private var circles: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        Color.red
        VStack(spacing: 0) {
          ForEach(0..<3) { row in
            HStack(spacing: 0) {
              ForEach(0..<3) { column in
                Rectangle()
                  .fill((column % 2 == 1 && row % 2 == 0) ? Color.red : Color.blue)
                  .overlay(point(row: row, column: column))
                  .frame(width: geometry.size.width / 3, height: geometry.size.width / 3)
              }
            }
          }
        }
      }
    }
  }

  @ViewBuilder 
  private func point(row: Int, column: Int) -> some View {
    GeometryReader { circleGeometry in
      Circle()
        .fill(color(for: values[row][column]))
        .onAppear {
          let frame = circleGeometry.frame(in: .named(Self.spaceName))
          points[values[row][column]] = frame
        }
        .onChange(
          of: circleGeometry.frame(in: .named(Self.spaceName))
        ) { frame in
          points[values[row][column]] = frame
        }
    }
    .frame(width: 12, height: 12)
    .scaleEffect(scalePoints.contains(values[row][column]) ? 2 : 1)
  }

  public static let spaceName = "GraphicalPasswordView.spaceName"

  public init(
    state: Binding<GraphicalPasswordState>
  ) {
    self._state = state
  }
}

#Preview {
  GraphicalPasswordView(state: .constant(.drawing))
}

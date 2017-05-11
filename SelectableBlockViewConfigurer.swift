//  Created by Laura Skelton on 3/14/17.
//  Copyright © 2017 Airbnb. All rights reserved.

import UIKit

public protocol SelectableBlockViewConfigurerDelegate: class {
  func didSelect(dataID: String)
}

// MARK: SelectableBlockViewConfigurer

/// A flexible `ListItem` class for configuring views of a specific type with data of a specific type,
/// using blocks for creation and configuration. This was designed to be used in a `ListInterface`
/// to lazily create and configure views as they are recycled in a `UITableView` or `UICollectionView`.
public class SelectableBlockViewConfigurer<ViewType, DataType>: ViewConfigurer where
  ViewType: UIView,
  DataType: Equatable
{
  // MARK: Lifecycle

  /**
   Initializes a `ListItem` that creates and configures a specific type of view for display in a `ListInterface`.

   - Parameters:
   - builder: Something that returns this view type. It will be wrapped in a closure and called as needed to lazily create views.
   - configurer: A closure that configures this view type with the specified data type.
   - data: The data this view takes for configuration, specific to this particular list item instance.
   - dataID: An optional ID to differentiate this row from other rows, used when diffing.

   - Returns: A `ListItem` instance that will create the specified view type with this data.
   */
  public init(
    builder: @escaping @autoclosure () -> ViewType,
    configurer: @escaping (ViewType, DataType) -> Void,
    data: DataType,
    selectionDelegate: SelectableBlockViewConfigurerDelegate,
    dataID: String)
  {
    self.data = data
    self.builder = builder
    self.configurer = configurer
    self.selectionDelegate = selectionDelegate
    self.dataID = dataID
  }

  // MARK: Public

  public private(set) weak var selectionDelegate: SelectableBlockViewConfigurerDelegate?
  public let dataID: String
  public let data: DataType
  public let isSelectable = true

  public func isDiffableItemEqual(to otherDiffableItem: Diffable) -> Bool {
    if let other = otherDiffableItem as? SelectableBlockViewConfigurer<ViewType, DataType> {
      return self.data == other.data
    } else {
      return false
    }
  }

  public func makeView() -> ViewType {
    return builder()
  }

  public func configureView(_ view: ViewType, animated: Bool) {
    configurer(view, data)
  }

  public func didSelect() {
    selectionDelegate?.didSelect(dataID: dataID)
  }

  // MARK: Private

  private let builder: () -> ViewType
  private let configurer: (ViewType, DataType) -> Void
}

extension BlockConfigurableView where
  Self: UIView,
  Self.Data: Equatable
{
  /**
   A convenience method to create a `ListItem` that creates and configures this type of view for display in a `ListInterface`.

   - Parameter builder: Something that returns this view type. It will be wrapped in a closure and called as needed to lazily create views.
   - Parameter data: The data this view takes for configuration, specific to this particular list item instance.
   - Parameter dataID: An optional ID to differentiate this row from other rows, used when diffing.

   - Returns: A `ListItem` instance that will create the specified view type with this data.

   - Note: The `builder` parameter will be wrapped in a closure automatically. The view will not be created until it is needed.
   */
  public static func selectable(
    builder: @escaping @autoclosure () -> Self,
    data: Data,
    selectionDelegate: SelectableBlockViewConfigurerDelegate,
    dataID: String) -> SelectableBlockViewConfigurer<Self, Data>
  {
    return SelectableBlockViewConfigurer<Self, Data>(
      builder: builder,
      configurer: { view, data in
        Self.configureView(view, with: data)
    },
      data: data,
      selectionDelegate: selectionDelegate,
      dataID: dataID)
  }

  /**
   A convenience method to create a `ListItem` that creates and configures this type of view for display in a `ListInterface`.

   - Parameter data: The data this view takes for configuration, specific to this particular list item instance.
   - Parameter dataID: An optional ID to differentiate this row from other rows, used when diffing.

   - Returns: A `ListItem` instance that will create the specified view type with this data.

   - Note: This uses an empty `init()` to create the view. Don't use this if you need to use a different `init()`.
   */
  public static func selectable(
    data: Data,
    selectionDelegate: SelectableBlockViewConfigurerDelegate,
    dataID: String) -> SelectableBlockViewConfigurer<Self, Data>
  {
    return SelectableBlockViewConfigurer<Self, Data>(
      builder: Self(),
      configurer: { view, data in
        Self.configureView(view, with: data)
    },
      data: data,
      selectionDelegate: selectionDelegate,
      dataID: dataID)
  }
}
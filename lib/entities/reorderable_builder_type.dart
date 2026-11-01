/// Type of ReorderableBuilder, set by the used constructor.
enum ReorderableBuilderType {
  /// ReorderableBuilder with children (e.g. GridView, GridView.count, ...)
  children,

  /// ReorderableBuilder.builder with a child builder.
  builder,

  /// ReorderableBuilder.wrap with children in a Wrap.
  wrap,
}

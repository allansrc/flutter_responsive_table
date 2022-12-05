import 'package:flutter/material.dart';
import 'package:responsive_context/responsive_context.dart';

import 'responsive_table.dart';

class ResponsiveDatatable extends StatefulWidget {
  final bool showSelect;
  final List<DatatableHeader> headers;
  final List<Map<String, dynamic>> source;

  final Widget? title;
  final String? sortColumn;
  final List<Widget>? actions;
  final List<Widget>? footers;
  final List<Map<String, dynamic>>? selectedValues;

  final Function(dynamic value)? onSort;
  final Function(dynamic value)? onTabRow;
  final Function()? onScrollEnd;
  final Function(bool? value)? onSelectAll;

  final Function(bool? value, Map<String, dynamic> data)? onSelect;

  final bool? isLoading;
  final bool? autoHeight;
  final bool? sortAscending;
  final bool? hideUnderline;

  const ResponsiveDatatable({
    Key? key,
    this.onTabRow,
    this.selectedValues,
    this.title,
    this.onSort,
    this.actions,
    this.footers,
    this.sortColumn,
    this.isLoading = false,
    this.autoHeight = true,
    this.showSelect = false,
    this.hideUnderline = true,
    this.sortAscending = true,
    required this.onSelectAll,
    required this.onSelect,
    required this.headers,
    required this.source,
    this.onScrollEnd,
  }) : super(key: key);

  @override
  _ResponsiveDatatableState createState() => _ResponsiveDatatableState();
}

class _ResponsiveDatatableState extends State<ResponsiveDatatable> {
  Widget mobileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Checkbox(
            value: widget.selectedValues!.length == widget.source.length &&
                widget.source.isNotEmpty,
            onChanged: (value) {
              widget.onSelectAll!(value);
            }),
        PopupMenuButton(
          tooltip: 'SORT BY',
          initialValue: widget.sortColumn,
          itemBuilder: (_) => widget.headers
              .where((header) => header.show == true && header.sortable == true)
              .toList()
              .map((header) => PopupMenuItem(
                    value: header.value,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${header.text}',
                          textAlign: header.textAlign,
                        ),
                        if (widget.sortColumn != null &&
                            widget.sortColumn == header.value)
                          widget.sortAscending!
                              ? Icon(Icons.arrow_downward, size: 15)
                              : Icon(Icons.arrow_upward, size: 15)
                      ],
                    ),
                  ))
              .toList(),
          onSelected: (value) {
            if (widget.onSort != null) widget.onSort!(value);
          },
          child: Container(
            padding: EdgeInsets.all(15),
            child: Text('SORT BY'),
          ),
        )
      ],
    );
  }

  List<Widget> mobileList() {
    return widget.source.map((data) {
      return InkWell(
        onTap: widget.onTabRow != null
            ? () {
                widget.onTabRow!(data);
              }
            : null,
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  if (widget.showSelect && widget.selectedValues != null)
                    Checkbox(
                      value: widget.selectedValues!.contains(data),
                      onChanged: (value) {
                        widget.onSelect!(value, data);
                      },
                    ),
                ],
              ),
              ...widget.headers
                  .where((header) => header.show == true)
                  .toList()
                  .map(
                    (header) => Container(
                      padding: EdgeInsets.all(11),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          header.headerBuilder != null
                              ? header.headerBuilder!(header.value)
                              : Text(
                                  '${header.text}',
                                  overflow: TextOverflow.clip,
                                ),
                          Spacer(),
                          header.sourceBuilder != null
                              ? header.sourceBuilder!(data[header.value], data)
                              : header.editable
                                  ? editAbleWidget(
                                      data: data,
                                      header: header,
                                      textAlign: TextAlign.end,
                                    )
                                  : Text('${data[header.value]}')
                        ],
                      ),
                    ),
                  )
                  .toList()
            ],
          ),
        ),
      );
    }).toList();
  }

  Alignment headerAlignSwitch(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  Widget desktopHeader() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: kElevationToShadow[2],
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showSelect && widget.selectedValues != null)
            Checkbox(
                value: widget.selectedValues!.length == widget.source.length &&
                    widget.source != null &&
                    widget.source.length > 0,
                onChanged: (value) {
                  if (widget.onSelectAll != null) widget.onSelectAll!(value);
                }),
          ...widget.headers
              .where((header) => header.show == true)
              .map(
                (header) => Expanded(
                  flex: header.flex ?? 1,
                  child: InkWell(
                    onTap: () {
                      if (widget.onSort != null && header.sortable!)
                        widget.onSort!(header.value);
                    },
                    child: header.headerBuilder != null
                        ? header.headerBuilder!(header.value)
                        : Container(
                            padding: EdgeInsets.all(11),
                            alignment: headerAlignSwitch(header.textAlign),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '${header.text}',
                                  textAlign: header.textAlign,
                                ),
                                if (widget.sortColumn != null &&
                                    widget.sortColumn == header.value)
                                  widget.sortAscending!
                                      ? Icon(Icons.arrow_downward, size: 15)
                                      : Icon(Icons.arrow_upward, size: 15)
                              ],
                            ),
                          ),
                  ),
                ),
              )
              .toList()
        ],
      ),
    );
  }

  List<Widget> desktopList() {
    var widgets = <Widget>[];
    for (var index = 0; index < widget.source.length; index++) {
      final data = widget.source[index];
      widgets.add(
        InkWell(
          onTap: widget.onTabRow != null
              ? () {
                  widget.onTabRow!(data);
                }
              : null,
          child: Container(
            padding: EdgeInsets.all(widget.showSelect ? 0 : 11),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showSelect && widget.selectedValues != null)
                  Checkbox(
                    value: widget.selectedValues!.contains(data),
                    onChanged: (value) {
                      if (widget.onSelect != null)
                        widget.onSelect!(value, data);
                    },
                  ),
                ...widget.headers
                    .where((header) => header.show == true)
                    .map(
                      (header) => Expanded(
                        flex: header.flex ?? 1,
                        child: header.sourceBuilder != null
                            ? header.sourceBuilder!(data[header.value], data)
                            : header.editable
                                ? editAbleWidget(
                                    data: data,
                                    header: header,
                                    textAlign: header.textAlign,
                                  )
                                : Container(
                                    child: Text(
                                      '${data[header.value]}',
                                      textAlign: header.textAlign,
                                    ),
                                  ),
                      ),
                    )
                    .toList()
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget editAbleWidget({
    required Map<String, dynamic> data,
    required DatatableHeader header,
    TextAlign textAlign = TextAlign.center,
  }) {
    return Container(
      constraints: BoxConstraints(maxWidth: 150),
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(0),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          border: widget.hideUnderline!
              ? InputBorder.none
              : UnderlineInputBorder(borderSide: BorderSide(width: 1)),
          alignLabelWithHint: true,
        ),
        textAlign: textAlign,
        controller: TextEditingController.fromValue(
          TextEditingValue(text: '${data[header.value]}'),
        ),
        onChanged: (newValue) => data[header.value] = newValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return context.isExtraSmall || context.isSmall || context.isMedium
        ?
        /**
         * for small screen
         */
        Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //title and actions
                if (widget.title != null || widget.actions != null)
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.title != null) widget.title!,
                        if (widget.actions != null) ...widget.actions!,
                      ],
                    ),
                  ),

                if (widget.autoHeight!)
                  Column(
                    children: [
                      if (widget.showSelect && widget.selectedValues != null)
                        mobileHeader(),
                      if (widget.isLoading!) LinearProgressIndicator(),
                      //mobileList
                      ...mobileList(),
                    ],
                  ),
                if (!widget.autoHeight!)
                  Expanded(
                    child: Container(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                            widget.onScrollEnd?.call();
                          }
                          return true;
                        },
                        child: ListView(
                          // itemCount: source.length,
                          children: [
                            if (widget.showSelect &&
                                widget.selectedValues != null)
                              mobileHeader(),
                            if (widget.isLoading!) LinearProgressIndicator(),
                            //mobileList
                            ...mobileList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                //footer
                if (widget.footers != null)
                  Container(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (widget.footers != null) ...widget.footers!
                      ],
                    ),
                  )
              ],
            ),
          )
        /**
          * for large screen
          */
        : Container(
            child: Column(
              children: [
                //title and actions
                if (widget.title != null || widget.actions != null)
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.title != null) widget.title!,
                        if (widget.actions != null) ...widget.actions!
                      ],
                    ),
                  ),

                //desktopHeader
                if (widget.headers.isNotEmpty) desktopHeader(),

                if (widget.isLoading!) LinearProgressIndicator(),

                if (widget.autoHeight!) Column(children: desktopList()),

                if (!widget.autoHeight!)
                  // desktopList
                  if (widget.source.isNotEmpty)
                    Expanded(
                        child: Container(
                            child: NotificationListener(
                                onNotification:
                                    (ScrollNotification scrollInfo) {
                                  if (scrollInfo.metrics.pixels ==
                                      scrollInfo.metrics.maxScrollExtent) {
                                    widget.onScrollEnd?.call();
                                  }
                                  return true;
                                },
                                child: ListView(children: desktopList())))),

                //footer
                if (widget.footers != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [if (widget.footers != null) ...widget.footers!],
                  )
              ],
            ),
          );
  }
}

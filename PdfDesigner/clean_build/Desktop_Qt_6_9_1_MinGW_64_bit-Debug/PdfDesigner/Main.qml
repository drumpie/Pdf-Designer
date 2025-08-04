import QtQuick
import QtQuick.Controls
import QtQuick.Pdf
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls.Universal

ApplicationWindow {
    Universal.theme: Universal.Dark
    Universal.accent: Universal.Taupe
    Universal.background: Universal.Taupe
    id: root
    width: 1024
    height: 720
    visible: true
    title: doc.title
    // color: "#2f4f4f"
    property string source


    // HEADER
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.rightMargin: 6
            ToolButton {
                z: 4
                action: Action {
                    shortcut: StandardKey.Open

                    onTriggered: fileDialog.open()
                    text: "Open PDF"
                }
                // icon.source: "qrc:/media/openFile.svg"
            }
            // Zoom In Butonu
            ToolButton {
                action: Action {
                    shortcut: StandardKey.ZoomIn
                    // shortcut: "Ctrl+mwheelup"
                    // shortcut: "Ctrl+="
                    enabled: view.renderScale < 10
                    // icon.source: "qrc:/media/zoomIn.svg"
                    text: "Zoom In"
                    onTriggered: view.renderScale *= Math.sqrt(2)
                }
                enabled: doc.status === PdfDocument.Ready
            }
            // Zoom Out Butonu
            ToolButton {
                action: Action {
                    shortcut: StandardKey.ZoomOut
                    enabled: view.renderScale > 0.1
                    // icon.source: "qrc:/media/zoomOut.svg"
                    text: "Zoom Out"
                    onTriggered: view.renderScale /= Math.sqrt(2)
                }
                enabled: doc.status === PdfDocument.Ready
            }
            // Scale to Width Butonu
            ToolButton {
                action: Action {
                    // icon.source: ""
                    text: "Scale to Width"
                    onTriggered: view.scaleToWidth(root.contentItem.width,
                                                   root.contentItem.height)
                }
                enabled: doc.status === PdfDocument.Ready
            }
            // Scale to Page Butonu
            ToolButton {
                action: Action {
                    // icon.source: ""
                    text: "Scale to Page"
                    onTriggered: view.scaleToPage(root.contentItem.width,
                                                  root.contentItem.height)
                }
                enabled: doc.status === PdfDocument.Ready
            }
            // Zoom Reset Butonu
            ToolButton {
                action: Action {
                    shortcut: "Ctrl+0"
                    text: "Zoom Reset"
                    enabled: view.renderScale > 0.1
                    // icon.source: ""
                    onTriggered: view.resetScale()
                }
                enabled: doc.status === PdfDocument.Ready
            }
            // Sayfayı Sola Döndürme Butonu
            ToolButton {
                action: Action {
                    shortcut: "Ctrl+L"
                    text: "Page to Left"
                    // icon.source: ""
                    onTriggered: view.pageRotation -= 90
                }
                enabled: doc.status === PdfDocument.Ready
            }
            // Sayfayı Sağa Döndürme Butonu
            ToolButton {
                action: Action {
                    shortcut: "Ctrl+R"
                    text: "Page to Right"
                    // icon.source: ""
                    onTriggered: view.pageRotation += 90
                }
                enabled: doc.status === PdfDocument.Ready
            }
            // Geri(Back) Butonu
            ToolButton {
                action: Action {
                    // icon.source: ""
                    text: "Back"
                    enabled: view.backEnabled
                    onTriggered: view.back()
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 2000
                ToolTip.text: "Go Back"
                enabled: doc.status === PdfDocument.Ready
            }
            SpinBox {
                            id: currentPageSB
                            from: 1
                            to: doc.pageCount
                            editable: true
                            enabled: doc.status === PdfDocument.Ready
                            onValueModified: view.goToPage(value - 1)
                            Shortcut {
                                sequence: StandardKey.MoveToPreviousPage
                                onActivated: view.goToPage(currentPageSB.value - 2)
                            }
                            Shortcut {
                                sequence: StandardKey.MoveToNextPage
                                onActivated: view.goToPage(currentPageSB.value)
                            }
                        }

            ToolButton {
                action: Action {
                    text: "Forward"
                    // icon.source: ""
                    enabled: view.forwardEnabled
                    onTriggered: view.forward()
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 2000
                ToolTip.text: "Go Forward"
                enabled: doc.status === PdfDocument.Ready
            }
            ToolButton {
                action: Action {
                    text: "Select All"
                    shortcut: StandardKey.SelectAll
                    // icon.source: ""
                    onTriggered: view.selectAll()
                }
                enabled: doc.status === PdfDocument.Ready
            }
            ToolButton {
                action: Action {
                    text: "Copy"
                    shortcut: StandardKey.Copy
                    // icon.source: ""
                    enabled: view.selectedText !== ""
                    onTriggered: view.copySelectionToClipboard()
                }
            }
            Shortcut {
                sequence: StandardKey.Find
                onActivated: {
                    searchField.forceActiveFocus()
                    searchField.selectAll()
                }
            }
            Shortcut {
                sequence: StandardKey.Quit
                onActivated: Qt.quit()
            }

            // NOT BURAYA TEKRAR BAK //
            // Rectangle {
            Dialog {
                id: passwordDialog
                title: "Password"
                standardButtons: Dialog.Ok | Dialog.Cancel
                modal: true
                closePolicy: Popup.CloseOnEscape
                // anchors.centerIn: parent
                width: 300

                // Info Sekmesi
                contentItem: TextField {
                    id: passwordField
                    placeholderText: qsTr("Enter password")
                    echoMode: TextInput.Password
                    width: parent.width
                    enabled: doc.status === PdfDocument.Ready
                    onAccepted: passwordDialog.accept()
                }
                onOpened: passwordField.forceActiveFocus()
                onAccepted: doc.password = passwordField.text
            }

            Dialog {
                id: errorDialog
                title: "Error loading " + doc.source
                standardButtons: Dialog.Close
                modal: true
                closePolicy: Popup.CloseOnEscape
                anchors.centerIn: parent
                width: 300
                visible: doc.status === PdfDocument.Error
                opacity: enabled ? 1.0 : 0.5

                contentItem: Label {
                    id: errorField
                    text: doc.error
                }
            }

            Dialog {
                id: noPdfDialog
                title: "PDF Not Loaded"
                standardButtons: Dialog.Ok
                modal: true
                closePolicy: Popup.CloseOnEscape
                contentItem: Label {
                    text: "Add a PDF First."
                    wrapMode: Text.WordWrap
                }
            }

            // Rectangle{


            // Flickable{
            // id: flickable
            // anchors.fill: parent
            // contentWidth: view.implicitWidth
            // contentHeight: view.implicitHeight
            // clip: true


            // Side Bar
            Drawer {
                id: sidebar
                edge: Qt.LeftEdge

                // Popup{
                // id: popup
                // visible: true
                // }

                // opacity: 0,1
                modal: true
                width: view.width / 4
                height: root.height
                dim: true
                clip: true
                z: 10

                // contentHeight: parent.height
                // contentWidth: parent.width / 2
                TabBar {
                    id: sidebarTabs
                    x: -width
                    rotation: -90
                    transformOrigin: Item.TopRight
                    currentIndex: 2 // bookmarks by default

                    // TabButton {
                    // text: qsTr("Exit")
                    // onClicked: sidebar.close
                    // }
                    FileDialog {
                        id: fileDialog
                        title: "Open a PDF file"
                        nameFilters: ["PDF files (*.pdf)"]
                        onAccepted: doc.source = selectedFile
                    }
                    TabButton {
                        text: qsTr("Info")
                    }
                    TabButton {
                        text: qsTr("Search Results")
                    }
                    TabButton {
                        text: qsTr("Bookmarks")
                    }
                    TabButton {
                        text: qsTr("Pages")
                    }
                }
                StackLayout {
                    width: parent.width
                    currentIndex: bar.currentIndex
                    Item {
                        id: pages
                    }
                    Item {
                        id: bookmarks
                    }
                    Item {
                        id: searchresults
                    }
                    Item {
                        id: info
                    }
                    Item {
                        id: openpdf
                    }
                }

                GroupBox {
                    anchors.fill: parent
                    anchors.leftMargin: sidebarTabs.height

                    StackLayout {
                        anchors.fill: parent
                        currentIndex: sidebarTabs.currentIndex
                        component InfoField: TextInput {
                            width: parent.width
                            selectByMouse: true
                            readOnly: true
                            wrapMode: Text.WordWrap
                        }
                        Column {
                            spacing: 6
                            width: parent.width - 6
                            Label {
                                font.bold: true
                                text: qsTr("Title")
                            }
                            InfoField {
                                text: doc.title
                            }
                            Label {
                                font.bold: true
                                text: qsTr("Author")
                            }
                            InfoField {
                                text: doc.author
                            }
                            Label {
                                font.bold: true
                                text: qsTr("Subject")
                            }
                            InfoField {
                                text: doc.subject
                            }
                            Label {
                                font.bold: true
                                text: qsTr("Keywords")
                            }
                            InfoField {
                                text: doc.keywords
                            }
                            Label {
                                font.bold: true
                                text: qsTr("Producer")
                            }
                            InfoField {
                                text: doc.producer
                            }
                            Label {
                                font.bold: true
                                text: qsTr("Creator")
                            }
                            InfoField {
                                text: doc.creator
                            }
                            Label {
                                font.bold: true
                                text: qsTr("Creation date")
                            }
                            InfoField {
                                text: doc.creationDate
                            }
                            Label {
                                font.bold: true
                                text: qsTr("Modification date")
                            }
                            InfoField {
                                text: doc.modificationDate
                            }
                        }

                        // Search Results Sekmesi
                        ListView {
                            id: searchResultsList
                            implicitHeight: parent.height
                            model: view.searchModel
                            enabled: doc.status === PdfDocument.Ready
                            currentIndex: view.searchModel.currentResult
                            ScrollBar.vertical: ScrollBar {}
                            delegate: ItemDelegate {
                                id: resultDelegate
                                required property int index
                                required property int page
                                required property string contextBefore
                                required property string contextAfter
                                width: parent ? parent.width : 0
                                RowLayout {
                                    // anchors.fill: parent
                                    spacing: 0
                                    Label {
                                        text: "Page " + (resultDelegate.page + 1) + ": "
                                    }
                                    Label {
                                        text: resultDelegate.contextBefore
                                        elide: Text.ElideLeft
                                        horizontalAlignment: Text.AlignRight
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: parent.width / 2
                                    }
                                    Label {
                                        font.bold: true
                                        text: view.searchString
                                        width: implicitWidth
                                    }
                                    Label {
                                        text: resultDelegate.contextAfter
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: parent.width / 2
                                    }
                                }
                                highlighted: ListView.isCurrentItem
                                onClicked: view.searchModel.currentResult = resultDelegate.index
                            }
                        }

                        // Bookmarks Sekmesi
                        TreeView {
                            id: bookmarksTree
                            implicitHeight: parent.height
                            implicitWidth: parent.width
                            enabled: doc.status === PdfDocument.Ready
                            columnWidthProvider: function () {
                                return width
                            }
                            delegate: TreeViewDelegate {
                                required property int page
                                required property point location
                                required property real zoom
                                onClicked: view.goToLocation(page,
                                                             location, zoom)
                            }
                            model: PdfBookmarkModel {
                                document: doc
                            }
                            ScrollBar.vertical: ScrollBar {}
                        }

                        // Thumbnails Sekmesi
                        GridView {
                            id: thumbnailsView
                            implicitWidth: parent.width
                            implicitHeight: parent.height
                            model: doc.pageModel
                            enabled: doc.status === PdfDocument.Ready
                            // opacity: enabled ? 1.0 : 0.5
                            cellWidth: width / 2
                            cellHeight: cellWidth + 10
                            delegate: Item {
                                required property int index
                                required property string label
                                required property size pointSize
                                width: thumbnailsView.cellWidth
                                height: thumbnailsView.cellHeight
                                Rectangle {
                                    id: paper
                                    width: image.width
                                    height: image.height
                                    x: (parent.width - width) / 2
                                    y: (parent.height - height - pageNumber.height) / 2
                                    PdfPageImage {
                                        id: image
                                        document: doc
                                        currentFrame: index
                                        asynchronous: true
                                        fillMode: Image.PreserveAspectFit
                                        property bool landscape: pointSize.width > pointSize.height
                                        width: landscape ? thumbnailsView.cellWidth - 6 : height
                                                           * pointSize.width / pointSize.height
                                        height: landscape ? width * pointSize.height / pointSize.width : thumbnailsView.cellHeight - 14
                                        sourceSize.width: width
                                        sourceSize.height: height
                                    }
                                }
                                Text {
                                    id: pageNumber
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: label
                                }
                                TapHandler {
                                    onTapped: view.goToPage(index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    PdfDocument {
        id: doc
        source: Qt.resolvedUrl(root.source)
        onPasswordRequired: passwordDialog.open()
    }
    PdfMultiPageView {
        id: view
        z: -5
        anchors.fill: parent
        anchors.leftMargin: sidebar.position * sidebar.width
        width: implicitWidth
        height: implicitHeight
        document: doc
        searchString: searchField.text
        onCurrentPageChanged: currentPage.value = view.currentPageSB + 1
    }

    // }
    DropArea {
        anchors.fill: parent
        keys: ["text/uri-list"]
        onEntered: drag => {
                       drag.accepted = (drag.proposedAction === Qt.MoveAction
                                        || drag.proposedAction === Qt.CopyAction)
                       && drag.hasUrls && drag.urls[0].endsWith("pdf")
                   }
        onDropped: drop => {
                       doc.source = drop.urls[0]
                       drop.acceptProposedAction()
                   }
    }
    // z:-2
    //     }

    // FOOTER
    footer: ToolBar {

        height: rowFooter.implicitHeight
        RowLayout {
            id: rowFooter
            anchors.fill: parent
            ToolButton {
                action: Action {
                    id: sidebarOpenAction
                    checkable: true
                    checked: sidebar.opened
                    // icon.source: checked ? ""
                    onTriggered: {
                        if (doc.status === PdfDocument.Ready) {
                            sidebar.open()
                        } else {
                            noPdfDialog.open()
                        }
                    }
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 2000
                ToolTip.text: "Open Sidebar"
                text: "Open Sidebar"
                enabled: doc.status === PdfDocument.Ready
            }
            ToolButton {
                action: Action {
                    // icon.source: ""
                    shortcut: StandardKey.FindPrevious
                    enabled: view.searchModel.count > 0
                    onTriggered: view.searchBack()
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 2000
                ToolTip.text: "Find Previous"
                text: "Find Previous"
            }
            // Footer'daki Arama Kutusu
            TextField {
                id: searchField
                // icon.name: "search"
                placeholderText: "Search"
                Layout.alignment: parent.right
                Layout.minimumWidth: 100
                enabled: doc.status === PdfDocument.Ready
                // Layout.maximumWidth: 300
                Layout.fillWidth: true
                Layout.bottomMargin: 3
                onAccepted: {
                    sidebar.open()
                    sidebarTabs.setCurrentIndex(1)
                }
                Image {
                    visible: searchField.text !== ""
                    // source: ""
                    sourceSize.height: searchField.height - 6
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: 3
                    }
                    TapHandler {
                        onTapped: searchField.clear()
                    }
                }
            }

            ToolButton {
                icon.source: "qrc:/media/zoomIn.svg"
                action: Action {
                    // icon.source: ""
                    shortcut: StandardKey.FindNext
                    enabled: view.searchModel.count > 0
                    onTriggered: view.searchForward()
                }
                ToolTip.visible: enabled && hovered
                ToolTip.delay: 2000
                ToolTip.text: "Find Next"
                text: "Find Next"
            }
            Label {
                id: statusLabel
                property size implicitPointSize: doc.pagePointSize(
                                                     view.currentPage)
                text: "page " + (currentPageSB.value) + " of "
                      + doc.pageCount + " scale " + view.renderScale.toFixed(2)
                      + " original " + implicitPointSize.width.toFixed(
                          1) + "x" + implicitPointSize.height.toFixed(1) + " pt"
                visible: doc.pageCount > 0
            }
        }
    }
}

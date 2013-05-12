/*
 *  Copyright 2013 Ruediger Gad
 *
 *  This file is part of Q To-Do.
 *
 *  Q To-Do is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Q To-Do is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Q To-Do.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import qtodo 1.0
import "../common"

Item {
    id: imapAccountSettingsSheet
    anchors.bottom: parent.bottom
    anchors.top: parent.bottom
    width: parent.width

    visible: false
    z: 1

    property int currentAccountId: -1

    signal closed()
    signal closing()
    signal opened()
    signal opening()
    signal accepted()

    function finished(){
        console.log("finished")
        if(state === "closed"){
            visible = false
            closed()
        }else{
            opened()
        }
    }

    function close(){
        closing()
        state = "closed"
    }

    function open(){
        console.log("open")

        visible = true

        opening()
        state = "open"
    }

    onStateChanged: {
        console.log("Imap account settings state changed: " + state)
    }

    states: [
        State {
            name: "open"
            AnchorChanges { target: imapAccountSettingsSheet; anchors.top: parent.top }
        },
        State {
            name: "closed"
            AnchorChanges { target: imapAccountSettingsSheet; anchors.top: parent.bottom }
        }
    ]

    transitions: Transition {
        SequentialAnimation {
            AnchorAnimation { duration: 250; easing.type: Easing.OutCubic }
            ScriptAction { script: imapAccountSettingsSheet.finished() }
        }
    }

    Rectangle {
        id: buttonBar
        anchors.top: parent.top
        height: rejectButton.height + 6
        width: parent.width
        z: 4

        color: "lightgray"

        CommonButton{
            id: rejectButton
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "Cancel"
            onClicked: imapAccountSettingsSheet.close();
        }

        Text {id: entryLabel; text: "Entry"; font.pointSize: primaryFontSize; font.capitalization: Font.SmallCaps; font.bold: true; anchors.centerIn: parent}

        CommonButton{
            id: acceptButton
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "OK"
            onClicked: {
                imapAccountSettingsSheet.accepted()
            }
        }
    }

    Rectangle {
        id: inputRectangle

        anchors {top: buttonBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
        color: "white"

        Item {
            anchors {top: parent.top; left: parent.left; leftMargin: primaryFontSize; right: parent.right; rightMargin: primaryFontSize; bottom: parent.bottom}

            Text {
                id: accountsText
                anchors {top: parent.top; topMargin: primaryFontSize * 0.5; left: parent.left; right: parent.right}
                text: "Available Accounts"
                font.pointSize: primaryFontSize * 0.75
                horizontalAlignment: Text.AlignHCenter
            }

            ListView {
                id: accountListView

                anchors {top: accountsText.bottom; topMargin: primaryFontSize * 0.25; horizontalCenter: parent.horizontalCenter}

                width: parent.width * 0.8
                height: parent.height * 0.2

                model: imapAccountListModel
                clip: true

                delegate: Text {
                    id: accountNameText

                    width: parent.width

                    text: accountName

                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAnywhere

                    font.pointSize: primaryFontSize
                    color: "black"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("clicked: " + index)
                            accountListView.currentIndex = index

                            currentAccountId = accountId
                            nameTextField.text = accountName

                            passwordTextField.text = imapAccountHelper.imapPassword(currentAccountId)
                            serverTextField.text = imapAccountHelper.imapServer(currentAccountId)
                            serverPortTextField.text = imapAccountHelper.imapPort(currentAccountId)
                            accountTextField.text = imapAccountHelper.imapUserName(currentAccountId)
                        }
                    }
                }

                highlight: Rectangle {
                    anchors.fill: parent
                    color: gray
                }
            }

            Text {
                id: nameText
                anchors {top: accountListView.bottom; topMargin: primaryFontSize * 0.25; left: parent.left}
                height: nameTextField.height
                text: "Name"
                font.pointSize: primaryFontSize * 0.75
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            CommonTextField {
                id: nameTextField
                anchors {top: accountListView.bottom; topMargin: primaryFontSize * 0.25; left: nameText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                pointSize: primaryFontSize * 0.5
            }

            Text {
                id: accountText
                anchors {top: nameText.bottom; topMargin: primaryFontSize * 0.25; left: parent.left}
                height: accountTextField.height
                text: "Account"
                font.pointSize: primaryFontSize * 0.75
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            CommonTextField {
                id: accountTextField
                anchors {top: nameText.bottom; topMargin: primaryFontSize * 0.25; left: accountText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                pointSize: primaryFontSize * 0.5
            }

            Text {
                id: passwordText
                anchors {top: accountText.bottom; topMargin: primaryFontSize * 0.25; left: parent.left}
                height: passwordTextField.height
                text: "Password"
                font.pointSize: primaryFontSize * 0.75
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            CommonTextField {
                id: passwordTextField
                anchors {top: accountText.bottom; topMargin: primaryFontSize * 0.25; left: passwordText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                pointSize: primaryFontSize * 0.5
            }

            Text {
                id: serverText
                anchors {top: passwordText.bottom; topMargin: primaryFontSize * 0.25; left: parent.left}
                height: serverTextField.height
                text: "Server"
                font.pointSize: primaryFontSize * 0.75
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            CommonTextField {
                id: serverTextField
                anchors {top: passwordText.bottom; topMargin: primaryFontSize * 0.25; left: serverText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                pointSize: primaryFontSize * 0.5
            }

            Text {
                id: serverPortText
                anchors {top: serverText.bottom; topMargin: primaryFontSize * 0.25; left: parent.left}
                height: serverPortTextField.height
                text: "Server Port"
                font.pointSize: primaryFontSize * 0.75
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            CommonTextField {
                id: serverPortTextField
                anchors {top: serverText.bottom; topMargin: primaryFontSize * 0.25; left: serverPortText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                pointSize: primaryFontSize * 0.5
            }
        }

    }

    ImapAccountListModel {
        id: imapAccountListModel
    }

    ImapAccountHelper {
        id: imapAccountHelper
    }
}

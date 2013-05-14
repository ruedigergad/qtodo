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
    property int encryptionSetting: -1

    property bool editAccount: false
    property bool newAccount: false

    signal closed()
    signal closing()
    signal opened()
    signal opening()
    signal accepted()

    function finished() {
        console.log("finished")
        if(state === "closed"){
            visible = false
            closed()
        }else{
            opened()
        }
    }

    function clearTextFields() {
        accountNameTextField.text = ""
        passwordTextField.text = ""
        userNameTextField.text = ""
        serverTextField.text = ""
        serverPortTextField.text = ""
    }

    function close() {
        closing()

        clearTextFields()

        state = "closed"
    }

    function open() {
        console.log("open")
        opening()

        visible = true

        currentAccountId = -1
        editAccount = false
        newAccount = false
        accountListView.currentIndex = -1

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

        Text {id: entryLabel; text: "Sync Accounts"; font.pointSize: primaryFontSize * 0.75
              font.capitalization: Font.SmallCaps; font.bold: true; anchors.centerIn: parent}

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
            id: contentItem

            anchors {top: parent.top; left: parent.left; leftMargin: primaryFontSize;
                     right: parent.right; rightMargin: primaryFontSize; bottom: parent.bottom}

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
                highlightFollowsCurrentItem: true

                delegate: Text {
                    id: listDelegate
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

                            editAccount = false
                            newAccount = false

                            currentAccountId = accountId
                            accountNameTextField.text = accountName

                            passwordTextField.text = imapAccountHelper.imapPassword(currentAccountId)
                            serverTextField.text = imapAccountHelper.imapServer(currentAccountId)
                            serverPortTextField.text = imapAccountHelper.imapPort(currentAccountId)
                            userNameTextField.text = imapAccountHelper.imapUserName(currentAccountId)

                            encryptionSetting = imapAccountHelper.encryptionSetting(currentAccountId)
                        }
                    }
                }

                highlight: Rectangle {
                    anchors.fill: listDelegate
                    color: "gray"
                }
            }

            Row {
                id: actionButtonRow
                anchors {top: accountListView.bottom; topMargin: primaryFontSize * 0.25; left: parent.left}
                height: newButton.height
                width: parent.width

                CommonButton {
                    id: newButton
                    text: "New"
                    width: parent.width / 3
                    onClicked: {
                        accountListView.currentIndex = -1
                        clearTextFields()
                        editAccount = true
                        newAccount = true
                        encryptionSetting = 1
                    }
                }

                CommonButton {
                    id: editButton
                    text: "Edit"
                    width: parent.width / 3
                    enabled: accountListView.currentIndex > -1
                    onClicked: {
                        editAccount = true
                    }
                }

                CommonButton {
                    id: saveButton
                    text: "Save"
                    width: parent.width / 3
                    enabled: editAccount || newAccount
                    onClicked: {
                        if (newAccount) {
                            console.log("Creating new account...")
                            imapAccountHelper.addAccount(accountNameTextField.text, userNameTextField.text,
                                                            passwordTextField.text, serverTextField.text,
                                                            serverPortTextField.text, encryptionSetting)
                        } else if (editAccount) {
                            console.log("Updating account...")
                            imapAccountHelper.updateAccount(currentAccountId, userNameTextField.text,
                                                            passwordTextField.text, serverTextField.text,
                                                            serverPortTextField.text, encryptionSetting)
                        }
                    }
                }
            }

            Text {
                id: accountNameText
                anchors {top: actionButtonRow.bottom; topMargin: primaryFontSize * 0.25; left: parent.left}
                height: accountNameTextField.height
                text: "Account Name"
                font.pointSize: primaryFontSize * 0.75
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            CommonTextField {
                id: accountNameTextField
                anchors {top: actionButtonRow.bottom; topMargin: primaryFontSize * 0.25;
                         left: accountNameText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                pointSize: primaryFontSize * 0.5
                enabled: newAccount
            }

            Text {
                id: userNameText
                anchors {top: accountNameText.bottom; topMargin: primaryFontSize * 0.25; left: parent.left}
                height: userNameTextField.height
                text: "User Name"
                font.pointSize: primaryFontSize * 0.75
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            CommonTextField {
                id: userNameTextField
                anchors {top: accountNameText.bottom; topMargin: primaryFontSize * 0.25;
                         left: userNameText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                pointSize: primaryFontSize * 0.5
                enabled: editAccount
            }

            Text {
                id: passwordText
                anchors {top: userNameText.bottom; topMargin: primaryFontSize * 0.25; left: parent.left}
                height: passwordTextField.height
                text: "Password"
                font.pointSize: primaryFontSize * 0.75
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            CommonTextField {
                id: passwordTextField
                anchors {top: userNameText.bottom; topMargin: primaryFontSize * 0.25;
                         left: passwordText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                pointSize: primaryFontSize * 0.5
                echoMode: TextInput.Password
                enabled: editAccount
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
                anchors {top: passwordText.bottom; topMargin: primaryFontSize * 0.25;
                         left: serverText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                pointSize: primaryFontSize * 0.5
                enabled: editAccount
            }

            Row {
                anchors {top: serverText.bottom; topMargin: primaryFontSize * 0.25}
                width: parent.width

                Text {
                    id: serverPortText
                    height: serverPortTextField.height
                    width: parent.width / 6
                    text: "Port"
                    font.pointSize: primaryFontSize * 0.75
                    horizontalAlignment: Text.AlignHLeft
                    verticalAlignment: Text.AlignVCenter
                }

                CommonTextField {
                    id: serverPortTextField
                    width: parent.width / 6
                    pointSize: primaryFontSize * 0.5
                    enabled: editAccount
                }

                CommonButton {
                    id: sslButton
                    text: "SSL"
                    width: parent.width / 3
                    enabled: encryptionSetting != 1
                    onClicked: encryptionSetting = 1
                }

                CommonButton {
                    id: startTlsButton
                    text: "STARTTLS"
                    width: parent.width / 3
                    enabled: encryptionSetting != 2
                    onClicked: encryptionSetting = 2
                }
            }
        }
    }

    ImapAccountListModel {
        id: imapAccountListModel
    }

    ImapAccountHelper {
        id: imapAccountHelper
    }

    MouseArea {
        anchors.fill: parent
        z: -1
    }
}

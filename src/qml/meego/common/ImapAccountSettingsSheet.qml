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
import com.nokia.meego 1.0
import "../common"

Sheet {
    id: imapAccountSettingsSheet
    anchors.fill: parent
    visualParent: mainPage

    property int currentAccountId: -1
    property string currentAccountName
    property int encryptionSetting: -1

    property bool editAccount: false
    property bool newAccount: false

    function clearTextFields() {
        accountNameTextField.text = ""
        passwordTextField.text = ""
        userNameTextField.text = ""
        serverTextField.text = ""
        serverPortTextField.text = ""
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

    ConfirmationDialog {
        id: removeAccountConfirmationDialog

        titleText: "Remove account?"
        message: "Delete account " + currentAccountName + "?"

        onAccepted: {
            console.log("Removing account: " + currentAccountId + " - " + currentAccountName)
            imapAccountHelper.removeAccount(currentAccountId)
        }
    }

    onStatusChanged: {
        if (status === DialogStatus.Opening){
            commonTools.enabled = false

            currentAccountId = -1
            editAccount = false
            newAccount = false
            accountListView.currentIndex = -1

            imapAccountListModel.reload()
        }else if (status === DialogStatus.Closed){
            clearTextFields()
            commonTools.enabled = true
        }
    }

    buttons: Item {
        anchors.fill: parent
        SheetButton{
            id: rejectButton
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "Cancel"
            onClicked: imapAccountSettingsSheet.reject();
        }

        SheetButton{
            id: acceptButton
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            platformStyle: SheetButtonAccentStyle { }
            text: "OK"
            onClicked: {
                imapAccountSettingsSheet.accept()
            }
        }
    }

    content: Item {
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

        Rectangle {
            id: accountListViewRectangle
            anchors {top: accountsText.bottom; topMargin: primaryFontSize * 0.25; horizontalCenter: parent.horizontalCenter}

            width: parent.width * 0.8
            height: parent.height * 0.225

            border.color: "gray"
            border.width: primaryFontSize * 0.1
            radius: primaryFontSize * 0.25

            ListView {
                id: accountListView

                anchors.fill: parent

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
                            console.log("Current account id: " + currentAccountId)

                            currentAccountName = accountName
                            accountNameTextField.text = currentAccountName

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
        }

        Text {
            id: infoText

            anchors {top: accountListViewRectangle.bottom; topMargin: primaryFontSize * 0.5
                     left: parent.left; right: parent.right}

            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap

            text: "Please use the accounts app to add, edit, or remove accounts. This is only for setting the default sync account."
            font.pointSize: primaryFontSize * 0.5
        }

        CommonFlickable {
            id: inputFlickable

            anchors {top: infoText.bottom; topMargin: primaryFontSize * 0.5
                     left: parent.left; right: parent.right; bottom: parent.bottom}
            clip: true
            contentHeight: flickableContent.height

            Column {
                id: flickableContent

                anchors {top: parent.top; left: parent.left; right: parent.right}
                spacing: primaryFontSize * 0.1

                Row {
                    width: parent.width
                    height: accountNameTextField.height

                    Text {
                        id: accountNameText
                        anchors.left: parent.left
                        height: parent.height
                        text: "Account Name"
                        font.pointSize: primaryFontSize * 0.75
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    CommonTextField {
                        id: accountNameTextField
                        anchors {left: accountNameText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                        pointSize: primaryFontSize * 0.5
                        enabled: newAccount
                    }
                }

                Row {
                    width: parent.width
                    height: userNameTextField.height

                    Text {
                        id: userNameText
                        anchors.left: parent.left
                        height: parent.height
                        text: "User Name"
                        font.pointSize: primaryFontSize * 0.75
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    CommonTextField {
                        id: userNameTextField
                        anchors {left: userNameText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                        pointSize: primaryFontSize * 0.5
                        enabled: editAccount
                    }
                }

                Row {
                    width: parent.width
                    height: passwordTextField.height

                    Text {
                        id: passwordText
                        anchors.left: parent.left
                        height: parent.height
                        text: "Password"
                        font.pointSize: primaryFontSize * 0.75
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    CommonTextField {
                        id: passwordTextField
                        anchors {left: passwordText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                        pointSize: primaryFontSize * 0.5
                        echoMode: TextInput.Password
                        enabled: editAccount
                    }
                }

                Row {
                    width: parent.width
                    height: serverTextField.height

                    Text {
                        id: serverText
                        anchors.left: parent.left
                        height: parent.height
                        text: "Server"
                        font.pointSize: primaryFontSize * 0.75
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    CommonTextField {
                        id: serverTextField
                        anchors {left: serverText.right; leftMargin: primaryFontSize * 0.5; right: parent.right}
                        pointSize: primaryFontSize * 0.5
                        enabled: editAccount
                    }
                }

                Row {
                    id: portRow
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

                    Button {
                        id: sslButton
                        text: "SSL"
                        width: parent.width / 3
                        enabled: encryptionSetting != 1
                        onClicked: {
                            encryptionSetting = 1
                            serverPortTextField.text = 993
                        }
                    }

                    Button {
                        id: startTlsButton
                        text: "STARTTLS"
                        width: parent.width / 3
                        enabled: encryptionSetting != 2
                        onClicked: {
                            encryptionSetting = 2
                            serverPortTextField.text = 143
                        }
                    }
                }
            }
        }
    }

    onAccepted: {
        if (currentAccountId >= 0) {
            imapAccountHelper.setSyncAccount(currentAccountId)
        }
        imapAccountSettingsSheet.close()

        imapAccountSettingsSheet.close();
    }

    onRejected: imapAccountSettingsSheet.close();
}

/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
 *               2012 Jolla Ltd.
 * All rights reserved.
 *
 * You may use this file under the terms of BSD license as follows:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the author nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 2.0
import org.asteroid.controls 1.0
import org.nemomobile.lipstick 0.1
import "../desktop.js" as Desktop

Item {
    id: notificationWindow
    width: Desktop.instance.width
    height: Desktop.instance.height
    x: Desktop.instance.x
    y: Desktop.instance.y

    MouseArea {
        id: notificationArea
        anchors.fill: parent
        enabled: state == "show"
        onClicked: if (notificationPreviewPresenter.notification != null) notificationPreviewPresenter.notification.actionInvoked("default")

        Image {
            anchors.fill: parent
            source: notificationArea.pressed ? "qrc:/images/diskBackgroundPressed.svg" : "qrc:/images/diskBackground.svg"
            sourceSize.width: width
            sourceSize.height: height
        }

        Icon {
            id: icon
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -parent.height*0.2
            width: parent.width*0.2
            height: width
            color: "#666666"
            name: {
                var notif = notificationPreviewPresenter.notification;
                if(notif==null)
                    return "";
                else if(notif.icon == "")
                    return "ios-mail-outline";
                else
                    return notif.icon;
                }
        }

        Text {
            id: summary
            anchors.top: icon.bottom
            height: text == "" ? 0 : undefined
            width: parent.width*0.7
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: parent.height*0.03
            color: "#666666"
            font.pixelSize: parent.height*0.05
            font.bold: true
            clip: true
            elide: Text.ElideRight
            text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewSummary : ""
        }

        Text {
            id: body
            anchors.top: summary.bottom
            width: parent.width/2
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: parent.height*0.06
            color: "#666666"
            font.pixelSize: parent.height*0.05
            font.bold: summary.text == ""
            clip: true
            maximumLineCount: 3
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewBody : ""
        }

        states: [
            State {
                name: "show"
                PropertyChanges {
                    target: notificationArea
                    opacity: 1
                }
                StateChangeScript {
                    name: "notificationShown"
                    script: {
                        notificationTimer.start()
                    }
                }
            },
            State {
                name: "hide"
                PropertyChanges {
                    target: notificationArea
                    opacity: 0
                }
                StateChangeScript {
                    name: "notificationHidden"
                    script: {
                        notificationTimer.stop()
                        notificationPreviewPresenter.showNextNotification()
                    }
                }
            }
        ]

        transitions: [
            Transition {
                to: "show"
                SequentialAnimation {
                    NumberAnimation { property: "opacity"; duration: 200 }
                    ScriptAction { scriptName: "notificationShown" }
                }
            },
            Transition {
                to: "hide"
                SequentialAnimation {
                    NumberAnimation { property: "opacity"; duration: 200 }
                    ScriptAction { scriptName: "notificationHidden" }
                }
            }
        ]

        Timer {
            id: notificationTimer
            interval: 3000
            repeat: false
            onTriggered: notificationArea.state = "hide"
        }

        Connections {
            target: notificationPreviewPresenter;
            onNotificationChanged: notificationArea.state = (notificationPreviewPresenter.notification != null) ? "show" : "hide"
        }
    }
}

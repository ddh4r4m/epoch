/*
    SPDX-FileCopyrightText: zayronxio
    SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick 2.12
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    property string codeleng: ((Qt.locale().name)[0]+(Qt.locale().name)[1])
    property bool formato12Hour: plasmoid.configuration.hourFormat
    property bool visibleTxt: Plasmoid.configuration.activeText

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    function desktoptext(languageCode) {
        const translations = {
            "es": "son las",         // Spanish
            "en": "it is",           // English
            "hi": "यह",              // Hindi
            "fr": "il est",          // French
            "de": "es ist",          // German
            "it": "sono le",         // Italian
            "pt": "são",             // Portuguese
            "ru": "сейчас",          // Russian
            "zh": "现在是",           // Chinese (Mandarin)
            "ja": "今",              // Japanese
            "ko": "지금은",           // Korean
            "nl": "het is"           // Dutch
        };

        // Return the translation for the language code or default to English if not found
        return translations[languageCode] || translations["en"];
    }

    FontLoader {
        id: milk
        source: "../fonts/Milkshake.ttf"
    }
    FontLoader {
        id: metro
        source: "../fonts/Metropolis-Black.ttf"
    }

    fullRepresentation: Item {
        id: mainContainer
        width: plasmoid.width
        height: plasmoid.height
        
        // Main rectangle with glow - this is now the only box
        Rectangle {
            id: base
            width: parent.width * 0.95
            height: parent.height * 0.85
            radius: height/10
            color: "#262842"  // Dark purple-blue interior
            anchors.centerIn: parent
            
            // Purple glow border effect
            layer.enabled: true
            layer.effect: Glow {
                radius: 15
                samples: 24
                color: "#9747c7"  // Purple glow color from screenshot
                spread: 0.2
            }
        }
        
        // Time display (16:20)
        Item {
            id: timeContainer
            width: base.width
            height: childrenRect.height
            anchors.centerIn: base
            
            Row {
                id: timeRow
                spacing: 0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: undefined
                anchors.right: undefined
                
                // Hours with blue gradient
                Text {
                    id: hora
                    property var currentDate: new Date()
                    text: formato12Hour
                    ? (currentDate.getHours() === 0
                    ? "12"
                    : (currentDate.getHours() <= 12
                    ? String(currentDate.getHours())
                    : String(currentDate.getHours() - 12)))
                    : Qt.formatDateTime(currentDate, "HH")
                    font.pixelSize: Math.min(mainContainer.width, mainContainer.height) * 0.36
                    font.family: metro.name
                    font.weight: Font.Bold
                    
                    LinearGradient {
                        anchors.fill: parent
                        source: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#78C3FB" }  // Light blue
                            GradientStop { position: 1.0; color: "#3A66F9" }  // Darker blue
                        }
                    }
                }
                
                // Colon separator
                Text {
                    text: ":"
                    font.pixelSize: hora.font.pixelSize
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    color: "#DDDDDD"
                }
                
                // Minutes with orange-pink gradient
                Text {
                    id: minutos
                    property var currentDate: hora.currentDate
                    text: Qt.formatDateTime(currentDate, "mm")
                    font.pixelSize: hora.font.pixelSize
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    
                    LinearGradient {
                        anchors.fill: parent
                        source: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#F9A55A" }  // Orange
                            GradientStop { position: 1.0; color: "#F25576" }  // Pink
                        }
                    }
                }
            }
            
            // Seconds as superscript
            Text {
                id: segundos
                property var currentDate: hora.currentDate
                text: Qt.formatDateTime(currentDate, "ss")
                font.pixelSize: hora.font.pixelSize * 0.4
                font.family: hora.font.family
                font.weight: Font.Bold
                color: "#4DD8C8"  // Teal
                anchors.left: timeRow.right
                anchors.top: timeRow.top
                anchors.topMargin: -5
            }
        }
        
        // Date display centered below time
        Text {
            id: dateText
            width: base.width
            horizontalAlignment: Text.AlignHCenter
            property var currentDate: hora.currentDate
            text: Qt.formatDateTime(currentDate, "MMM, dddd d")
            font.pixelSize: Math.min(mainContainer.width, mainContainer.height) * 0.08
            font.family: hora.font.family
            color: "#CC73E1"  // Light purple
            anchors.horizontalCenter: timeContainer.horizontalCenter
            anchors.top: timeContainer.bottom
            anchors.topMargin: 2
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                hora.currentDate = new Date()
                minutos.currentDate = hora.currentDate
                segundos.currentDate = hora.currentDate
                dateText.currentDate = hora.currentDate
            }
        }
    }
}
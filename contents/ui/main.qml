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

    fullRepresentation: RowLayout {
        Layout.minimumWidth: 300
        Layout.minimumHeight: 150
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight
        
        // Main background with glow effect
        Rectangle {
            id: baseBackground
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height
            color: "#272640"  // Dark purple-blue background
            anchors.centerIn: parent
            
            // Clock background with rounded corners
            Rectangle {
                id: base
                width: Math.max(clockLayout.width + 60, parent.width * 0.8)
                height: Math.max(clockLayout.height + 60, parent.height * 0.7)
                radius: height/8
                color: "#2D2D3F"  // Slightly lighter than the background
                anchors.centerIn: parent
                
                // Add glow effect
                layer.enabled: true
                layer.effect: Glow {
                    radius: 20
                    samples: 41
                    color: "#7747AC"  // Purple glow
                    spread: 0.2
                }
            }
        }

        // Clock components layout
        ColumnLayout {
            id: clockLayout
            anchors.centerIn: base
            spacing: 10
            
            // Main time display (hours, colon, minutes)
            RowLayout {
                id: timeRow
                Layout.alignment: Qt.AlignHCenter
                spacing: 0
                
                // Hours with blue gradient
                Text {
                    id: hora
                    property var currentDate: new Date()
                    text: formato12Hour
                    ? (currentDate.getHours() === 0
                    ? "12"
                    : (currentDate.getHours() <= 12
                    ? String(currentDate.getHours()).padStart(2, '0')
                    : String(currentDate.getHours() - 12).padStart(2, '0')))
                    : Qt.formatDateTime(currentDate, "HH")
                    font.pixelSize: Math.min(base.width, base.height) * 0.25
                    font.family: metro.name
                    font.weight: Font.Bold
                    Layout.alignment: Qt.AlignBottom
                    
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
                    id: colon
                    text: ":"
                    font.pixelSize: hora.font.pixelSize 
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    color: "#DDDDDD"  // Light gray
                    Layout.alignment: Qt.AlignBottom
                }
                
                // Minutes with orange-pink gradient
                Text {
                    id: minutos
                    property var currentDate: hora.currentDate
                    text: Qt.formatDateTime(currentDate, "mm")
                    font.pixelSize: hora.font.pixelSize
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    Layout.alignment: Qt.AlignBottom
                    
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
                
                // AM/PM indicator
                Text {
                    id: ampm
                    visible: formato12Hour
                    property var currentDate: hora.currentDate
                    text: currentDate.getHours() < 12 ? "AM" : "PM"
                    font.pixelSize: hora.font.pixelSize * 0.3
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    color: "#FFD166"  // Gold/yellow
                    Layout.alignment: Qt.AlignTop
                    Layout.leftMargin: 5
                }
            }
            
            // Seconds display
            Text {
                id: segundos
                property var currentDate: hora.currentDate
                text: Qt.formatDateTime(currentDate, "ss")
                font.pixelSize: hora.font.pixelSize * 0.3
                font.family: hora.font.family
                font.weight: Font.Bold
                color: "#4DD8C8"  // Teal
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 10
            }
            
            // Date display
            Text {
                id: dateText
                property var currentDate: hora.currentDate
                text: Qt.formatDateTime(currentDate, "MMM, dddd d")
                font.pixelSize: hora.font.pixelSize * 0.25
                font.family: "Arial"
                color: "#CC73E1"  // Light purple
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
            }
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
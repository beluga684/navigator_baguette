import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12
import QtPositioning 5.12
import QtLocation 5.12
import myclass 1.0

ApplicationWindow { //главное окно
    visible: true
    width: 1000
    height: 600
    title: "мапус"

    property bool count_start : false //флажок нажатия кнопки старта
    property bool count_end : false //флажок нажатия кнопки конца
    property bool calculated: false //флажок для расчитанного маршрута
    property bool chaeck_ip : false //флажок для проверки wi-fi соединения

    property real startLatitude : 0 //координаты точек
    property real startLongitude : 0
    property real endLatitude : 0
    property real endLongitude : 0

    Plugin { //плагин для отображения карты OpenStreetMaps
        id: mapPlugin
        name: "osm"
    }

    MapUs { //объявление класса обработки маршрута
        id: myMap
    }

    Rectangle { //область UI с картой и элементами
        width: 700
        height: 600
        color: "green"
        x: 0

        Map { //карта
            id: map
            anchors.fill: parent
            plugin: mapPlugin
            center: QtPositioning.coordinate(59.941545, 30.304488)
            zoomLevel: 14

            MouseArea { //область считывания клика мыши
                anchors.fill: parent
                onClicked: {
                    if (count_start == true) //установка точки старта
                    {
                        var coordinate_start = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                        marker_start.visible = true
                        marker_start.coordinate = QtPositioning.coordinate(coordinate_start.latitude, coordinate_start.longitude)
                        startLatitude = coordinate_start.latitude
                        startLongitude = coordinate_start.longitude
                        count_start = false
                        button_start.background.color = "#ff6e6e"
                        route.visible = false
                        label.text = ""
                        label_1.text = ""
                        calculated = false
                    }
                    else if (count_end == true) //установка точки конца
                    {
                        var coordinate_end = map.toCoordinate(Qt.point(mouse.x, mouse.y))
                        marker_end.visible = true
                        marker_end.coordinate = QtPositioning.coordinate(coordinate_end.latitude, coordinate_end.longitude)
                        endLatitude = coordinate_end.latitude
                        endLongitude = coordinate_end.longitude
                        count_end = false
                        button_end.background.color = "#816eff"
                        route.visible = false
                        label.text = ""
                        label_1.text = ""
                        calculated = false
                    }
                }
            }

            MapPolyline { //линия маршрута
                id: route
                line.width: 4
                line.color: 'red'
                visible: false
            }

            MapQuickItem { //маркер на точку старта
                id: marker_start
                anchorPoint.x: image_s.width / 2
                anchorPoint.y: image_s.width
                sourceItem: Image {
                    id: image_s
                    source: "qrc:///marker_start.png"
                    width: 40
                    height: 40
                }
                visible: false
            }

            MapQuickItem { //маркер на точку конца
                id: marker_end
                anchorPoint.x: image_e.width / 2
                anchorPoint.y: image_e.width
                sourceItem: Image {
                    id: image_e
                    source: "qrc:///marker_end.png"
                    width: 40
                    height: 40
                }
                visible: false
            }
        }
    }

    Rectangle { //область UI с кнопками
        width: 300
        height: 600
        color: "#d9e5b2"
        x: 700

        Column {
            id : column_el
            spacing: 15
            anchors.centerIn: parent

            Row { //строка кнопок начала и конца
                spacing: 10

                Button {
                    id: button_start
                    text: "начало"
                    width: 125
                    background: Rectangle {
                        radius: 10
                        color: "#ff6e6e"
                    }
                    onClicked: {
                        if (count_start == false)
                        {
                            button_start.background.color = "#ff1e1e"
                            count_start = true
                        }
                        else
                        {
                            button_start.background.color = "#ff6e6e"
                            count_start = false
                        }
                    }
                }

                Button {
                    id: button_end
                    text: "конец"
                    font.bold: false
                    width: 125
                    background: Rectangle {
                        radius: 10
                        color: "#816eff"
                    }
                    onClicked: {
                        if (count_end == false)
                        {
                            button_end.background.color = "#3c1eff"
                            count_end = true
                        }
                        else
                        {
                            button_end.background.color = "#816eff"
                            count_end = false
                        }
                    }
                }
            }

            Row { //строка кнопок расчёта и отображения маршрута
                spacing: 10
                Button {
                    text: "построить"
                    width: 125
                    background: Rectangle {
                        radius: 10
                        color: "#8adf72"
                    }
                    onClicked: {
                        if (myMap.check_IP() === true)
                        {
                            if (calculated === false)
                            {
                                if (startLatitude > 0 && startLongitude > 0 && endLatitude > 0 && endLongitude > 0)
                                {
                                    myMap.onButtonClicked(startLatitude, startLongitude, endLatitude, endLongitude)
                                    label.text = "расчитано, можно отображать"
                                    label_1.text = ""
                                    route.visible = false
                                    calculated = true
                                }
                            }
                        }
                        else
                        {
                            label.text = "расчёт не выполнен - проверьте"
                            label_1.text = "подключение к интернету"
                            calculated = false
                        }

                    }
                }

                Button {
                    text: "отобразить"
                    width: 125
                    background: Rectangle {
                        radius: 10
                        color: "#8adf72"
                    }
                    onClicked: {
                        var list_size = myMap.get_Size()
                        if (list_size > 0 && startLatitude > 0 && endLatitude > 0 && calculated == true)
                        {
                            var lat_list = myMap.getDouble_lat()
                            var lng_list = myMap.getDouble_lng()
                            var path = [];
                            for (var i = 0; i<list_size; i++)
                            {
                                path.push(QtPositioning.coordinate(lat_list[i], lng_list[i]));
                            }
                            route.path = path;
                            route.visible = true;

                            marker_start.coordinate = QtPositioning.coordinate(lat_list[0], lng_list[0])
                            marker_end.coordinate = QtPositioning.coordinate(lat_list[list_size-1], lng_list[list_size-1])

                            label.text = myMap.get_Time()
                            label_1.text = myMap.get_Dist() + " метров"
                        }
                    }
                }
            }

            Row { //строка с информационным лейблом
                Text {
                    id: label
                    text: ""
                    font.pixelSize: 15
                    color: "green"
                }
            }

            Row { //строка с информационным лейблом
                Text {
                    id: label_1
                    text: ""
                    font.pixelSize: 15
                    color: "green"
                }
            }

            Row { //строка с кнопкой очистки
                Button {
                    text: "очистить"
                    width: 260
                    background: Rectangle {
                        radius: 10
                        color: "#8adf72"
                    }
                    onClicked: {
                        marker_end.visible = false
                        marker_start.visible = false

                        label.text = ""
                        label_1.text = ""

                        startLatitude = 0
                        startLongitude = 0
                        endLatitude = 0
                        endLongitude = 0

                        route.visible = false
                    }
                }
            }
        }
    }
}

